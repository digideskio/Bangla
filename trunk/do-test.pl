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

binmode(STDOUT, ':utf8');

#Lines
my %outputs;

my $rt = JavaScript::Runtime->new();
my $script = slurp "lang/fr/test.js";
my $js = $rt->create_context();

$js->bind_function( 'say'         => sub { print @_,"\n"; } );
$js->bind_function( 'system'      => sub { my $cmd = join(" " , @_); return `$cmd`; } );

#Now call the javascript to extract word information from the base
print "JSError : " , $@, "\n" unless ( $js->eval( $script ) );




