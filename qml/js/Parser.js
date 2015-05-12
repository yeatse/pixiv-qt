WorkerScript.onMessage = function(msg){
                 var mode = msg.mode;
                 var data = msg.data;
                 var option = msg.option;

                 switch (mode){
                 case "ranking": loadRanking(option, data); break;
                 case "tags": loadTags(option, data); break;
                 case "comments": loadComments(option, data); break;
                 case "novel": loadNovel(option, data); break;
                 case "user": loadUser(option, data); break;
                 }
             }

// Return array of string values, or NULL if CSV string not well formed.
function CSVtoArray(text) {
    var re_valid = /^\s*(?:'[^'\\]*(?:\\[\S\s][^'\\]*)*'|"[^"\\]*(?:\\[\S\s][^"\\]*)*"|[^,'"\s\\]*(?:\s+[^,'"\s\\]+)*)\s*(?:,\s*(?:'[^'\\]*(?:\\[\S\s][^'\\]*)*'|"[^"\\]*(?:\\[\S\s][^"\\]*)*"|[^,'"\s\\]*(?:\s+[^,'"\s\\]+)*)\s*)*$/;
    var re_value = /(?!\s*$)\s*(?:'([^'\\]*(?:\\[\S\s][^'\\]*)*)'|"([^"\\]*(?:\\[\S\s][^"\\]*)*)"|([^,'"\s\\]*(?:\s+[^,'"\s\\]+)*))\s*(?:,|$)/g;
    // Return NULL if input string is not well formed CSV string.
    if (!re_valid.test(text)) return null;
    var a = [];                     // Initialize array to receive values.
    text.replace(re_value, // "Walk" the string using replace with callback.
        function(m0, m1, m2, m3) {
            // Remove backslash from \' in single quoted values.
            if      (m1 !== undefined) a.push(m1.replace(/\\'/g, "'"));
            // Remove backslash from \" in double quoted values.
            else if (m2 !== undefined) a.push(m2.replace(/\\"/g, '"'));
            else if (m3 !== undefined) a.push(m3);
            return ''; // Return empty string.
        });
    // Handle special case of empty last value.
    if (/,\s*$/.test(text)) a.push('');
    return a;
};

function loadRanking(option, data){
    var model = option.model;
    if (option.renew) model.clear();
    var list = data.split("\n");
    list.forEach(function(item){
                     item = item.replace(/""/g, "'");
                     var detail = CSVtoArray(item);
                     if (!detail || detail.length != 31) return;
                     var prop = {
                         "pid": detail[0],
                         "uid": detail[1],
                         "format": detail[2],
                         "title": detail[3],
                         "ranking": detail[4],
                         "contributor": detail[5],
                         "pic_thumbnail": detail[6],
                         "pic_medium": detail[9],
                         "date_posted": detail[12],
                         "tags": detail[13],
                         "tools_used": detail[14],
                         "rating": detail[15],
                         "score": detail[16],
                         "views": detail[17],
                         "caption": detail[18],
                         "pages": detail[19],
                         "bookmarks": detail[22],
                         "comments": detail[23],
                         "pixiv_id": detail[24],
                         "mark": detail[25],
                         "portrait": detail[29]
                     }
                     model.append(prop);
                 })
    model.sync();
}

function loadTags(option, data){
    var model = option.model;
    if (option.renew) model.clear();
    var list = data.split("\n");
    list.forEach(function(item){
                     var detail = CSVtoArray(item);
                     if (!detail || detail.length != 2) return;
                     var prop = {
                         "name": detail[0]
                     }
                     model.append(prop);
                 })
    model.sync();
}

function loadComments(option, data){
    var model = option.model;
    if (option.renew) model.clear();
    var list = data.split("\n");
    list.forEach(function(item){
                     var detail = CSVtoArray(item);
                     if (!detail || detail.length != 27) return;
                     var prop = {
                         "uid": detail[1],
                         "contributor": detail[5],
                         "portrait": detail[6],
                         "date_posted": detail[12],
                         "content": detail[18],
                         "pixiv_id": detail[24]
                     }
                     model.append(prop);
                 })
    model.sync();
}

function loadNovel(option, data){
    var model = option.model;
    model.clear();
    var list = data.split("[newpage]");

    function enrichText(raw){
        return raw
        .replace(/\n/g,
                 "<br/>")
        .replace(/\[pixivimage:(\d+)]/g,
                 "<p><img src='http://i1.pixiv.net/img01/img/pixiv/mobile/$1_480mw.jpg' onclick='handler.viewImage(this.src);'></p>")
        .replace(/\[chapter:([^\]]+)]/g,
                 "<h5>$1</h5>")
        .replace(/\[jump:(\d+)]/g,
                 "<p><a href='$1' onclick='handler.jumpToPage(this.href);return false;'>To page $1</a></p>")
        .replace(/\[\[jumpuri:(.+?)\s>\s(.+?)]]/g,
                 "<p><a href='$2' onclick='handler.jumpUri(this.href);return false;'>$1</a></p>")
        .replace(/\[pixivimage:(\d+)-(\d+)]/g,
                 "<p><a href='$1-$2' onclick='handler.viewManga($1,$2);return false;'>View manga</a></p>")
    }

    list.forEach(function(item){
                     var prop = { "text": enrichText(item) };
                     model.append(prop);
                 })
    model.sync();
}

function loadUser(option, data){
    var model = option.model;
    if (option.renew) model.clear();
    var list = data.split("\n");
    list.forEach(function(item){
                     var detail = CSVtoArray(item);
                     if (!detail || detail.length != 27) return;
                     var prop = {
                         "uid": detail[1],
                         "contributor": detail[5],
                         "avatar": detail[6],
                         "pixiv_id": detail[24]
                     }
                     model.append(prop);
                 })
    model.sync();
}
