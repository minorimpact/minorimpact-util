#!/usr/bin/perl


=head1 NAME

reset.pl - Reset the MinorImpact application.

=head1 SYNOPSIS

reset.pl [options]

=head2 Options

=over

=item -a, --admin

Reset the password for the 'admin' user to 'admin'.

=item -c, --config=FILE

Read connection information from FILE.

Default: /etc/minorimpact.conf

=item -d, --debug

Turn on debug logs.

=item -f, --force

Do not prompt for confirmation before wiping out the existing database.

=item -h, --help

Usage information.

=item -v, --verbose 

Verbose output.

=back

=head1 AUTHOR

Patrick Gillan <pgillan@minorimpact.com>

=cut

use Data::Dumper;
use Getopt::Long "HelpMessage";
use JSON;
use MinorImpact;
use MinorImpact::Object;
use MinorImpact::User;

my $MINORIMPACT;

my $postponed = {};

my $options = {
    help => sub { HelpMessage(); },
};

Getopt::Long::Configure("bundling");
GetOptions( 
    $options, 
    "admin|a", 
    "config|c=s", 
    "debug|d",
    "force|f",
    "help|?|h",
    "verbose|v",
) || HelpMessage();

eval { main(); };
if ($@) {
    die $@;
}

sub main {
    MinorImpact::debug($options->{debug});
    $MINORIMPACT = new MinorImpact({config_file=>$options->{config}});
    $ENV{USER} = 'admin';

    my $current_user = MinorImpact::user( { force => 1, admin =>1 });

    unless ($options->{force}) {
        print "This will completely erase the existing data.  Are you sure? (y/N) ";
        my $confirm = <>;
        if (lc($confirm) =~/^y/) {
            print "Confirmed.\n" if ($options->{verbose});
        } else {
            print "Aborted.\n" if ($options->{verbose});
            return;
        }
    }

    print "Searching for users\n" if ($options->{verbose});
    my @users = MinorImpact::User::search();
    foreach my $user (@users) {
        print "Searching for objects for " . $user->name() . "\n" if ($options->{verbose});
        foreach my $object ($user->searchObjects()) {
            push(@{$user_data->{objects}}, $object->toData());
            print "Deleting object " . $object->name() . "\n" if ($options->{verbose});
            $object->delete();
        }
        unless ($user->name() eq 'admin') {
            print "Deleting user " . $user->name() . "\n" if ($options->{verbose});
            $user->delete();
        }
    }

    if ($options->{admin}) {
        my $DB = MinorImpact::db();
        my $admin_password = crypt("admin", $$);
        $DB->do("UPDATE user SET password = ? WHERE name=?", undef, ($admin_password, "admin")) || die $DB->errstr;
    }


    print "Searching for types\n" if ($options->{verbose});
    my @types = MinorImpact::Object::types();
    foreach my $type (@types) {
        print "Deleting type " . $type->name() . "\n" if ($options->{verbose});
        $type->delete();
    }

    MinorImpact::clearCache();
    MinorImpact::dbConfig();
}

