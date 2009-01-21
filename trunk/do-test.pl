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

binmode(STDOUT, ':utf8');

my $script = slurp("lang/fr/t/00-basic.js");

my $gram = LinkGrammar->new();

my $js = JavaScripting->new({
    functions => {
        'getSentence' => sub { my $sent = join(" " , @_); return to_json($gram->getSentence($sent)); }
    },
    script    => $script
});

#Now call the javascript to extract word information from the base
print "JSError : " ,$js->{error}, "\n" unless ( $js->run() );





