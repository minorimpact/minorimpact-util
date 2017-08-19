#!/usr/bin/perl

use strict;

use lib "../lib";

use Getopt::Long "HelpMessage";

use MinorImpact;
use MinorImpact::Object;
use MinorImpact::Object::Search;
use MinorImpact::Util;

my $options = {
                action => "info",
                count => 50,
                help => sub { HelpMessage(); },
                user => $ENV{USER},
            };

Getopt::Long::Configure("bundling");
GetOptions( $options,
            "action|a=s",
            "config|c=s",
            "count=i",
            "force|f",
            "help|?|h",
            "id|i=i",
            "user|u=s",
            "verbose",
        ) || HelpMessage();

eval { main(); };
if ($@) {
    HelpMessage({message=>$@, exitval=>1});
}

sub main {
    my $MINORIMPACT = new MinorImpact({config_file=>$options->{config}});

    my $DB = $MinorImpact::SELF->{DB};
    my $USERDB = $MinorImpact::SELF->{USERDB};
    if ($options->{id} && (!$options->{action} || $options->{action} eq 'info')) {
        $options->{action} = 'info';
    }

    if ($options->{action} eq 'info') {
        if ($options->{id}) {
            my $user_id = $options->{id};
            my $user = new MinorImpact::User($user_id);
            print $user->name() . "($user_id):\n";
            my @object_ids = $user->searchObjects({ query=> { id_only => 1 } });
            print "  object count " . scalar(@object_ids) . "\n";
            return;
        }
        my $user_count = MinorImpact::User::count();
        print "user_count $user_count\n";
        my $test_user_count = MinorImpact::User::count({ name => 'test_user_%' });
        print "test_user_count $test_user_count\n";
    } elsif ($options->{action} eq 'delete') {
        my $count = $options->{count};

        my $test_user_count = MinorImpact::User::count({ name => 'test_user_%', });
        die "Can't delete '$count' test users; total test users is '$test_user_count'." if ($count > $test_user_count);

        print "Deleting '$count' test users.\n";

        # Delete the users with the automated "test_user_*" name.
        my @users = MinorImpact::User::search({ limit => $count, name => 'test_user_%', order_by => 'RAND()' });
        foreach my $user (@users) {
            next if ($user->id() == 1);
            print "  deleting " . $user->name() . "(" . $user->id() . ")\n";
            my $username = $user->name();
            my ($password) = $username =~/_([0-9]+)$/;
            my $active_user = MinorImpact::user({ username => $username, password => $password });
            $active_user->delete() if ($active_user);
        }
    } else {
         HelpMessage({message=>"'$options->{action}' is not a valid ACTION.", exitval=>0});
    }
}

=pod

=name1 NAME

test_user.pl - MinorImpact utility script for manipulating test users in a MinorImpact application.

=name1 SYNOPSIS

test_user.pl [options]

  Options:
  -a, --action=ACTION   Perform ACTION.  default: info
                        Actions:
                            info    Show information about the userdatabase in the
                                    application described by FILE.
                            delete  delete COUNT test users.
  -c, --config=FILE     Read connection information from FILE.
      --count=COUNT     Operate on COUNT number of test users.
  -f, --force           Never request conformation.
  -h, --help            Usage information.
  -v, --verbose         Verbose output.

=cut
