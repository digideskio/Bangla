#!/usr/bin/perl
use strict;
use XML::Twig;
use utf8;
use Unicode::String;
use Parse::MediaWikiDump;
use Mysql;
use Switch;
use signatures;
use JavaScript;
use Slurp;
use JSON;
use Encode qw/encode decode/;
use Data::Dumper;

#Connect to Mysql
mysqlcon '#p:localhost:piki:root:magda';

binmode(STDOUT, ':utf8');



my @words = r "SELECT count(*) as compte, luthorword.* FROM luthorword GROUP BY word,type ORDER BY idWordExt ASC LIMIT 300000";

#Lines
my %outputs;

my $rt = JavaScript::Runtime->new();
my $script = slurp "lang/fr/links.js";
my $js = $rt->create_context();

$js->bind_function( say           => sub { print @_,"\n"; } );
$js->bind_function( getWord       => sub { return shift @words; } );
$js->bind_function( getFunc       => sub { my ( $word, $type ) = @_; my @ret = r("SELECT * FROM luthorword WHERE word = ? AND type = ? " , $word , $type ); return(\@ret); } );
$js->bind_function( sayWord       => sub { my ( $word ) = @_; printf "%-9.9s | %-9.9s | %-25.25s | %-10.10s | %-10.10s | %-2.2s | %-1.1s | %-25.25s | %-2.2s \n",, $word->{idWordExt} ,$word->{word} ,$word->{type} ,, $word->{gender} , $word->{number} , $word->{'verb-number'} ,$word->{'verb-time'}; } );
$js->bind_function( addWord       => sub { my ( $word , $link ) = @_; print "$word : $link ;\n" ; if( !exists($outputs{$link}) ){ $outputs{$link} = []; }; push( @{$outputs{$link}} , $word ) } );
$js->bind_function( 'system'      => sub { my $cmd = join(" " , @_); return `$cmd`; } );

#Now call the javascript to extract word information from the base
my $script =  $script ;
while ( @words > 0 ) {
    print "JSError : " , $@, "\n" unless ( $js->eval( $script ) );
}

#Outputs data to file

open( DICT , ">4.0.dict" );
binmode(DICT, ':utf8');
print DICT "CAPITALIZED-WORDS: J- or O- or (S+ & (({\@CO-} & {C-}) or R-)) or SI-;\nANDABLE-CONNECTORS: S+ & S- & A+ & A- & MV+ & MV- & D- & O+ & O- &\nJ+ & J- & C-;\n\n\n";
print DICT "\n\n\n\n\n";
while (my ($link, $words) = each %outputs ) {
    print DICT join(" , ", @{$words} ) , " : \n " , $link , " ;\n\n";
}
close( DICT );




