package App::MaildirToIMAP::Safe;

use strict;
use warnings;
use base 'App::MaildirToIMAP';
use File::Spec;

__PACKAGE__->mk_accessors(qw/
    imported_path
    imported_obj
/);

sub new {
    my $self = shift->SUPER::new(@_);

    # Default the imported path to be a subdirectory
    my $imported_path = File::Spec->join($self->maildir_path, 'Imported');
    my $imported_obj = $self->open_maildir($imported_path, 1);

    $self->imported_path($imported_path);
    $self->imported_obj($imported_obj);

    return $self;
}

sub message_imported {
    my ($self, $message) = @_;

    $message->moveTo($self->imported_obj);
}

1;
