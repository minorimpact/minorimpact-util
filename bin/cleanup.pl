#!/usr/bin/perl

use strict;

use Getopt::Long "HelpMessage";

use MinorImpact;
use MinorImpact::Object;
use MinorImpact::Object::Search;
use MinorImpact::Util;

my $options = {
                help => sub { HelpMessage(); },
            };

Getopt::Long::Configure("bundling");
GetOptions( $options,
            "config|c=s",
            "force|f",
            "help|?|h",
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

    # Look for orphaned objects that have no owner, and delete them.  This is an issue
    #   that should have been fixed, but leaving here just in case.
    print "looking for orphaned objects...\n";
    my $objects = $DB->selectall_arrayref("SELECT * FROM object", {Slice=>{}});
    foreach my $row (@$objects) {
        next if ($row->{user_id} == 1);
        my $user;
        eval {
            $user = new MinorImpact::User($row->{user_id});
        };
        if (!$user) {
            print "user " . $row->{user_id} . " doesn't exist\n";
            deleteObject($DB, $row->{object_type_id}, $row->{id});
        }
    }

    print "looking for orphaned tags...\n";
    my $objects = $DB->selectall_arrayref("SELECT DISTINCT(object_id) AS object_id FROM object_tag", {Slice=>{}});
    foreach my $row (@$objects) {
        my $object_id = $row->{object_id};
        my $object;
        eval {
            $object = new MinorImpact::Object($object_id, { admin => 1 });
        };
        next if ($object);
        print "can't create object for id '$object_id'\n";
        my $tags = $DB->selectall_arrayref("SELECT DISTINCT(name) AS name FROM object_tag where object_id=?", {Slice=>{}}, ($object_id));
        foreach my $r (@$tags) {
            print "  deleting tag '" . $r->{name} . "'\n";
            $DB->do("DELETE FROM object_tag WHERE object_id=? AND name=?", undef, ($object_id, $r->{name}));
        }
    }
}

sub deleteObject {
    my $DB = shift || return;
    my $object_type_id = shift || return;
    my $object_id = shift || return;

    print "deleting object '$object_id'\n";
    my $data = $DB->selectall_arrayref("select * from object_field where type like '%object[$object_type_id]'", {Slice=>{}});
    foreach my $r (@$data) {
        $DB->do("DELETE FROM object_data WHERE object_field_id=? and value=?", undef, ($r->{id}, $object_id));
    }

    my $data = $DB->selectall_arrayref("select * from object_text where object_id=?", {Slice=>{}}, ($object_id));
    foreach my $r (@$data) {
        $DB->do("DELETE FROM object_reference WHERE object_text_id=?", undef, ($r->{id}));
    }

    $DB->do("DELETE FROM object_data WHERE object_id=?", undef, ($object_id));
    $DB->do("DELETE FROM object_text WHERE object_id=?", undef, ($object_id));
    $DB->do("DELETE FROM object_reference WHERE object_id=?", undef, ($object_id));
    $DB->do("DELETE FROM object_tag WHERE object_id=?", undef, ($object_id));
    $DB->do("DELETE FROM object WHERE id=?", undef, ($object_id));
    return;
}
