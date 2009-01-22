#!/usr/bin/perl
use strict;
use XML::Twig;
use utf8;
use Unicode::String;
use JavaScript;
use Slurp;
use JSON;
use Encode qw/encode decode/;
use lib 'lib-perl';
use LinkGrammar;
use Test::More;
use JavaScripting;
use Config::General;

my %conf = new Config::General("config.cfg")->getall;

binmode(STDOUT, ':utf8');

my $gram = LinkGrammar->new(\%conf);

my $script = slurp( $ARGV[0] );

my $js = JavaScripting->new({
    functions => {
        'getSentence' => sub { my $sent = join(" " , @_); return to_json($gram->getSentence($sent)); }
    },
    script    => $script
});

#Now call the javascript to extract word information from the base
print "JSError : " ,$js->{error}, "\n" unless ( $js->run() );




