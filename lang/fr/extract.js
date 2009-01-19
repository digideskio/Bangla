
var page = new Page( nextPage() );

//For each function of this word
for each ( var word in page.words ){
    if( !( /fr/.test(word.lang) )  ){continue;}
    if( ( /fro/.test(word.lang) )  ){continue;}
    if( /^(Wiki|Wikt|Annex|Mod.le|PAGENAME|Aide|sans bo.tes d.roulantes)/.test(word.word) ){continue;}
    if( ! /\w/.test(word.word) || ! /\w/.test(word.type) ){
        say("#Skipping : " + word.word + " -> " + word.type );
        continue;
    }
    //Extract properties for this word's function

    //Gender and number
    word = genderNumber( word );

    //We do verb flexions ourself since wiktionnary don't have all of them
    if( word.type == "flex-verb" ){ continue; }
    //Verb flexions
    if( word.type == "verb" ){
        addVerbFlexions( word );
        continue;
    }

    wordAdd(word);
}

function genderNumber( word ){

    for each ( var Line in word.content.split( /\n/g  ) ){
        if(/({{msing(\|.*?)*}}|# Masculin singulier|{{fr-accord-(.*?))/gi.test(Line)){word.gender="m";word.number="s";}
        if( /({{fsing(\|.*?)*}}|# F.minin singulier)/gi.test(Line)  ){ word.gender = "f"; word.number = "s"; }
        if( /({{mp(l*)(\|.*?)*}}|# Masculin Pluriel)/gi.test(Line)  ){ word.gender = "m"; word.number = "p"; }
        if( /({{fp(l*)(\|.*?)*}}|# F.minin Pluriel)/gi.test(Line)   ){ word.gender = "f"; word.number = "p"; }
        if( /({{m(\|.*?)*}})/gi.test(Line)                          ){ word.gender = "m"; }
        if( /({{f(\|.*?)*}})/gi.test(Line)                          ){ word.gender = "f"; }
        if( /({{mf(\|.*?)*}})/gi.test(Line)                         ){ word.gender = "mf";}
        if( /({{p(\|.*?)*}}|# Pluriel d)/gi.test(Line)              ){ word.number = "p"; }
        if( /({{s(\|.*?)*}}|# Singulier d|{{fr\-r.g)/gi.test(Line)  ){ word.number = "s"; }
        if( /({{inv(\|.*?)*}})/gi.test(Line)                        ){ word.number = "inv"; }
    }

    return(word);

}


function addVerbFlexions( word ){
    //Add each flexion for this verb from 'verbiste'
    var flexions = system( "french-conjugator " + word.word );
    for each ( var Time in flexions.split( /(?=- .*?:)/gm ) ){
        var verbTime;
        var words = Time.split( /\n/g );
        for( var verbNumber = 0; verbNumber < words.length; verbNumber++ ){
            var flexion = words[verbNumber];
            if( verbNumber == 0 ){
                verbTime = flexion;
                verbTime = verbTime.replace(/\W/g,'');
            }else{
                if( flexion == "-" ){ continue; }
                var addWord = word;
                addWord.word = flexion;
                if( verbTime != "infinitivepresent" ){ addWord.type = "flex-verb"; }
                if( addWord.word == '' ){ continue; }
                addWord.verbTime = verbTime;
                switch( verbTime ){
                    case "participlepast"    : {
                        switch( verbNumber ){
                            case 1 : { addWord.gender = "m"; addWord.number = "s"; break; }
                            case 2 : { addWord.gender = "m"; addWord.number = "p"; break; }
                            case 3 : { addWord.gender = "f"; addWord.number = "s"; break; }
                            case 4 : { addWord.gender = "f"; addWord.number = "p"; break; }
                        }
                    }
                    case "infinitivepresent" : { break;}
                    default                  : { addWord.verbNumber = verbNumber; break; }
                }
                wordAdd( addWord );
            }
        }
    }

}

function Page( data ){
    this.data = data;
    this.words = new Array();
    for each( var item in data.content.split( /(?={{-((?:.*?)-(?:.*?))}})/mg ) ){
        if( match =  /^{{-(.+?)-\|(.+?)}}/mg.exec(item) ){
                var type = match[1];
                var lang = match[2];
                this.words.push( new Word( this.data , type , lang , item ) );
        }
    }
}

function Word( data , type , lang , item ){
    this.word        = data.word;
    this.idWordExt   = data.idWordExt;
    this.type        = type;
    this.lang        = lang;
    this.content     = item;

    //if word changes
    if( match =  /^{{-(.+?)-\|(.+?)}}\n\'\'\'(.+?)\'\'\'/mg.exec(item) ){
        this.word = match[3].replace(/([\[\]\(\)])/g,'');
    }
}




1;


