import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import "../Component"
import "../../js/main.js" as Script

MyPage {
    id: page;

    title: qsTr("Ranking")+" - "+internal.section;

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

        property string section: qsTr("Daily");
        //day, week
        property string mode: "day";
        //normal, r18
        property string type: "normal"

        property variant selectionDialog: null;

        function getCount(){
            loading = true;
            view.model.clear();
            currentPage = 0;
            var opt = { "mode": mode, "type": type }
            function s(resp){
                loading = false;
                totalNumber = parseInt(resp);
                getlist();
            }
            function f(err){
                loading = false;
                signalCenter.showMessage(err);
            }
            Script.getNovelRanking(opt, s, f);
        }

        function getlist(option){
            if (currentPage >= Math.ceil(totalNumber/50)) return;
            loading = true;
            if (view.count == 0) option = "renew";
            option = option || "renew";
            var opt = { "mode": mode, "type": type, "model": view.model }
            if (option == "renew"){
                opt.renew = true;
                currentPage = 1;
                opt.p = 1;
            } else {
                opt.p = currentPage + 1;
            }
            function s(p){ currentPage = p; loading = false; }
            function f(err){ signalCenter.showMessage(err); loading = false; }
            Script.getNovelRanking(opt, s, f);
        }

        function openDialog(){
            if (!selectionDialog){
                selectionDialog = selectionDialogComp.createObject(page);
            }
            selectionDialog.open();
        }
    }

    ListView {
        id: view;

        property bool __aboutToNext: false;
        anchors.fill: parent;
        model: ListModel {}
        delegate: NovelDelegate {
            onClicked: {
                var prop = { "parentView": view, "modelData": model };
                pageStack.push(Qt.resolvedUrl("../NovelViewPage.qml"), prop);
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
        platformStyle: ButtonStyle { buttonWidth: buttonHeight; }
        iconSource: "image://theme/icon-m-toolbar-refresh";
        onClicked: internal.getCount();
    }

    Button {
        anchors { left: parent.left; bottom: parent.bottom; margins: constant.paddingMedium; }
        platformStyle: ButtonStyle { buttonWidth: buttonHeight; }
        iconSource: "image://theme/icon-m-toolbar-list"
        onClicked: internal.openDialog();
    }

    Component {
        id: selectionDialogComp;
        SelectionDialog {
            id: selectionDialog;
            titleText: qsTr("Ranking");
            model: ListModel {}
            Component.onCompleted: {
                var list = [[qsTr("Daily"), "day", "normal"],
                            [qsTr("Weekly"), "week", "normal"],
                            [qsTr("R-18 Daily"), "day", "r18"],
                            [qsTr("R-18 Weekly"), "week", "r18"]];
                list.forEach(function(item){
                                 var prop = {"modelData": item[0], "mode": item[1], "type": item[2]}
                                 model.append(prop);
                             })
                selectedIndex = 0;
            }
            onAccepted: {
                var data = model.get(selectedIndex);
                internal.section = data.modelData;
                internal.mode = data.mode;
                internal.type = data.type;
                internal.getCount();
            }
        }
    }
}
