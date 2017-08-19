#!/usr/bin/perl

use strict;
use Time::HiRes qw(tv_interval gettimeofday);
use Getopt::Long "HelpMessage";

my $options = {
                config => $ENV{MINORIMPACT_CONFIG},
                help => sub { HelpMessage(); },
            };

Getopt::Long::Configure("bundling");
GetOptions( $options,
            "config|c=s",
            "count|c=i",
            "force|f",
            "help|?|h",
            "id|i=i",
            "test_count|t=i",
            "verbose",
        ) || HelpMessage();


use MinorImpact;
use MinorImpact::Object;
use MinorImpact::Object::Search;
use MinorImpact::Test;
use MinorImpact::Util;


use Uravo::InfluxDB;

use lib "../lib";

die "config file $options->{config} does not exist" unless (-f $options->{config});
my $test_count = $options->{test_count} || $options->{count} || int(rand(10)) + 1;
my $MAX_CHILD_COUNT = 3;
my $verbose = $options->{verbose};
my $start_time = [gettimeofday];

my %child;
my $i = 0;
while ($i++ < $test_count) {
    my $pid;
    defined ($pid = fork()) || die "Can't fork\n";

    if ($pid) {
        $child{$pid} = 1;
        if (scalar keys %child >= $MAX_CHILD_COUNT) {
            my $done = wait();
            delete $child{$done};
        }
    } else {
        test();
        exit;
    }
}
while (wait() > 0) {}
my $end_time = [gettimeofday];

my $MINORIMPACT = new MinorImpact({ no_log => ($options->{verbose}?0:1), config_file => $options->{config} });
my $application_id = $MINORIMPACT->{conf}{default}{application_id};
my $default_type_id = MinorImpact::Object::getType() || die "Unable to get a default type.";

my $DB = $MinorImpact::SELF->{DB};
my $USERDB = $MinorImpact::SELF->{USERDB};
my $total_time = tv_interval($start_time, $end_time);
if ($test_count) {
    my $avg_time = $total_time/$test_count;
    print "average test time = $avg_time\n" if ($options->{verbose});
    Uravo::InfluxDB::influxdb({ db => $application_id, metric => "test_avg", value => $avg_time }) if ($application_id);
}

my $user_count = $USERDB->selectrow_array("SELECT count(*) FROM user");
my $object_count = $DB->selectrow_array("SELECT count(*) FROM object WHERE object_type_id=?", undef, ($default_type_id));
my $tag_count = $DB->selectrow_array("SELECT count(*) FROM object_tag");
my $unique_tag_count = $DB->selectrow_array("SELECT count(distinct(name)) FROM object_tag");

print "user_count = $user_count\n" if ($options->{verbose});
Uravo::InfluxDB::influxdb({ db => $application_id, metric => "user_count", value => $user_count }) if ($application_id);
print "object_count = $object_count\n" if ($options->{verbose});
Uravo::InfluxDB::influxdb({ db => $application_id, metric => "object_count", value => $object_count }) if ($application_id);
print "tag_count = $tag_count\n" if ($options->{verbose});
Uravo::InfluxDB::influxdb({ db => $application_id, metric => "tag_count", value => $tag_count }) if ($application_id);
print "unique_tag_count = $unique_tag_count\n" if ($options->{verbose});
Uravo::InfluxDB::influxdb({ db => $application_id, metric => "unique_tag_count", value => $unique_tag_count }) if ($application_id);
if ($user_count) {
    print "objects/user = " . ($object_count/$user_count) . "\n"  if ($options->{verbose});
    Uravo::InfluxDB::influxdb({ db => $application_id, metric => "notes_per_user", value => ($object_count/$user_count) }) if ($application_id);
    print "tags/user = " . ($tag_count/$user_count) . "\n"  if ($options->{verbose});
    Uravo::InfluxDB::influxdb({ db => $application_id, metric => "tags_per_user", value => ($tag_count/$user_count) }) if ($application_id);
}
if ($object_count) {
    print "tags/object = " . ($tag_count/$object_count) . "\n"  if ($options->{verbose});
    Uravo::InfluxDB::influxdb({ db => $application_id, metric => "tags_per_note", value => ($tag_count/$object_count) }) if ($application_id);
}

sub test {
    my $test_start_time = [gettimeofday];
    srand();
    my $MINORIMPACT = new MinorImpact({ no_log => ($options->{verbose}?0:1), config_file => $options->{config}, log_method => 'file', log_file => '/tmp/debug.log'  });
    my $application_id = $MINORIMPACT->{conf}{default}{application_id};
    my $default_object_type_id = MinorImpact::Object::getType() || die "Unable to get a default type.";
    my $default_object_type = MinorImpact::Object::typeName($default_object_type_id) || die "Unable to get a default type name.";
    my $lib_directory = $MINORIMPACT->{conf}{default}{lib_directory};
    push(@INC, $lib_directory) if ($lib_directory);

    my $user = MinorImpact::Test::randomUser();
    my $user_type = int(rand(4));
    if ($user_type == 0 || !$user) { # new user
        my $password = time() . $$ . int(rand(100)) ;
        my $username = "test_user_note_$password";
        print "$$ adding user $username\n" if ($options->{verbose});
        MinorImpact::User::addUser({ username => $username, password => $password });
        $user = MinorImpact::user({ username => $username, password => $password }) || die "Can't retrieve user $username\n";;
    } elsif ($user_type == 1) { # angry user
        print "$$ deleting user " . $user->name() . "(" . $user->id() . ")\n" if ($options->{verbose});
        return $user->delete();
    } else {
        print "$$ logging in as " . $user->name() . "(" . $user->id() . ")\n" if ($options->{verbose});
    }

    eval {
        require "$default_object_type.pm";
        eval $default_object_type . '::churn({ user => $user, verbose => $options->{verbose} });';
    };
    print "$@\n" if ($@ && $options->{verbose});
    MinorImpact::log('notify', $@) if ($@);

    my $test_end_time = [gettimeofday];
    #print "test_time=" . tv_interval($test_start_time, $test_end_time) . "\n";
    #print "deleting user $username\n";
    #$user->delete();
}

