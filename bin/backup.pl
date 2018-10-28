#!/usr/bin/perl


=head1 NAME

backup.pl - Back up a MinorImpact application.

=head1 SYNOPSIS

object.pl [options]

=head2 Options

=over

=item -c, --config=FILE

Read connection information from FILE.

=item -d, --debug

Turn on debug logs.

=item -h, --help

Usage information.

=item -o, --output_file=FILE

Write output to FILE rather than STDOUT.

=item -u, --username=USER

Connect as USER.  default: $ENV{USER}

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

my $options = {
    help => sub { HelpMessage(); },
};

Getopt::Long::Configure("bundling");
GetOptions( 
    $options, 
    "config|c=s", 
    "debug|d",
    "help|?|h",
    "output_file|o=s",
    "username|u=s",
    "verbose",
) || HelpMessage();

eval { main(); };
if ($@) {
    HelpMessage({message=>$@, exitval=>1});
}

sub main {
    #my $output;
    my $data;

    MinorImpact::debug($options->{debug});
    $MINORIMPACT = new MinorImpact({config_file=>$options->{config}});
    if ($options->{username}) {
        $ENV{USER} = $options->{username};
    }
    my $current_user = MinorImpact::user( { force => 1, admin =>1 });

    #$output .= "__USERS__\n";
    $data->{users} = [];
    my @users = MinorImpact::User::search();
    foreach my $user (@users) {
        #$output .= $user->toString({ format => 'json' }) . "\n";
        my $user_data = $user->toData();
        $user_data->{objects} = [];
        foreach my $object ($user->searchObjects()) {
            push(@{$user_data->{objects}}, $object->toData());
        }
        push(@{$data->{users}}, $user_data);
    }

    $data->{types} = [];
    my @types = MinorImpact::Object::types();
    foreach my $type (@types) {
        push(@{$data->{types}}, $type->toData());
    }

    my $output = to_json($data);
    if ($options->{output_file}) {
        open(FILE, ">$options->{output_file}") || die "Can't open " . $options->{output_file} . " for writing\n";
        print FILE $output;
        close(FILE);
    } else {
        print $output;
    }

    #HelpMessage({message=>"No valid ACTION specified.", exitval=>0});
}


