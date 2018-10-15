# NAME

bootstrap.pl - Registers new objects in the MinorImpact database.

# SYNOPSIS

bootstrap.pl \[options\] OBJECT

    Options:
    -d, --debug           Turn debugging output on.
    -c, --config=FILE     Read connection information from FILE.
    -h, --help            Usage information.
    -u, --username=USER   Run as USER instead of $ENV{USER}.
    -v, --verbose         Verbose output.

OBJECT can be a package name or a path to a perl module.

# DESCRIPTION

This script is used to register new objects in the MinorImpact database
prior to use, but it's simply a shortcut to executing the ::dbConfig()
subroutine from your own code.

# AUTHOR

Patrick Gillan <pgillan@minorimpact.com>
