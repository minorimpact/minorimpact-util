# NAME

test\_user.pl - MinorImpact utility script for manipulating test users in a MinorImpact application.

# SYNOPSIS

test\_user.pl \[options\]

    Options:
    -a, --action=ACTION   Perform ACTION.  default: info
                          Actions:
                              info    Show information about the userdatabase in the
                                      application described by FILE.
                              delete  delete COUNT test users.
    -c, --config=FILE     Read connection information from FILE.
        --count=COUNT     Operate on COUNT number of test users.
    -f, --force           Never request conformation.
    -h, --help            Usage information.
    -u, --user=USER       Connect to MinorImpct as USER.  default: $ENV{USER}
    -v, --verbose         Verbose output.
