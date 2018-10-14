# NAME

type.pl - Command line tool for viewing and editing MinorImpact object types.

# SYNOPSIS

type.pl \[options\]

    Options:
    -a, --action=ACTION   Perform ACTION.  default: list
                          Actions:
                              addtype     Create a new TYPE.
                              addfield    Add a new field FIELDNAME to TYPE. See "Field options" below.
                              bootstrap   Run MODULE::dbConfig().  Useful for adding the first object
                                          to an application.
                              delfield    Delete field FIELDNAME from TYPE.
                              info        Show information about TYPE.
                              list        show all types.
        --addfield        Equivilant to --action=addfield.
    -c, --config=CONFIG   Read connection information from CONFIG.
    -f, --force           Never request conformation.
    -h, --help            Usage information.
    -m, --module=MODULE   With the bootstrap ACTION, will run MODULE::dbConfig().  If MODULE
                          is not a ".pm" filename, we'll try looking in the $lib_directory option
                          defined in CONFIG for MODULE.pm.
    -p, --password=PASSWORD
                          Connect with PASSWORD.  Will prompt if not specified.
        --system          TYPE will considered a 'system' object.
    -t, --type=TYPE       Work with TYPE object definition.
    -u, --user=USER       Connect as USER.  default: $ENV{USER}
    -v, --verbose         Verbose output.

    Type options:
        --plural          The plural form of TYPE.

    Field options:
        --field-name=FIELDNAME
                          Field name.
        --field-description=DESCRIPTIOn
                          Field description.
        --field-type=FIELDTYPE
                          Field type.

      The following options are true/false:
        --field-hidden    field will show up on forms.
        --field-required  field is required.
        --field-readonly  field is viewable, but not user editable.
        --field-sortby    When sorting lists, use this field.
