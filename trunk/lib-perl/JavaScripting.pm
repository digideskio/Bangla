package JavaScripting;

use strict; 
use warnings;
use JavaScript;
use Exporter;
use utf8;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = ();
@EXPORT_OK   = qw();
%EXPORT_TAGS = ( DEFAULT => [qw()] );



sub new{
    my $self  = {};

    $self->{rt} = JavaScript::Runtime->new();
    $self->{js} = $self->{rt}->create_context();

    bless($self);
    return $self;
}



1;
