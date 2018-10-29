#!/usr/bin/perl


=head1 NAME

restore.pl - Restore a MinorImpact application.

=head1 SYNOPSIS

restore.pl [options]

=head2 Options

=over

=item -c, --config=FILE

Read connection information from FILE.

Default: /etc/minorimpact.conf

=item -d, --debug

Turn on debug logs.

=item -f, --force

Do not prompt for confirmation before wiping out the existing database.

=item -h, --help

Usage information.

=item -i, --input_file=FILE

Read data from FILE.

Required.

=item -u, --username=USER

Connect as USER.  

Default: $ENV{USER}

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
    "force|f",
    "help|?|h",
    "input_file|o=s",
    "username|u=s",
    "verbose|v",
) || HelpMessage();

eval { main(); };
if ($@) {
    die $@;
}

sub main {
    MinorImpact::debug($options->{debug});
    $MINORIMPACT = new MinorImpact({config_file=>$options->{config}});
    if ($options->{username}) {
        $ENV{USER} = $options->{username};
    }
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

    my $input;
    if ($options->{input_file}) {
        print "Reading data\n" if ($options->{verboser});
        open(FILE, "<$options->{input_file}") || die "Can't open " . $options->{input_file} . " for reading\n";
        while(<FILE>) {
            $input .= $_;
        }
        close(FILE);
    } else {
        while(<>) {
            $input .= $_;
        }
    }
    my $data = from_json($input);

    print "Searching for users\n" if ($options->{verbose});
    my @users = MinorImpact::User::search();
    foreach my $user (@users) {
        print "Searching for objects for " . $user->name() . "\n" if ($options->{verbose});
        foreach my $object ($user->searchObjects()) {
            push(@{$user_data->{objects}}, $object->toData());
            print "Deleting object " . $object->name() . "\n" if ($options->{verbose});
            $object->delete();
        }
        print "Deleting user " . $user->name() . "\n" if ($options->{verbose});
        $user->delete();
    }

    print "Searching for types\n" if ($options->{verbose});
    my @types = MinorImpact::Object::types();
    foreach my $type (@types) {
        print "Deleting type " . $type->name() . "\n" if ($options->{verbose});
        $type->delete();
    }

    foreach my $type ( @{$data->{types}}) {
        print "Adding type " . $type->{name} . "\n" if ($options->{verbose});
        my $new_type = MinorImpact::Object::Type::add($type);
    }

    foreach my $user ( @{$data->{users}}) {
        print "Adding user " . $user->{name} . "\n" if ($options->{verbose});
        my $new_user = MinorImpact::User::add($user) || die "Couldn't add $user->{name}\n";
        foreach my $object (@{$user->{objects}}) {
            print "Adding object " . $object->{name} . "\n" if ($options->{verbose});
            my $new_object = new MinorImpact::Object($object);
        }
    }
}


