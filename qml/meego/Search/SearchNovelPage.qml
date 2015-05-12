import QtQuick 1.1
import com.nokia.meego 1.0
import "../Component"
import "../../js/main.js" as Script

MyPage {
    id: page;

    property string word: "";
    property string searchMode: "s_tag";

    function getlist(){ internal.getCount(); }

    title: qsTr("Search result: ")+word;

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolIcon {
            platformIconId: "toolbar-jump-to"
            onClicked: {
                if (!internal.sortDialog){
                    internal.sortDialog = sortDialogComp.createObject(page);
                }
                internal.sortDialog.open();
            }
        }
    }

    Component {
        id: sortDialogComp;
        SelectionDialog {
            id: sortDialog;
            titleText: qsTr("Sort by");
            selectedIndex: 0;
            model: [
                qsTr("Sort by newest"),
                qsTr("Sort by oldest:All time"),
                qsTr("Sort by oldest:Within last day"),
                qsTr("Sort by oldest:Within last week"),
                qsTr("Sort by oldest:Within last month")
            ]
            onAccepted: {
                var today = new Date(), y = today.getFullYear(), m = today.getMonth()+1, d = today.getDate();
                switch (selectedIndex){
                case 0: internal.order = "date_d"; internal.scd = ""; break;
                case 1: internal.order = "date"; internal.scd = ""; break;
                case 2:
                    internal.order = "date";
                    internal.scd = Qt.formatDate(utility.addDays(y, m, d, -1), "yyyy-MM-dd");
                    break;
                case 3:
                    internal.order = "date";
                    internal.scd = Qt.formatDate(utility.addDays(y, m, d, -7), "yyyy-MM-dd");
                    break;
                case 4:
                    internal.order = "date";
                    internal.scd = Qt.formatDate(utility.addDays(y, m, d, -30), "yyyy-MM-dd");
                    break;
                }
                internal.getCount();
            }
        }
    }

    QtObject {
        id: internal;

        property int totalNumber: 0;
        property int currentPage: 0;

        property string order: "date_d";
        property string scd: "";

        property variant sortDialog: null;

        function getCount(){
            loading = true;
            view.model.clear();
            currentPage = 0;
            var opt = {"mode": "novel","s_mode": searchMode, "order": order, "word": word, "scd": scd};
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
            var opt = {"mode":"novel","s_mode": searchMode, "order": order, "word": word, "scd": scd, "model": view.model};
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
}
