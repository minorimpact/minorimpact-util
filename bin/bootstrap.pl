#!/usr/bin/perl

use strict;

use Data::Dumper;
use Cwd;
use Getopt::Long "HelpMessage";
use MinorImpact;

my $options = {
                help => sub { HelpMessage(); },
            };

Getopt::Long::Configure("bundling");
GetOptions( $options,
            "config|c=s",
            "debug|d",
            "help|?|h",
            "verbose|v",
        ) || HelpMessage();

eval { main(); };

if ($@) {
    die $@;
}

sub main {
    my $package = shift  @ARGV;

    MinorImpact::debug($options->{debug});
    if (0 && $package =~/^MinorImpact::/){
        #my $main = "MinorImpact.pm";
        #my $p = $package;
        #$p =~s/::/\//g;
        #$p = "$p.pm" unless ($p =~/\.pm$/);
        #(my $path = $INC{$main}) =~ s#/\Q$main\E$##g;
        #print "$path\n";

        # If the user is just trying to bootstrap a stock
        #   MinorImpact object, for some reseon, just 
        #   'use' it and hope for the the best.
        eval "use $package;";
        die $@ if ($@);
        eval $package ."::dbConfig()";
        die $@ if ($@);
        exit;
    } 
    
    if ($package =~/\.pm$/) {
        # User passed us a filename, so lets add the file's location to
        #   our path and try it that way.
        my $local_dir = getcwd;
        my $filename = $package;
        unless ($filename =~/^\//) {
            $filename = "$local_dir/$filename";
        }
        print "Reading $filename\n";
        die "Can't find $filename\n" unless (-f $filename);
        open(FILE, "<$filename");
        my $file_package;
        while (my $line = <FILE>){
            chomp($line);
            last if ( ($file_package) = $line =~/^package (.*);/);
        }
        close(FILE);
        die "Can't read package name from $package\n" unless ($file_package);
        my $package_path = $file_package;
        $package_path =~s/::/\//g;
        $package_path .= ".pm";
        my $lib_path = $filename;
        $lib_path =~s/\Q$package_path\E//g;
        $lib_path =~s/\/$//;
        eval "use lib qw($lib_path);";
        eval "use $file_package;";
        die ($@) if ($@);
        eval $file_package . "::dbConfig()";
        die ($@) if ($@);
        exit;

    } 
     
    # It might be in their path already, just try using it.
    print "Trying $package\n";
    eval "use $package;";
    unless ($@) {
        eval $package ."::dbConfig()";
        die $@ if ($@);
        exit;
    }
    print "$@\n";

    # User passed us a package name, but we've already tried all the
    #   paths we know about, let's try guessing.
    my @dir = ();
    my $local_dir = getcwd;
    push(@dir, $local_dir);
    push(@dir, "$local_dir/lib");
    foreach my $path (@dir) {
        my $p = $package;
        $p =~s/::/\//g;
        my $filename = "$path/$p.pm";
        if (-f $filename) {
            print "Trying $filename\n";
            eval "use lib qw($path);";
            eval "use $package;";
            eval $package ."::dbConfig()";
            unless ($@) {
                exit;
            }
            print "$@\n";
        }
    }

    print "no matching libraries found.\n";
}

=head1 NAME

bootstrap.pl - Registers new objects in the MinorImpact database.

=head1 SYNOPSIS

bootstrap.pl [options] OBJECT

  Options:
  -d, --debug           Turn debugging output on.
  -c, --config=FILE     Read connection information from FILE.
  -h, --help            Usage information.
  -u, --username=USER   Run as USER instead of $ENV{USER}.
  -v, --verbose         Verbose output.

OBJECT can be a package name or a path to a perl module.

=head1 DESCRIPTION

This script is used to register new objects in the MinorImpact database
prior to use, but it's simply a shortcut to executing the ::dbConfig()
subroutine from your own code.

=head1 AUTHOR

Patrick Gillan <pgillan@minorimpact.com>

=cut
