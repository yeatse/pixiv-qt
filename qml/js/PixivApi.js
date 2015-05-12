var PixivApi = {
    "Ranking": "http://spapi.pixiv.net/iphone/ranking.php",
    "Ranking_Log": "http://spapi.pixiv.net/iphone/ranking_log.php",
    "Tags": "http://spapi.pixiv.net/iphone/tags.php",
    "New_Illust_Followers": "http://spapi.pixiv.net/iphone/bookmark_user_new_illust.php",
    "New_Illust_My": "http://spapi.pixiv.net/iphone/mypixiv_new_illust.php",
    "New_Illust": "http://spapi.pixiv.net/iphone/new_illust.php",
    "Hot_Tags": "http://spapi.pixiv.net/iphone/hot_tags.php",
    "Manga": "http://spapi.pixiv.net/iphone/manga.php",
    "Bookmark_Add_Illust": "http://spapi.pixiv.net/iphone/bookmark_add_illust.php",
    "Rating": "http://spapi.pixiv.net/iphone/rating.php",
    "Search": "http://spapi.pixiv.net/iphone/search.php",
    "Comment": "http://spapi.pixiv.net/iphone/comment.php",
    "Illust_Comments": "http://spapi.pixiv.net/iphone/illust_comments.php",
    "Novel_Ranking": "http://spapi.pixiv.net/iphone/novel_ranking.php",
    "Novel_Text": "http://spapi.pixiv.net/iphone/novel_text.php",
    "New_Novel_Followers": "http://spapi.pixiv.net/iphone/bookmark_user_new_novel.php",
    "New_Novel_My": "http://spapi.pixiv.net/iphone/mypixiv_new_novel.php",
    "New_Novel": "http://spapi.pixiv.net/iphone/new_novel.php",
    "New_Novel_R18": "http://spapi.pixiv.net/iphone/new_novel_r18.php",
    "Search_Novel": "http://spapi.pixiv.net/iphone/search_novel.php",
    "Novel_Comments": "http://spapi.pixiv.net/iphone/novel_comments.php",
    "Bookmark_Add_Novel": "http://spapi.pixiv.net/iphone/bookmark_add_novel.php",
    "Rating_Novel": "http://spapi.pixiv.net/iphone/rating_novel.php",
    "Bookmark": "http://spapi.pixiv.net/iphone/bookmark.php",
    "Bookmark_Novel": "http://spapi.pixiv.net/iphone/bookmark_novel.php",
    "Bookmark_User_All": "http://spapi.pixiv.net/iphone/bookmark_user_all.php",
    "Mypixiv_All": "http://spapi.pixiv.net/iphone/mypixiv_all.php",
    "Member_Illust": "http://spapi.pixiv.net/iphone/member_illust.php",
    "Member_Novel": "http://spapi.pixiv.net/iphone/member_novel.php",
    "Search_User": "http://spapi.pixiv.net/iphone/search_user.php",
    "Bookmark_Add_User": "http://spapi.pixiv.net/iphone/bookmark_add_user.php"
}

var WebRequest = function (url, method){
    this.method = method || "GET";
    this.url = url;
    this.parameters = {};
    this.encodedParams = function(){
             var res = [];
             for (var i in this.parameters){
                 res.push(i+"="+encodeURIComponent(this.parameters[i]));
             }
             if (phpsessid) res.push("PHPSESSID="+phpsessid);
             return res.join("&");
         }
}

WebRequest.prototype.setParameters = function(param){
            this.parameters = param;
        }

WebRequest.prototype.setMessage = function(message){
            this.message = message;
        }

WebRequest.prototype.sendRequest = function(onSuccess, onFailed){
            var __msg = this.message;
            var req = new XMLHttpRequest();
            req.onreadystatechange = function(){
                        if (req.readyState == XMLHttpRequest.DONE){
                            if (req.status == 200){
                                try {
                                    var resp = req.responseText;
                                    if (resp.substring(0,13) == "<?xml version"){
                                        onFailed("ERROR!!")
                                    } else {
                                        onSuccess(resp, __msg);
                                    }
                                } catch(e){
                                    onFailed(JSON.stringify(e));
                                }
                            } else {
                                onFailed("Network error: "+req.status+" "+req.statusText);
                            }
                        }
                    }
            var param = this.encodedParams();
            console.log(this.url, param);
            if (this.method == "GET"){
                req.open("GET", this.url+(param?"?"+param:""));
                req.send();
            } else if (this.method == "POST"){
                req.open("POST", this.url);
                req.setRequestHeader("Content-Length", param.length);
                req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
                req.send(param);
            }
        }
