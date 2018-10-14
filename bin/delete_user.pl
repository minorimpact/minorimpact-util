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
            "debug|d",
            "config|c=s",
            "help|?|h",
            "username|u=s",
            "verbose",
        ) || HelpMessage();

eval { main(); };
if ($@) {
    print "$@\n";
    exit(1);
}

sub main {
    my $del_user = shift @ARGV;

    MinorImpact::debug($options->{debug});
    MinorImpact::clearSession();
    my $MINORIMPACT = new MinorImpact({config_file=>$options->{config}});

    if ($options->{username}) {
        # Override the environment variable and try to force validation as a different user.
        $ENV{USER} = $options->{username};
    }

    unless ($del_user) {
        HelpMessage({message=>"You must specify a login name for the user to delete.", exitval=>0});
    }
    
    my $user = new MinorImpact::User($del_user);
    if (!$user) {
        die "'" . $del_user . "' doesn't exist.\n";
    }
    if ($user->isAdmin() && MinorImpact::User::count({admin => 1}) <= 1) {
        die "You cann't delete the only admin user!\n";
    }

    unless ($user->delete()) {
        die "Unable to delete '$del_user'\n";
    }
    print "'$del_user' deleted.\n";
}

=head1 NAME

delete_user.pl - Deletes a MinorImpact user and all owned objects.

=head1 SYNOPSIS

delete_user.pl [options] DEL_USER

  Options:
  -a, --admin           Set 'admin' as true for the new user.
  -c, --config=FILE     Read connection information from FILE.
  -d, --debug           Turn debugging output on.
  -h, --help            Usage information.
  -u, --username=USER   Run as USER instead of $ENV{USER}.
  -v, --verbose         Verbose output.

=head1 DESCRIPTION

Deletes the user and all objects owned by that user.  Can only be run by an 'admin' user.

=cut
