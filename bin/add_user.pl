#!/usr/bin/perl

use strict;

use Getopt::Long "HelpMessage";
use Term::ReadKey;
use MinorImpact::CLI;

my $options = {
                help => sub { HelpMessage(); },
            };

Getopt::Long::Configure("bundling");
GetOptions( $options,
            "admin|a",
            "config|c=s",
            "debug|d",
            "help|?|h",
            "username|u=s",
            "verbose|v",
        ) || HelpMessage();

eval { main(); };
if ($@) {
    print "$@\n";
    exit(1);
}

sub main {
    my $new_user = shift @ARGV;

    MinorImpact::debug($options->{debug});
    MinorImpact::clearSession();
    my $MINORIMPACT = new MinorImpact({config_file=>$options->{config}});

    if ($options->{username}) {
        # Override the environment variable and try to force validation as a different user.
        $ENV{USER} = $options->{username};
    }

    my $login = MinorImpact::user();

    unless ($new_user) {
        HelpMessage({message=>"You must specify a login name for the new user.", exitval=>0});
    }
    
    my $user = new MinorImpact::User($new_user);
    if ($user) {
        print "'" . $user->name() . "' already exists.\n";
        exit(1);
    }

    my $password = MinorImpact::CLI::passwordPrompt({confirm => 1, username=>$new_user});

    my $user = MinorImpact::User::add({username=>$new_user, password => $password, admin=>$options->{admin}});
    if ($user && $user->name() eq $new_user) {
        print "'$new_user' created.\n";
        exit(0);
    } else {
        print "Unable to create '$new_user'\n";
        exit(1);
    }
}

=head1 NAME

add_user.pl - MinorImpact utility to add users.

=head1 SYNOPSIS

add_user.pl [options] NEW_USER

  Options:
  -a, --admin           Make NEW_USER an admin.  You must be an admin
                        to create an admin user.
  -d, --debug           Turn debugging output on.
  -c, --config=FILE     Read connection information from FILE.
  -h, --help            Usage information.
  -u, --username=USER   Run as USER instead of $ENV{USER}.
  -v, --verbose         Verbose output.

=cut
