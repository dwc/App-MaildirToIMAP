#!/usr/bin/env perl

use strict;
use warnings;
use ExtUtils::MakeMaker 6.56;

WriteMakefile(
    NAME => 'App-MaildirToIMAP',
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'DateTime::Format::Mail' => 0,
        'DateTime::Format::RFC3501' => 0,
        'Getopt::Long' => 0,
        'Mail::Box::Maildir' => 0,
        'Mail::Transport::IMAP4' => 0,
    },
    EXE_FILES => [ glob("bin/*") ],
);
