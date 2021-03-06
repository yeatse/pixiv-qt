import QtQuick 1.0
import com.nokia.symbian 1.0
import "../Component"
import "../../js/main.js" as Script

MyPage {
    id: page;

    title: qsTr("Illustration");

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
        property int currentPage: 0;
        onTotalNumberChanged: illustCount = totalNumber;

        function getCount(){
            loading = true;
            view.model.clear();
            currentPage = 0;
            var opt = { "mode": "member", "id": uid };
            function s(resp){
                loading = false;
                totalNumber = parseInt(resp);
                getlist();
            }
            function f(err){
                loading = false;
                signalCenter.showMessage(err);
            }
            Script.getNewIllust(opt, s, f);
        }

        function getlist(option){
            if (currentPage >= Math.ceil(totalNumber/50)) return;
            loading = true;
            if (view.count == 0) option = "renew";
            option = option || "renew";
            var opt = { "mode": "member", "id": uid, "model": view.model};
            if (option == "renew"){
                opt.renew = true;
                currentPage = 1;
                opt.p = 1;
            } else {
                opt.p = currentPage + 1;
            }
            function s(p){ currentPage = p; loading = false; }
            function f(err){ signalCenter.showMessage(err); loading = false; }
            Script.getNewIllust(opt, s, f);
        }
    }

    GridView {
        id: view;

        property bool __aboutToNext: false;

        anchors.fill: parent;
        cellWidth: parent.width / 3;
        cellHeight: cellWidth;
        model: ListModel {}
        delegate: GridDelegate {
            onClicked: {
                var prop = {"title": page.title, "parentView": view};
                pageStack.push(Qt.resolvedUrl("../ImageViewPage.qml"), prop);
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
