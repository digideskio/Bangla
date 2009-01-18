var word = getWord();

word.links = new Array();
word.functions = getFunc( word.word, word.type );
word.funcs = new Array();

while( func = word.functions.pop() ){

    var type = word.type.replace(/[^\w\-]/g,'');
    if( type == "flex-art-df" ){ type = "art-df"; word.type = word.type.replace(/flex-/g,''); }
    if( type == "flex-nom" ){ type = "nom"; word.type = word.type.replace(/flex-/g,''); }
    if( type == "flex-adj" ){ type = "adj"; word.type = word.type.replace(/flex-/g,''); }
    func.variables = {};
    func.links = new Array();
    func.variables.genNum = getGenNum( func );

    switch( type ){

        case "nom": {
            func.links.push(" {+@A:genNum:} , +D:genNum: , {@A:genNum:+} , S:genNum:+   # As a Subject to a Verb");
            func.links.push(" {+@A:genNum:} , +D:genNum: , {@A:genNum:+} , +O:genNum:   # As an Object to a Verb");
            break;
        }

        case "art-df" : {
            func.links.push(" D:genNum:+                       # Article défini");
            break;
        }

        case "adj" : {
            func.links.push(" A:genNum:+ or +A:genNum:         # Article défini");
            break;
        }

        case "flex-verb": {
            func.links.push(" +S:genNum:                     # Subject Verb" +
                            "                                # Basic sentence ");
            func.links.push(" +S:genNum: , O:genNum:+        # Subject Verb Object");
            break;
        }

    }

    word.funcs.push( func );
}

toGSyntax(word);

function toGSyntax(word){
    //Convert an xml word to LG syntax
    var links = new Array();
    for each ( var func in word.funcs ){
        for each ( var link in func.links ){
            for( var variable in func.variables ){
                var regex = new RegExp("\:" + variable + "\:" , "gmi" );
                link = link.replace( regex , func.variables[variable] );
            }
            var line = link.replace(",","&","g").replace(/\+([\w\*\@]+)/g,"$1-").replace(/#.*(\n|$)(\s*)/mg,'').replace(/\s+/gm,' ');

            links.push( "(" + line + ")" );
        }
    }

    //TODO : Enlever les doublons

    if( links.length == 0 ){ return; }
    if( /PAGENAME/.test(word.word) ){ return; }
    addWord( word.word + "." + word.type , links.join(" or " ) );

}

function getGenNum( func ){
    //Get Gender and Number suffix for link names
    var gender = "";
    var number = "";

    switch( func.gender ){
        case "m"   : { gender = "m"; break; }
        case "f"   : { gender = "f" ; break; }
        case "mf"  : { gender = "";     break; }
    }
    switch( func.number ){
        case "s"   : { number = "s";  break; }
        case "p"   : { number = "p";  break; }
    }

    if( func.type == "flex-verb" && func.verbTime != "participlepast" ){
        if( func.verbNumber < 4 ){
            number = "s";
        }else{
            number = "p";
        }
    }

    if( number != "" && gender == "" ){
        return( "*" + number );
    }else{
        return( gender + number );
    }

}


1;
