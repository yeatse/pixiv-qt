import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"
import "../../js/main.js" as Script

MyPage {
    id: page;

    title: qsTr("Novel")+" - "+internal.section;

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

        property string mode: "public";
        property string section: qsTr("Public");

        property variant selectionDialog: null;

        function getCount(){
            loading = true;
            view.model.clear();
            currentPage = 0;
            var opt = { "isNovel": true };
            if (mode == "private") opt.rest = "hide";
            function s(resp){
                loading = false;
                totalNumber = parseInt(resp);
                getlist();
            }
            function f(err){
                loading = false;
                signalCenter.showMessage(err);
            }
            Script.getBookmark(opt, s, f);
        }

        function getlist(option){
            if (currentPage >= Math.ceil(totalNumber/50)) return;
            loading = true;
            if (view.count == 0) option = "renew";
            option = option || "renew";
            var opt = {"isNovel": true, "model": view.model};
            if (mode == "private") opt.rest = "hide";
            if (option == "renew"){
                opt.renew = true;
                currentPage = 1;
                opt.p = 1;
            } else {
                opt.p = currentPage + 1;
            }
            function s(p){ currentPage = p; loading = false; }
            function f(err){ signalCenter.showMessage(err); loading = false; }
            Script.getBookmark(opt, s, f);
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

    Component {
        id: selectionDialogComp;
        SelectionDialog {
            id: selectionDialog;
            titleText: qsTr("Novel");
            model: [qsTr("Public"), qsTr("Private")];
            selectedIndex: 0;
            onAccepted: {
                if (selectedIndex == 0) internal.mode = "public";
                else internal.mode = "private";
                internal.section = model[selectedIndex];
                internal.getCount();
            }
        }
    }

    Button {
        anchors.centerIn: parent;
        visible: !loading && view.count == 0;
        text: qsTr("Reload");
        onClicked: internal.getCount();
    }

    Button {
        anchors { left: parent.left; bottom: parent.bottom; margins: constant.paddingMedium; }
        width: height;
        iconSource: privateStyle.toolBarIconPath("toolbar-list");
        onClicked: internal.openDialog();
    }
}
