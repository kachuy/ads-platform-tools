#!/usr/bin/perl

use strict;
use warnings;
use Digest::SHA qw(sha256_hex);
use File::Basename;

our $debug = 1;

# MAIN
{
    my ($type, $file) = @ARGV;

    unless ($file && -e $file) {
        die "File missing or does not exist\n";
    }

    unless ($type && $type =~ /^[A-Za-z]+$/) {
        die "Type is required\n";
    } else {
        $type = uc($type);
    }

    my ($file_name, $file_path, $file_suffix) = fileparse($file, qr/\.(txt|csv)/);

    unless ($file_suffix) {
        die "Invalid file type. Must be .txt or .csv, but got \"$file_suffix\"\n";
    }

    my $output_file;
    if ($file_name && $file_path && $file_suffix) {
        $output_file = $file_path . $file_name . "_hashed_$$" . $file_suffix;
    } else {
        die "Cannot format output file name\n";
    }

   my $flags = {};

    if ($type eq 'MOBILEDEVICEID') {
        # mobile device IDs can be a mixture of IDFA, ADID and ANDROID in a single file
        $flags->{'regex'} = qr/^[a-z0-9][a-z0-9\-]+[a-z0-9]$/;
    } elsif ($type eq 'IDFA') {
        $flags->{'regex'} = qr/^[a-z0-9][a-z0-9\-]+[a-z0-9]$/;
        # $flags->{'uppercase'} = 1;

    } elsif ($type eq 'ADID') {
        $flags->{'regex'} = qr/^[a-z0-9][a-z0-9\-]+[a-z0-9]$/;

    } elsif ($type eq 'ANDROID') {
        $flags->{'regex'} = qr/^[a-z0-9]+$/;

    } elsif ($type eq 'EMAIL') {
        $flags->{'regex'} = qr/^[a-z0-9][a-z0-9_\-\.\+]+\@[a-z0-9][a-z0-9\.]+[a-z]$/;

    } elsif ($type eq 'PHONE' || $type eq 'TWITTERID') {
        $flags->{'regex'} = qr/^\d+$/;
        $flags->{'dropleadingzeros'} = 1;

    } elsif ($type eq 'TWITTERSCREENNAME') {
        $flags->{'regex'} = qr/^[a-z0-9_]+$/;
        $flags->{'dropleadingat'} = 1;

    } else {
        die "Unknown type\n";
    }

    unless (open(INPUT, "<$file")) {
        die "Cannot open input file $file\n";
    }

    unless (open(OUTPUT, ">$output_file")) {
        die "Cannot open output file\n";
    }

    my $skipped = 0;
    my $written = 0;

    while (my $line = <INPUT>) {
        chomp($line);
        $line =~ s/\s//g;

        # Set case
        $line = $flags->{'uppercase'} ? uc($line) : lc($line);
        # Drop leading '@'
        $line =~ s/^\@// if ($flags->{'dropleadingat'});
        # Drop leading zeros
        $line =~ s/^0+// if ($flags->{'dropleadingzeros'});

        unless ($line =~ /$flags->{'regex'}/) {
            $skipped++;
            next;
        }

        if ($debug) {
            print "\t";
            print $line;
            print "\n";
        }
        print OUTPUT sha256_hex($line);
        print OUTPUT "\n";
        $written++;
    }

    close(INPUT);
    close(OUTPUT);

    print "Written:\t$written\n";
    print "Skipped:\t$skipped\n";
    exit;
}
