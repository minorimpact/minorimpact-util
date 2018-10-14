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
    -f, --force           Never request conformation.
    -h, --help            Usage information.
    -i, --id=ID           ID of the object you want to take action on.
    -p, --password=PASSWORD
                          Connect with PASSWORD.  Will prompt if not specified.
    -u, --user=USER       Connect as USER.  default: $ENV{USER}
    -v, --verbose         Verbose output.

    List options:
    -t, --type_id=TYPE    Object is TYPE.
