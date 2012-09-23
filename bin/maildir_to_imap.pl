#!/usr/bin/env perl

use strict;
use warnings;

$|++;

my $option = '--safe';
my @args = @ARGV;

my $class = 'App::MaildirToIMAP';
if (grep { $_ eq $option } @args) {
    $class = 'App::MaildirToIMAP::Safe';

    # Remove the option since scripts don't need to parse it
    @args = grep { $_ ne $option } @args;
}

eval "require $class";
$class->new(@args)->run;
