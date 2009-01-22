package LinkGrammar;

use strict;
use IPC::Open3;
use IO::Select;
use Data::Dumper;
use JSON;
use Expect;
use Exporter;
use utf8;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = ();
@EXPORT_OK   = qw(getSentence);
%EXPORT_TAGS = ( DEFAULT => [qw(&getSentence)] );

sub new{
    my $self  = {};

    my $conf = pop;

    $self->{exp} = new Expect;
    $self->{exp}->log_stdout(0);
    $self->{exp}->spawn($conf->{'link-grammar-executable'},$conf->{'link-grammar-dictionnary'}) or die "Cannot spawn : $!\n";
    $self->{exp}->send("!links\n!postscript\n");

    bless($self);
    return $self;
}


sub getSentence{

    my ( $self , $sentence ) = @_;

    $self->{exp}->send("$sentence\n");
    my @linkages;
    my $long=2;
    $self->{exp}->expect("5",
               [ qr/(linkparser>)/ =>
                     sub { my $exp = shift;
                           my $before = $self->{exp}->before();
                           #sleep 1;
                           if( @linkages < $long ){
                               push( @linkages , $before ) if $before =~ m/cost vector/g;
                               #print "linkage : " . scalar(@linkages) . " < long : $long -> $before\n";
                               if ( $before =~ m/Found (.*?) linkage.*? \((.*?) had no/ ) {
                                   $long = $2;
                               }
                               $self->{exp}->send("\n");
                               return(exp_continue);
                           }else {
                               #print "Finished\n";                   
                           }
                           
                     }
              ],
    );

    my @retour;

    for (@linkages) {
        my $text = $_;
        #Extract data from postscript output
        #$text =~ m/\[\((.*?)\)\]\n\[\[(.*?)\]\]\n\[(.*?)\]/gms ;
        $text =~ m/\[\((.*?)\)\]\s*\n\s*\[\[(.*?)\]\]/gms ;
        my ( $wordsline , $linksline ) = ( $1 , $2 );
        my @words = split('\)\(',$wordsline);
        my @links = split('\]\[',$linksline);
        #print join(",",@words),"\n";
        #print join(",",@links),"\n";
        my @link;
        for (@links) {
            my @elems = split(" ",$_);
            $elems[3] =~ s/[\(\)]//g;
            push(@link,{left => $elems[0] , right => $elems[1] , 'length' => $elems[2] , 'link' => $elems[3] });
        }
        my @all;
        my $c = 0;
        for (@words) {
            my $word = $_;
            $word =~ m/(.*)\.(.*)/g;
            my ( $word , $type ) = ( $1 , $2 );

            #Get all links for this word;
            my @alllink;
            for ( @link ) {
                my $link = $_;
                push( @alllink , $link ) if( $link->{'left'} == $c or $link->{'right'} == $c );
            }
            push( @all , { word => $word , type => $type , links => \@alllink } );
            $c++;
        } 
        push @retour , { 'sentence' => $sentence , 'words' => \@all };
    }
    return \@retour;

}


1;
