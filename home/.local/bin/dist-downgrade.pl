#!/usr/bin/perl
use strict;

use Data::Dumper;

my $status = {};
my $available = {};

open(STATUS, "/var/lib/dpkg/status");

parse_dpkg(*STATUS{IO}, $status);
close(STATUS);

my @files = split(/\s+/, `ls /var/lib/apt/lists/*_Packages`);

my $file;
foreach $file (@files) {
    open(AVAILABLE, $file);
    parse_dpkg(*AVAILABLE{IO}, $available);
    close AVAILABLE;
}

my @args = ("apt-get", "-t", "wily", "-f", "install");
my $key;
foreach $key (sort(keys %$status)) {
    if($available->{$key}
       and $status->{$key}->{"Version"}
       and $status->{$key}->{"Version"} ne $available->{$key}->{"Version"}) {
        push(@args, "$key=" . $available->{$key}->{"Version"} );
    }
}

print Dumper(\@args);

#system(@args);

sub parse_dpkg {
    my $fh = shift;
    my $hash = shift;

    my $curhash = {};

    my $line = "";

    my $go = 1;

    while($go) {
        ($_ = <$fh>) or $go = 0;

        /^\s*$/ and do {
            $line =~ /([^:]*):\s*(.*?)\s*$/s;
            $curhash->{$1} = $2;
            $line = "";

            if(!defined($hash->{$curhash->{"Package"}})
               or compare_version($hash->{$curhash->{"Package"}}->{"Version"},
                                  $curhash->{"Version"}) < 0) {
                $hash->{$curhash->{"Package"}} = $curhash;
            }
            $curhash = {};
            next;
        };

        /^(\s+.*)$/ and do {
            $line .= $1;
            next;
        };

        if($line) {
            $line =~ /([^:]*):\s*(.*?)\s*$/s;
            $curhash->{$1} = $2;
            $line = "";
        }

        $line = $_;
    }
}

sub compare_version {
    my $ver1 = shift;
    my $ver2 = shift;
    my $dbg = shift;

    my $ver1_epoch = 0;
    my $ver2_epoch = 0;

    my $ver1_uvers = '';
    my $ver2_uvers = '';

    $ver1 =~ s/^([^:]*):// and $ver1_epoch = $1;
    $ver2 =~ s/^([^:]*):// and $ver2_epoch = $1;

    $ver1 =~ s/-([^-]*)$// and $ver1_uvers = $1;
    $ver2 =~ s/-([^-]*)$// and $ver2_uvers = $1;

    if($ver1_epoch != $ver2_epoch) {
        if($dbg) {
            print "Difference of epochs: " . $ver1_epoch . " vs. " . $ver2_epoch . "\n";
            print "returning " . ($ver1_epoch <=> $ver2_epoch);
        }
        return $ver1_epoch <=> $ver2_epoch;
    }

    if($ver1 eq $ver2) {
        if($dbg) {
            print "Identical versions: " . $ver1 . " vs. " . $ver2 . "\n";
        }
        $ver1 = $ver1_uvers;
        $ver2 = $ver2_uvers;
    }

    if($ver1 eq $ver2) {
        if($dbg) {
            print "Identical uversions: " . $ver1 . " vs. " . $ver2 . "\n";
            print "Returning 0";
        }
        return 0;
    }

    my $digit = 0;

    while($ver1 or $ver2) {
        if($digit) {
            my $n1 = 0;
            my $n2 = 0;

            $ver1 =~ s/^([0-9]+)// and $n1 = $1;
            $ver2 =~ s/^([0-9]+)// and $n2 = $1;

            if($dbg) {
                print "Comparing $n1 with $n2...\n";
            }

            if($n1 != $n2) {
                if($dbg) {
                    print "returning " . ($n1 <=> $n2) . "\n";
                }
                return $n1 <=> $n2;
            }
            $digit = 0;

            $ver1 =~ s/^\.(?=[0-9]+)// and $digit = 1;
            $ver2 =~ s/^\.(?=[0-9]+)// and $digit = 1;
        } else {
            my $s1 = "";
            my $s2 = "";

            $ver1 =~ s/^([^0-9]+)// and $s1 = $1;
            $ver2 =~ s/^([^0-9]+)// and $s2 = $1;

            if($dbg) {
                print "Comparing $s1 with $s2...\n";
            }

            for(my $i = 0; $i < length($s1) or $i < length($s2); $i++) {
                my $c1 = "";
                my $c2 = "";

                $i < length($s1) and $c1 = substr($s1, $i, 1);
                $i < length($s2) and $c2 = substr($s2, $i, 1);

                if($c1 eq $c2) {
                    next;
                }

                if($c1 eq "~") {
                    if($dbg) {
                        print "returning 1\n";
                    }
                    return 1;
                }

                if($c2 eq "~") {
                    if($dbg) {
                        print "returning -1\n";
                    }
                    return -1;
                }

                if($c1 eq "") {
                    if($dbg) {
                        print "returning -1\n";
                    }
                    return -1;
                }

                if($c2 eq "") {
                    if($dbg) {
                        print "returning 1\n";
                    }
                    return 1;
                }

                if($c1 =~ /^[a-zA-Z]$/) {
                    if($c2 !~ /^[a-zA-Z]$/) {
                        if($dbg) {
                            print "returning 1\n";
                        }
                        return 1;
                    }
                } elsif($c2 =~ /^[a-zA-Z]$/) {
                    return -1;
                    if($dbg) {
                        print "returning -1\n";
                    }
                }

                return $c1 cmp $c2;
            }
            $digit = 1;
        }
    }
}
