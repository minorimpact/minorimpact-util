#!/usr/bin/perl

use strict;

use Getopt::Long "HelpMessage";
use Term::ReadKey;
use MinorImpact::CLI;
use MinorImpact::Util;

my $options = {
                help => sub { HelpMessage(); },
            };

Getopt::Long::Configure("bundling");
GetOptions( $options,
            "admin|a=s",
            "config|c=s",
            "debug|d",
            "help|?|h",
            "password|p",
            "username|u=s",
            "verbose|v",
        ) || HelpMessage();

eval { main(); };
if ($@) {
    print "$@\n";
    exit(1);
}

sub main {
    my $username = shift @ARGV;

    MinorImpact::debug($options->{debug});
    MinorImpact::clearSession();
    my $MINORIMPACT = new MinorImpact({config_file=>$options->{config}});

    if ($options->{username}) {
        # Override the environment variable and try to force validation as a different user.
        $ENV{USER} = $options->{username};
    }

    my $login = MinorImpact::user();

    unless ($username) {
        HelpMessage({message=>"You must specify a username.", exitval=>0});
    }
    
    my $user = new MinorImpact::User($username);
    die "$username doesn't exist.\n" unless ($user);

    if (defined($options->{admin})) {
        print "Updating admin rights.\n";
        $user->update({admin => isTrue($options->{admin})});
    }
    if (defined($options->{email}) && $options->{email}) {
        print "Setting email\n";
        $user->update({email => $options->{email}});
    }
    if (defined($options->{password})) {
        print "Setting password\n";
        my $new_password = MinorImpact::CLI::passwordPrompt({confirm=>1, username=>$user->name()});
        $user->update({password => $new_password});
    }
}

=head1 NAME

edit_user.pl - MinorImpact utility to update a a user

=head1 SYNOPSIS

edit_user.pl [options] EDIT_USER

  Options:
  -a, --admin yes/no    Turn admin rights on or off for EDIT_USER.
  -c, --config FILE     Read connection information from FILE.
  -d, --debug           Turn debugging output on.
  -h, --help            Usage information.
  -p, --password        Prompt for a new password for EDIT_USER.
  -u, --username USER   Run as USER instead of $ENV{USER}.
  -v, --verbose         Verbose output.

User updates can only be performed by THE USER THEMSELVES or AN ADMIN USER.  If 
you're not running this to make changes to your own user, and you're not
an admin, then you have to run the script as an admin user user by invoking
the "--username" option.  

Examples

Use the configuration in /etc/minorimpact.conf to turn on admin
rights for user 'foo'

  edit_user.pl -c /etc/minorimpact.conf -a yes foo

Turn off admin rights for user 'foo', but log into MinorImpact
as the 'admin' user instead of yourself.

  edit_user.pl -a no -u admin foo

=cut
