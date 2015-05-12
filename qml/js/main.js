.pragma library

Qt.include("PixivApi.js");

var workerScript;
var signalCenter;
var phpsessid;

function initialize(ws, sc){
    workerScript = ws;
    signalCenter = sc;
    signalCenter.initialized();
}

function getRanking(option, onSuccess, onFailed){
    var url;
    if (option.log) url = PixivApi.Ranking_Log;
    else url = PixivApi.Ranking;
    var req = new WebRequest(url);
    var param = { "mode": option.mode }

    if (option.p) param.p = option.p;
    else param.c_mode = "count";

    if (option.content) param.content = option.content;
    if (option.log){
        param.Date_Year = option.Date_Year;
        param.Date_Month = option.Date_Month;
        param.Date_Day = option.Date_Day;
    }
    req.setParameters(param);
    var s;
    if (option.p){
        s = function (resp){
                    var msg = {"mode": "ranking", "data": resp, "option": option};
                    workerScript.sendMessage(msg);
                    onSuccess(option.p);
                }
    } else {
        s = onSuccess;
    }
    req.sendRequest(s, onFailed);
}

function getTags(option, onSuccess, onFailed){
    var req = new WebRequest(PixivApi.Tags);
    var param = { "tag": option.tag }

    if (option.p) param.p = option.p;
    else param.c_mode = "count";

    req.setParameters(param);
    var s;
    if (option.p){
        s = function (resp){
                    var msg = {"mode": "ranking", "data": resp, "option": option};
                    workerScript.sendMessage(msg);
                    onSuccess(option.p);
                }
    } else {
        s = onSuccess;
    }
    req.sendRequest(s, onFailed);
}

function getNewIllust(option, onSuccess, onFailed){
    var url;
    if (option.mode == "my") url = PixivApi.New_Illust_My;
    else if (option.mode == "followers") url = PixivApi.New_Illust_Followers;
    else if (option.mode == "member") url = PixivApi.Member_Illust;
    else url = PixivApi.New_Illust;
    var req = new WebRequest(url);
    var param = { "dummy": 0 }

    if (option.id) param.id = option.id;

    if (option.p) param.p = option.p;
    else param.c_mode = "count";

    req.setParameters(param);
    var s;
    if (option.p){
        s = function (resp){
                    var msg = {"mode": "ranking", "data": resp, "option": option};
                    workerScript.sendMessage(msg);
                    onSuccess(option.p);
                }
    } else {
        s = onSuccess;
    }
    req.sendRequest(s, onFailed);
}

function getHotTags(option, onSuccess, onFailed){
    var req = new WebRequest(PixivApi.Hot_Tags);
    var param = { "dummy": 0 }

    if (option.p) param.p = option.p;
    else param.c_mode = "count";

    req.setParameters(param);
    var s;
    if (option.p){
        s = function (resp){
                    var msg = {"mode": "tags", "data": resp, "option": option};
                    workerScript.sendMessage(msg);
                    onSuccess(option.p);
                }
    } else {
        s = onSuccess;
    }
    req.sendRequest(s, onFailed);
}

function getManga(option, onSuccess, onFailed){
    var req = new WebRequest(PixivApi.Manga);
    var param = {"illust_id": option.illust_id};

    if (option.p) param.p = option.p;
    else param.c_mode = "count";

    req.setParameters(param);
    var s;
    if (option.p){
        s = function (resp){
                    var msg = {"mode": "ranking", "data": resp, "option": option};
                    workerScript.sendMessage(msg);
                    onSuccess(option.p);
                }
    } else {
        s = onSuccess;
    }
    req.sendRequest(s, onFailed);
}

function addBookmark(option, onSuccess, onFailed){
    var url;
    if (option.isNovel) url = PixivApi.Bookmark_Add_Novel;
    else if (option.isUser) url = PixivApi.Bookmark_Add_User;
    else url = PixivApi.Bookmark_Add_Illust;
    url += "?dummy=0&PHPSESSID="+phpsessid;
    var req = new WebRequest(url, "POST");
    var param = new Object();

    if (option.mode) param.mode = option.mode;
    if (option.id) param.id = option.id;
    if (option.illust_id) param.illust_id = option.illust_id;
    param.restrict = option.restrict;

    req.setParameters(param);
    req.sendRequest(onSuccess, onFailed);
}

function addRating(option, onSuccess, onFailed){
    var url;
    if (option.isNovel) url = PixivApi.Rating_Novel;
    else url = PixivApi.Rating;
    url += "?dummy=0&PHPSESSID="+phpsessid;
    var req = new WebRequest(url, "POST");
    var param = {"illust_id": option.illust_id, "score": option.score};
    req.setParameters(param);
    req.sendRequest(onSuccess, onFailed);
}

function getSearch(option, onSuccess, onFailed){
    var url;
    if (option.mode == "user") url = PixivApi.Search_User;
    else if (option.mode == "novel") url = PixivApi.Search_Novel;
    else url = PixivApi.Search;

    var req = new WebRequest(url);

    var param = new Object();

    if (option.s_mode) param.s_mode = option.s_mode;
    if (option.order) param.order = option.order;
    if (option.word) param.word = option.word;
    if (option.nick) param.nick = option.nick;

    if (option.p) param.p = option.p;
    else param.c_mode = "count";

    if (option.scd) param.scd = option.scd;

    req.setParameters(param);
    var s;
    if (option.p){
        s = function (resp){
                    var mode = option.mode == "user" ? "user" : "ranking";
                    var msg = {"mode": mode, "data": resp, "option": option};
                    workerScript.sendMessage(msg);
                    onSuccess(option.p);
                }
    } else {
        s = onSuccess;
    }
    req.sendRequest(s, onFailed);
}

function getComment(option, onSuccess, onFailed){
    var url, param;
    if (option.isNovel){
        url = PixivApi.Novel_Comments;
        param = { "id": option.illust_id };
    } else {
        url = PixivApi.Illust_Comments;
        param = { "illust_id": option.illust_id };
    }
    var req = new WebRequest(url);

    if (option.p) param.p = option.p;
    else param.c_mode = "count";

    req.setParameters(param);
    var s;
    if (option.p){
        s = function (resp){
                    var msg = {"mode": "comments", "data": resp, "option": option};
                    workerScript.sendMessage(msg);
                    onSuccess(option.p);
                }
    } else {
        s = onSuccess;
    }
    req.sendRequest(s, onFailed);
}

function addComment(option, onSuccess, onFailed){
    var req = new WebRequest(PixivApi.Comment);
    var param = {
        "mode": option.mode,
        "illust_id": option.illust_id,
        "comment": option.comment
    }
    req.setParameters(param);
    req.sendRequest(onSuccess, onFailed);
}

function getNovelRanking(option, onSuccess, onFailed){
    var req = new WebRequest(PixivApi.Novel_Ranking);
    var param = { "mode": option.mode, "type": option.type };

    if (option.p) param.p = option.p;
    else param.c_mode = "count";

    req.setParameters(param);
    var s;
    if (option.p){
        s = function (resp){
                    var msg = {"mode": "ranking", "data": resp, "option": option};
                    workerScript.sendMessage(msg);
                    onSuccess(option.p);
                }
    } else {
        s = onSuccess;
    }
    req.sendRequest(s, onFailed);
}

function getNovelText(option, onSuccess, onFailed){
    var req = new WebRequest(PixivApi.Novel_Text);
    var param = { "id": option.id };
    req.setParameters(param);
    function s(resp){
        var msg = { "mode": "novel", "data": resp, "option": option };
        workerScript.sendMessage(msg);
        onSuccess(option.p);
    }
    req.sendRequest(s, onFailed);
}

function getNewNovel(option, onSuccess, onFailed){
    var url;
    if (option.mode == "my") url = PixivApi.New_Novel_My;
    else if (option.mode == "followers") url = PixivApi.New_Novel_Followers;
    else if (option.mode == "r18") url = PixivApi.New_Novel_R18;
    else if (option.mode == "member") url = PixivApi.Member_Novel;
    else url = PixivApi.New_Novel;
    var req = new WebRequest(url);
    var param = { "dummy": 0 }

    if (option.id) param.id = option.id;

    if (option.p) param.p = option.p;
    else param.c_mode = "count";
    req.setParameters(param);
    var s;
    if (option.p){
        s = function (resp){
                    var msg = {"mode": "ranking", "data": resp, "option": option};
                    workerScript.sendMessage(msg);
                    onSuccess(option.p);
                }
    } else {
        s = onSuccess;
    }
    req.sendRequest(s, onFailed);
}

function getBookmark(option, onSuccess, onFailed){
    var url;
    if (option.isNovel) url = PixivApi.Bookmark_Novel;
    else url = PixivApi.Bookmark;
    var req = new WebRequest(url);
    var param = { "dummy": 0 };
    if (option.id) param.id = option.id;
    if (option.rest) param.rest = option.rest;
    if (option.p) param.p = option.p;
    else param.c_mode = "count";
    req.setParameters(param);
    var s;
    if (option.p){
        s = function (resp){
                    var msg = { "mode": "ranking", "data": resp, "option": option };
                    workerScript.sendMessage(msg);
                    onSuccess(option.p);
                }
    } else {
        s = onSuccess;
    }
    req.sendRequest(s, onFailed);
}

function getUserList(option, onSuccess, onFailed){
    var url;
    if (option.mode == "my") url = PixivApi.Mypixiv_All;
    else url = PixivApi.Bookmark_User_All;
    var req = new WebRequest(url);
    var param = {};
    if (option.rest) param.rest = option.rest;
    if (option.mode == "my") param.dummy = 0;
    if (option.id) param.id = option.id;

    if (option.p) param.p = option.p;
    else param.c_mode = "count";
    req.setParameters(param);
    var s;
    if (option.p){
        s = function (resp){
                    var msg = { "mode": "user", "data": resp, "option": option };
                    workerScript.sendMessage(msg);
                    onSuccess(option.p);
                }
    } else {
        s = onSuccess;
    }
    req.sendRequest(s, onFailed);
}
