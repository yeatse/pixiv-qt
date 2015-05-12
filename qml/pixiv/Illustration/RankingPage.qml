import QtQuick 1.1
import com.nokia.symbian 1.1
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
        property variant selectionDialog: null;
        property variant pastRankingsDialog: null;

        property string section: qsTr("Daily");
        property string mode: "day";
        property string content: "";
        property bool log: false;
        property int logYear: 0;
        property int logMonth: 0;
        property int logDay: 0;

        function getCount(){
            loading = true;
            view.model.clear();
            currentPage = 0;
            var opt = {
                "mode": mode, "content": content,
                "log": log, "Date_Year": logYear,
                "Date_Month": paddingLeft(logMonth), "Date_Day": paddingLeft(logDay)
            };
            function s(resp){
                loading = false;
                totalNumber = parseInt(resp);
                getlist();
            }
            function f(err){
                loading = false;
                signalCenter.showMessage(err);
            }
            Script.getRanking(opt, s, f);
        }

        function getlist(option){
            if (currentPage >= Math.ceil(totalNumber/50)) return;
            loading = true;
            if (view.count == 0) option = "renew";
            option = option || "renew";
            var opt = {
                "mode": mode, "content": content, "model": view.model,
                "log": log, "Date_Year": logYear,
                "Date_Month": paddingLeft(logMonth), "Date_Day": paddingLeft(logDay)
            };
            if (option == "renew"){
                opt.renew = true;
                currentPage = 1;
                opt.p = 1;
            } else {
                opt.p = currentPage + 1;
            }
            function s(p){ currentPage = p; loading = false; }
            function f(err){ signalCenter.showMessage(err); loading = false; }
            Script.getRanking(opt, s, f);
        }

        function openDialog(){
            if (!selectionDialog){
                selectionDialog = selectionDialogComp.createObject(page);
                var data = [[qsTr("Daily"), "day", ""],
                            [qsTr("Weekly"), "week", ""],
                            [qsTr("Monthly"), "month", ""],
                            [qsTr("Rookie"), "week", "rookie"],
                            [qsTr("Original"), "week", "original"],
                            [qsTr("Popular amongst males"), "day", "male"],
                            [qsTr("Popular amongst females"), "day", "female"],
                            [qsTr("Past rankings"), "", ""]]
                var model = selectionDialog.model;
                data.forEach(function(item){
                                 var prop = {"modelData": item[0], "mode": item[1], "content": item[2]};
                                 model.append(prop);
                             })
                selectionDialog.selectedIndex = 0;
            }
            selectionDialog.open();
        }

        function selectDate(){
            if (!pastRankingsDialog){
                pastRankingsDialog = pastRankingsDialogComp.createObject(page);
            }
            pastRankingsDialog.open();
        }

        function paddingLeft(number){
            return number < 10 ? "0"+number : number;
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

    Component {
        id: selectionDialogComp;
        SelectionDialog {
            id: selectionDialog;
            property int prevIndex: 0;
            titleText: qsTr("Ranking");
            model: ListModel {}
            onAccepted: {
                if (selectedIndex < model.count-1){
                    prevIndex = selectedIndex;
                    var data = model.get(selectedIndex);
                    internal.section = data.modelData;
                    internal.mode = data.mode;
                    internal.content = data.content;
                    internal.log = false;
                    internal.getCount();
                } else {
                    internal.selectDate();
                }
            }
        }
    }

    Component {
        id: pastRankingsDialogComp;
        DatePickerDialog {
            id: pastRankingsDialog;
            titleText: qsTr("Past rankings");
            privateCloseIcon: true;
            acceptButtonText: qsTr("Go");
            minimumYear: 2006;
            onAccepted: {
                internal.selectionDialog.prevIndex = internal.selectionDialog.selectedIndex;
                var yeasterday = getYeasterday();
                var yy = yeasterday.getFullYear(), ym = yeasterday.getMonth()+1, yd = yeasterday.getDate();
                if (utility.daysTo(year, month, day, yy, ym, yd) < 0){
                    year = yy; month = ym; day = yd;
                } else if (utility.daysTo(year, month, day, 2007, 10, 13) > 0){
                    year = 2007; month = 10; day = 13;
                }
                internal.section = qsTr("Past rankings");
                internal.mode = prmsd.model.get(prmsd.selectedIndex).mode;
                internal.content = "";
                internal.log = true;
                internal.logYear = year;
                internal.logDay = day;
                internal.logMonth = month;
                internal.getCount();
            }
            onRejected: {
                internal.selectionDialog.selectedIndex = internal.selectionDialog.prevIndex;
            }
            content: MenuItem {
                id: menuItem;
                platformSubItemIndicator: true;
                text: qsTr("Daily");
                onClicked: prmsd.open();
            }
            Component.onCompleted: {
                var yeasterday = getYeasterday();
                day = yeasterday.getDate();
                month = yeasterday.getMonth()+1;
                maximumYear = yeasterday.getFullYear()+1;
                year = maximumYear - 1;
                var prevItem = content[0];
                menuItem.anchors.top = prevItem.bottom;
            }
            function getYeasterday(){
                var today = new Date();
                return utility.addDays(today.getFullYear(), today.getMonth()+1, today.getDate(), -1);
            }
            SelectionDialog {
                id: prmsd;
                titleText: pastRankingsDialog.titleText;
                model: ListModel {}
                Component.onCompleted: {
                    var list = [[qsTr("Daily"), "daily"],
                                [qsTr("Weekly"), "weekly"],
                                [qsTr("Monthly"), "monthly"],
                                [qsTr("Rookie"), "weekly"],
                                [qsTr("Popular amongst males"), "male"],
                                [qsTr("Popular amongst females"), "female"],
                                [qsTr("R-18 Daily"), "daily_r18"],
                                [qsTr("R-18 Weekly"), "weekly_r18"],
                                [qsTr("R-18 Popular amongst males"), "male_r18"],
                                [qsTr("R-18 Popular amongst females"), "female_r18"],
                                [qsTr("R-18 G"), "r18g"]]
                    list.forEach(function(item){ model.append({"modelData": item[0], "mode": item[1]}); })
                    selectedIndex = 0;
                }
                onAccepted: {
                    menuItem.text = model.get(selectedIndex).modelData;
                }
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
