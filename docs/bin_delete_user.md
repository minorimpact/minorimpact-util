# NAME

delete\_user.pl - Deletes a MinorImpact user and all owned objects.

# SYNOPSIS

delete\_user.pl \[options\] DEL\_USER

    Options:
    -a, --admin           Set 'admin' as true for the new user.
    -c, --config=FILE     Read connection information from FILE.
    -d, --debug           Turn debugging output on.
    -h, --help            Usage information.
    -u, --username=USER   Run as USER instead of $ENV{USER}.
    -v, --verbose         Verbose output.

# DESCRIPTION

Deletes the user and all objects owned by that user.  Can only be run by an 'admin' user.
