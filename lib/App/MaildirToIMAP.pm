package App::MaildirToIMAP;

use strict;
use warnings;
use base 'Class::Accessor::Fast';
use DateTime::Format::Mail;
use DateTime::Format::RFC3501;
use Getopt::Long qw();
use Mail::Box::Maildir;
use Mail::Transport::IMAP4;  # for direct access to appendMessage

__PACKAGE__->mk_accessors(qw/
    imap_server
    imap_username
    imap_password
    imap_folder
    imap_obj
    maildir_path
    maildir_obj
    debug
/);

sub default_imap_server { 'imap.gmail.com' }
sub default_imap_folder { 'INBOX' }
sub default_debug { 0 }

sub new {
    my ($class, @args) = @_;

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
    ) or die $class->usage;

    die $class->usage if not $maildir_path;

    my $maildir_obj = $class->open_maildir($maildir_path);
    my $imap_obj = $class->open_imap($imap_server, $imap_username, $imap_password, $debug);

    my %self = (
        imap_server => $imap_server,
        imap_username => $imap_username,
        imap_password => $imap_password,
        imap_folder => $imap_folder,
        imap_obj => $imap_obj,
        maildir_path => $maildir_path,
        maildir_obj => $maildir_obj,
        debug => $debug,
    );

    bless \%self, $class;
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
    my ($class, $path, $create) = @_;

    return Mail::Box::Maildir->new(
        folder => $path,
        access => 'rw',
        create => $create,
    );
}

sub open_imap {
    my ($class, $server, $username, $password, $debug) = @_;

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

sub run {
    my ($self) = @_;

    my $num_imported = 0;
    my $num_skipped = 0;
    my $num_failed = 0;

    foreach my $message ($self->maildir_obj->messages) {
        print '.';

        if ($self->skip_message($message, $self->imap_username)) {
            $num_skipped++;
        }

        eval {
            $self->import_message($message);
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

sub skip_message {
    my ($self, $message, $username) = @_;

    my $skip_message = 0;

    my $delivered = $message->head->get('Delivered-To');
    if ($delivered and $delivered->unfoldedBody eq $username) {
        $skip_message = 1;
    }

    return $skip_message;
}

sub import_message {
    my ($self, $message) = @_;

    $self->upload_message($message);
    $self->message_imported($message);
}

sub format_date {
    my ($self, $date) = @_;

    my $dt = $self->parse_date($date);

    return DateTime::Format::RFC3501->format_datetime($dt);
}

sub parse_date {
    my ($self, $date) = @_;

    my $dt;
    eval {
        # Remove extra time zone information that some mail clients add
        $date =~ s/([-+]\d{4})\s+\(?[^)]+\)?$/$1/;

        # Add a leading zero to the hour if needed
        $date =~ s/(\d{4})\s+(\d:)/$1 0$2/;

        # Add seconds if needed
        $date =~ s/\s+(\d{2}:\d{2})\s+/ $1:00 /;

        $dt = DateTime::Format::Mail->parse_datetime($date);
        $dt->set_time_zone('GMT');
    };
    if ($@) {
        die "Could not parse [$date]";
    }

    return $dt;
}

sub upload_message {
    my ($self, $message) = @_;

    my $date = $self->format_date($message->head->get('Date'));

    $self->imap_obj->appendMessage(
        $message,
        $self->imap_folder,
        $date,
    ) or die "Error appending message: " . join(', ', $self->imap_obj->errors);
}

sub message_imported {
    # no-op by default
}

1;
