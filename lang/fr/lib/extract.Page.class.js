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

