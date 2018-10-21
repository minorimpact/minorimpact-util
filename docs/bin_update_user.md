# NAME

edit\_user.pl - MinorImpact utility to update a a user

# SYNOPSIS

edit\_user.pl \[options\] EDIT\_USER

## Options

- -a, --admin yes/no

    Turn admin rights on or off for EDIT\_USER.

- -c, --config FILE

    Read connection information from FILE.

- -d, --debug

    Turn debugging output on.

- -e. --email EMAIL

    Set USER's email address top EMAIL.

- -h, --help 

    Usage information.

- -p, --password

    Prompt for a new password for EDIT\_USER.

- -u, --username USER

    Run as USER instead of $ENV{USER}.

- -v, --verbose

    Verbose output.

User updates can only be performed by THE USER THEMSELVES or AN ADMIN USER.  If 
you're not running this to make changes to your own user, and you're not
an admin, then you have to run the script as an admin user user by invoking
the "--username" option.  

Examples

Use the configuration in /etc/minorimpact.conf to turn on admin
rights for user 'foo'

    edit_user.pl -c /etc/minorimpact.conf -a yes foo

Turn off admin rights for user 'foo', but log into MinorImpact
as the 'admin' user instead of yourself.

    edit_user.pl -a no -u admin foo
