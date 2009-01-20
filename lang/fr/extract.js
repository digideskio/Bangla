
#include lang/fr/lib/extract.Page.class.js
#include lang/fr/lib/extract.Word.class.js

var page = new Page( nextPage() );

//For each function of this word
for each ( var word in page.words ){

    //Skip bad words
    if( !word.isValid() ){ continue; }

    //Extract properties for this word's function
    //Gender and number
    word.genderNumber();

    //We do verb flexions ourself since wiktionnary don't have all of them
    if( word.type == "flex-verb" ){ continue; }

    //Verb flexions
    if( word.type == "verb" ){
        word.addVerbFlexions();
        continue;
    }

    //Finally add to database
    wordAdd(word);

}



1;


