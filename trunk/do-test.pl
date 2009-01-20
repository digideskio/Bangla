#!/usr/bin/perl
use strict;
use XML::Twig;
use utf8;
use Unicode::String;
use Parse::MediaWikiDump;
use Switch;
use signatures;
use JavaScript;
use Slurp;
use JSON;
use Encode qw/encode decode/;
use Data::Dumper;
use Grammar qw(getSentence);
use Test::More;

binmode(STDOUT, ':utf8');

my $rt = JavaScript::Runtime->new();
my $script = slurp "lang/fr/t/00-basic.js";
my $js = $rt->create_context();

$js->bind_function( 'say'         => sub { print @_,"\n"; } );
$js->bind_function( 'system'      => sub { my $cmd = join(" " , @_); return `$cmd`; } );
$js->bind_function( 'getSentence' => sub { my $sent = join(" " , @_); return to_json(getSentence($sent)); } );
$js->bind_function( 'plan'        => sub { plan tests => $_[0]; } );
$js->bind_function( 'ok'          => sub { ok($_[0],$_[1]);   } );
$js->bind_function( 'is'          => sub { is($_[0],$_[1],$_[2]);   } );
$js->bind_function( 'isnt'        => sub { isnt($_[0],$_[1],$_[2]); } );

#Now call the javascript to extract word information from the base
print "JSError : " , $@, "\n" unless ( $js->eval( $script ) );





