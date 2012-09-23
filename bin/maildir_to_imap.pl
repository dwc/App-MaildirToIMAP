#!/usr/bin/env perl

use strict;
use warnings;
use App::MaildirToIMAP;

$|++;

App::MaildirToIMAP->new(@ARGV)->run;
