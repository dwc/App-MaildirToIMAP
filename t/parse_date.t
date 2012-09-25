#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

BEGIN { use_ok('App::MaildirToIMAP'); }

my $class = 'App::MaildirToIMAP';

{
    my $dt = $class->parse_date('Thu, 29 Mar 2012 15:50:02 +0000');

    isa_ok($dt, 'DateTime');
    is($dt->year, 2012, 'year matches');
    is($dt->month, 3, 'month matches');
    is($dt->day, 29, 'day matches');
    is($dt->hour, 15, 'hour matches');
    is($dt->minute, 50, 'minute matches');
    is($dt->second, 2, 'second matches');
}

{
    my $dt = $class->parse_date('Thu, 29 Mar 2012 15:22:42 -0400');

    isa_ok($dt, 'DateTime');
    is($dt->year, 2012, 'year matches');
    is($dt->month, 3, 'month matches');
    is($dt->day, 29, 'day matches');
    is($dt->hour, 19, 'hour matches');
    is($dt->minute, 22, 'minute matches');
    is($dt->second, 42, 'second matches');
}

{
    my $dt = $class->parse_date('Thu, 7 Sep 2006 8:19:27 -0400');

    isa_ok($dt, 'DateTime');
    is($dt->year, 2006, 'year matches');
    is($dt->month, 9, 'month matches');
    is($dt->day, 7, 'day matches');
    is($dt->hour, 12, 'hour matches');
    is($dt->minute, 19, 'minute matches');
    is($dt->second, 27, 'second matches');
}

{
    my $dt = $class->parse_date('Thu, 14 Sep 2006 17:50:32 +0000 GMT');

    isa_ok($dt, 'DateTime');
    is($dt->year, 2006, 'year matches');
    is($dt->month, 9, 'month matches');
    is($dt->day, 14, 'day matches');
    is($dt->hour, 17, 'hour matches');
    is($dt->minute, 50, 'minute matches');
    is($dt->second, 32, 'second matches');
}

{
    my $dt = $class->parse_date('Thu, 9 Jan 2003 13:16:47 -0500 (EST)');

    isa_ok($dt, 'DateTime');
    is($dt->year, 2003, 'year matches');
    is($dt->month, 1, 'month matches');
    is($dt->day, 9, 'day matches');
    is($dt->hour, 18, 'hour matches');
    is($dt->minute, 16, 'minute matches');
    is($dt->second, 47, 'second matches');
}

{
    my $dt = $class->parse_date('Fri, 20 Aug 2004 07:57 -0400');

    isa_ok($dt, 'DateTime');
    is($dt->year, 2004, 'year matches');
    is($dt->month, 8, 'month matches');
    is($dt->day, 20, 'day matches');
    is($dt->hour, 11, 'hour matches');
    is($dt->minute, 57, 'minute matches');
    is($dt->second, 0, 'second matches');
}

done_testing();
