import QtQuick 1.0
import com.nokia.symbian 1.0
import "../Component"
import "../../js/main.js" as Script

MyPage {
    id: page;

    title: qsTr("Popular tags");

    onVisibleChanged: {
        if (visible && internal.firstStart){
            internal.firstStart = false;
            internal.getCount();
        }
    }

    QtObject {
        id: internal;

        property bool firstStart: true;
        property int totalNumber: 0;
        property int currentPage: 1;

        function getCount(){
            loading = true;
            function s(resp){
                loading = false;
                totalNumber = parseInt(resp);
                getlist();
            }
            function f(err){
                loading = false;
                signalCenter.showMessage(err);
            }
            Script.getHotTags({}, s, f);
        }

        function getlist(option){
            if (view.count >= totalNumber) return;
            loading = true;
            if (view.count == 0) option = "renew";
            option = option || "renew";
            var opt = {"model": view.model};
            if (option == "renew"){
                opt.renew = true;
                currentPage = 1;
                opt.p = 1;
            } else {
                opt.p = currentPage + 1;
            }
            function s(p){ currentPage = p; loading = false; }
            function f(err){ signalCenter.showMessage(err); loading = false; }
            Script.getHotTags(opt, s, f);
        }
    }

    ListView {
        id: view;

        property bool __aboutToNext: false;

        anchors.fill: parent;
        model: ListModel {}
        delegate: tagsDelegate;
        onAtYEndChanged: {
            if (view.count > 0 && atYEnd && !page.loading) __aboutToNext = true;
        }
        onMovementEnded: {
            if (__aboutToNext && !page.loading){
                __aboutToNext = false;
                internal.getlist("next");
            }
        }
        Component {
            id: tagsDelegate;
            ListItem {
                id: tagsItem;
                Text {
                    anchors.left: parent.paddingItem.left;
                    anchors.verticalCenter: parent.verticalCenter;
                    text: model.name;
                    font: constant.titleFont;
                    color: constant.colorLight;
                }
                onClicked: {
                    var prop = { "word": model.name }
                    var p = pageStack.push(Qt.resolvedUrl("../Search/SearchResultPage.qml"), prop);
                    p.getlist();
                }
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
