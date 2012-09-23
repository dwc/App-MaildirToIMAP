package App::MaildirToIMAP;

use strict;
use warnings;
use DateTime::Format::Mail;
use DateTime::Format::RFC3501;
use Getopt::Long qw();
use Mail::Box::Maildir;
use Mail::Transport::IMAP4;  # for direct access to appendMessage

sub default_imap_server { 'imap.gmail.com' }
sub default_imap_folder { 'INBOX' }
sub default_debug { 0 }

sub run {
    my (@args) = @_;

    my $imap_server = default_imap_server();
    my $imap_username;
    my $imap_password;
    my $imap_folder = default_imap_folder();
    my $maildir_path;
    my $debug = default_debug();

    Getopt::Long::GetOptionsFromArray(
        \@args,
        'server|s=s' => \$imap_server,
        'username|u=s' => \$imap_username,
        'password|p=s' => \$imap_password,
        'folder|f=s' => \$imap_folder,
        'maildir|m=s' => \$maildir_path,
        'debug|d!' => \$debug,
    ) or die usage();

    die usage() if not $maildir_path;

    my $maildir = open_maildir($maildir_path);
    my $imap = open_imap($imap_server, $imap_username, $imap_password, $debug);

    my $num_imported = 0;
    my $num_skipped = 0;
    my $num_failed = 0;

    foreach my $message ($maildir->messages) {
        print '.';

        if (skip_message($message, $imap_username)) {
            $num_skipped++;
        }

        eval {
            my $dt = parse_date($message->head->get('Date'));
            my $date = DateTime::Format::RFC3501->format_datetime($dt);

            $imap->appendMessage(
                $message,
                $imap_folder,
                $date,
            );

            $num_imported++;
        };
        if ($@) {
            warn "Failed to import message: $@";
            $num_failed++;
        }

        sleep 1;
    }

    print "\n";
    print "Imported: $num_imported\n";
    print "Skipped: $num_skipped\n";
    print "Failed: $num_failed\n";
}

sub usage {
    return join(' ',
        $0,
        qq[--server <imap hostname>],
        qq[--username <imap username>],
        qq[--password <imap password>],
        qq[--folder <imap folder>],
        qq[--maildir <path to maildir>],
    ) . "\n";
}

sub open_maildir {
    return Mail::Box::Maildir->new(folder => $_[0]);
}

sub open_imap {
    my ($server, $username, $password, $debug) = @_;

    my $client = Mail::IMAPClient->new(
        Server => $server,
        User => $username,
        Password => $password,
        Ssl => 1,
        Uid => 1,
        Debug => $debug,
    );

    return Mail::Transport::IMAP4->new(imap_client => $client);

}

sub skip_message {
    my ($message, $username) = @_;

    my $skip_message = 0;

    my $delivered = $message->head->get('Delivered-To');
    if ($delivered and $delivered->unfoldedBody eq $username) {
        $skip_message = 1;
    }

    return $skip_message;
}

sub parse_date {
    my ($date) = @_;

    my $dt;
    eval {
        # Remove extra time zone information that some mail clients add
        $date =~ s/([-+]\d{4})\s+\(?[^)]+\)?$/$1/;

        # Add a leading zero to the hour if needed
        $date =~ s/(\d{4})\s+(\d:)/$1 0$2/;

        $dt = DateTime::Format::Mail->parse_datetime($date);
        $dt->set_time_zone('GMT');
    };
    if ($@) {
        die "Could not parse [$date]";
    }

    return $dt;
}

1;
