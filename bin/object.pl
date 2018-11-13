#!/usr/bin/perl


use Data::Dumper;
use Term::ReadKey;
use Getopt::Long "HelpMessage";

use MinorImpact;
use MinorImpact::Object;
use MinorImpact::User;


my $MINORIMPACT;


my $options = {
                action => "list",
                help => sub { HelpMessage(); },
            };

Getopt::Long::Configure("bundling");
GetOptions( $options, 
            "action|a=s",
            "config|c=s", 
            "debug|d",
            "help|?|h",
            "id|i=s",
            "type_id|type|t=s",
            "username|u=s",
            "verbose|v",
        ) || HelpMessage();

eval { main(); };
if ($@) {
    die "$@";
}


sub main {
    MinorImpact::debug($options->{debug});
    $MINORIMPACT = new MinorImpact({config_file=>$options->{config}});
    if ($options->{username}) {
        $ENV{USER} = $options->{username};
    }
    my $user = MinorImpact::user();
    die "Invalid user\n" unless ($user);

    if ($options->{id} && (!$options->{action} || $options->{action} eq 'list')) {
        # We can't 'list' a single object, so just change it to 'info' if ID is defined.
        $options->{action} = 'info';
    }

    if ($options->{action} eq 'list') {
        my $params;
        $params->{query}{user_id} = $user->id();
        $params->{query}{object_type_id} = MinorImpact::Object::typeID($options->{type_id});
        my @objects = MinorImpact::Object::Search::search($params);
        foreach my $object (@objects) {
            printf("%s (%d)\n", $object->name(), $object->id());
        }
    } elsif ($options->{id} && $options->{action} eq 'info') {
        my $object = new MinorImpact::Object($options->{id}) || die "Can't retrieve object.";
        print $object->name() . " (" . $object->id() . ")\n";
        print "-------\n";
        print "  type: " . $object->typeName() . "\n";
        print "  description:" . $object->get('description') . "\n";
        print  "  fields:\n";
        my $fields = $object->fields();
        foreach my $field_name (sort keys %$fields) {
            my $field = $fields->{$field_name};
            foreach my $value ($field->value()) {
                if (ref($value)) {
                    print "    $field_name: " . $value->name() . "\n";
                } else {
                    print "    $field_name: " . $value . "\n";
                }
            }
        }

        print "\n";
    } else {
         HelpMessage({message=>"No valid ACTION specified.", exitval=>0});
     }
}

=head1 NAME

object.pl - Command line tool for viewing and editing MinorImpact object databases.

=head1 SYNOPSIS

object.pl [options]

  Options:
  -a, --action=ACTION   Perform ACTION.  default: info
                        Actions:
                            info    Show information about ID.
                            list    show all objects that match search criteria. See "List options" below.
  -c, --config=FILE     Read connection information from FILE.
  -d, --debug           Turn on debug logs.
  -h, --help            Usage information.
  -u, --username=USER   Connect as USER.  default: $ENV{USER}
  -v, --verbose         Verbose output.

  Info options:
  -i, --id=ID           ID of the object you want to take action on.

  List options:
  -t, --type_id=TYPE    Object is TYPE.

=cut

