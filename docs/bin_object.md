# NAME

object.pl - Command line tool for viewing and editing MinorImpact object databases.

# SYNOPSIS

object.pl \[options\]

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
