#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 2;

BEGIN {
    use_ok('App::MaildirToIMAP');
    use_ok('App::MaildirToIMAP::Safe');
}
