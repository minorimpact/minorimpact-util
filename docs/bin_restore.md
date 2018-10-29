# NAME

restore.pl - Restore a MinorImpact application.

# SYNOPSIS

restore.pl \[options\]

## Options

- -c, --config=FILE

    Read connection information from FILE.

    Default: /etc/minorimpact.conf

- -d, --debug

    Turn on debug logs.

- -f, --force

    Do not prompt for confirmation before wiping out the existing database.

- -h, --help

    Usage information.

- -i, --input\_file=FILE

    Read data from FILE.

    Required.

- -u, --username=USER

    Connect as USER.  

    Default: $ENV{USER}

- -v, --verbose 

    Verbose output.

# AUTHOR

Patrick Gillan <pgillan@minorimpact.com>
