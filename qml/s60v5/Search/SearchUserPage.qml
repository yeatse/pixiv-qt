import QtQuick 1.0
import com.nokia.symbian 1.0
import "../Component"
import "../../js/main.js" as Script

MyPage {
    id: page;

    property string word: "";

    function getlist(){ internal.getCount(); }

    title: qsTr("Search result: ")+word;

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: pageStack.pop();
        }
    }

    QtObject {
        id: internal;

        property int totalNumber: 0;
        property int currentPage: 0;

        function getCount(){
            loading = true;
            view.model.clear();
            currentPage = 0;
            var opt = {"nick": word, "mode": "user"};
            function s(resp){
                loading = false;
                totalNumber = parseInt(resp);
                getlist();
            }
            function f(err){
                loading = false;
                signalCenter.showMessage(err);
            }
            Script.getSearch(opt, s, f);
        }

        function getlist(option){
            if (currentPage >= Math.ceil(totalNumber/50)) return;
            loading = true;
            if (view.count == 0) option = "renew";
            option = option || "renew";
            var opt = {"nick": word, "mode": "user", "model": view.model};
            if (option == "renew"){
                opt.renew = true;
                currentPage = 1;
                opt.p = 1;
            } else {
                opt.p = currentPage + 1;
            }
            function s(p){ currentPage = p; loading = false; }
            function f(err){ signalCenter.showMessage(err); loading = false; }
            Script.getSearch(opt, s, f);
        }
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
    }

    ListView {
        id: view;

        property bool __aboutToNext: false;
        anchors { fill: parent; topMargin: viewHeader.height; }
        model: ListModel {}
        delegate: UserDelegate {
            onClicked: {
                var prop = { "uid": model.uid, "userName": model.contributor, "avatarUrl": model.avatar };
                pageStack.push(Qt.resolvedUrl("../UserPage.qml"), prop);
            }
        }
        onAtYEndChanged: {
            if (view.count > 0 && atYEnd && !page.loading) __aboutToNext = true;
        }
        onMovementEnded: {
            if (__aboutToNext && !page.loading){
                __aboutToNext = false;
                internal.getlist("next");
            }
        }
    }

    ScrollDecorator { flickableItem: view; }

    Button {
        anchors.centerIn: parent;
        visible: !loading && view.count == 0;
        text: qsTr("Reload");
        onClicked: internal.getCount();
    }
}
