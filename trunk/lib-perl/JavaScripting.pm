package JavaScripting;

use strict; 
use warnings;
use JavaScript;
use Test::More;
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
    my $params = pop;

    $self->{script} = $params->{script};
    $self->{rt} = JavaScript::Runtime->new();
    $self->{js} = $self->{rt}->create_context();

    $self->{js}->bind_function( 'say'         => sub { print @_,"\n"; } );
    $self->{js}->bind_function( 'system'      => sub { my $cmd = join(" " , @_); return `$cmd`; } );
    $self->{js}->bind_function( 'plan'        => sub { plan tests => $_[0]; } );
    $self->{js}->bind_function( 'ok'          => sub { ok($_[0],$_[1]);   } );
    $self->{js}->bind_function( 'skip'        => sub { SKIP:{ skip($_[2],1); }  } );
    $self->{js}->bind_function( 'is'          => sub { is($_[0],$_[1],$_[2]);   } );
    $self->{js}->bind_function( 'isnt'        => sub { isnt($_[0],$_[1],$_[2]); } );

    $self->{error} = undef;

    while ( my ($name, $function) = each %{$params->{functions}}) {
        $self->{js}->bind_function( $name => $function );
    }

    bless($self);
    return $self;
}

sub run{
    my $self = shift;
    $self->{error} = undef;
    my $result;
    $result = $self->{js}->eval( $self->{script} ) ;
    $self->{error} = $@ unless $result;
    return $result;
}




1;
