import QtQuick 1.1
import com.nokia.meego 1.0
import "Component"
import "../js/main.js" as Script

MyPage {
    id: page;

    property bool isNovel: false;

    title: qsTr("Search");

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ButtonRow {
            id: buttonRow;
            exclusive: false;
            TabButton {
                checked: !isNovel;
                text: qsTr("Illustration");
                onClicked: {
                    isNovel = false;
                    internal.modeString = text;
                }
            }
            TabButton {
                checked: isNovel
                text: qsTr("Novel");
                onClicked: {
                    isNovel = true;
                    internal.modeString = text;
                }
            }
        }
        ToolIcon {
            platformIconId: "toolbar-delete";
            onClicked: internal.historyList = [];
        }
    }

    QtObject {
        id: internal;

        property string modeString: isNovel ? qsTr("Novel") : qsTr("Illustration");

        property int totalNumber: 0;
        property int currentPage: 1;

        property bool loading: false;

        property variant historyList: utility.getValue("SearchHistory", [])||[];
        onHistoryListChanged: utility.setValue("SearchHistory", historyList);

        function addHistory(name){
            var ary = [];
            if (!historyList.some(function(value){
                                  ary.push(value);
                                  return value == name;})){
                ary.push(name);
                historyList = ary;
            }
        }
        function removeHistory(name){
            var ary = [];
            historyList.forEach(function(value){
                                    if (value != name) ary.push(value);
                                })
            historyList = ary;
        }

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
            var opt = {"model": hotTagsModel};
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

    ViewHeader {
        id: viewHeader;
        TextField {
            id: searchBox;
            anchors {
                left: parent.left; right: parent.right;
                verticalCenter: parent.verticalCenter; margins: constant.paddingLarge;
            }
            placeholderText: qsTr("Search");
            focus: true;
            ToolIcon {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter; }
                platformIconId: "toolbar-cancle";
                visible: searchBox.activeFocus || searchBox.text.length > 0;
                onClicked: {
                    searchBox.text = "";
                    page.forceActiveFocus();
                }
            }
        }
    }

    Flickable {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        contentWidth: width;
        contentHeight: contentCol.height;
        Column {
            id: contentCol;
            anchors { left: parent.left; right: parent.right; }
            Column {
                visible: searchBox.text.length > 0;
                width: parent.width;
                MenuItem {
                    text: qsTr("Search tags for %1 in the \"%2\"").arg(internal.modeString).arg(searchBox.text);
                    onClicked: {
                        internal.addHistory(searchBox.text);
                        var prop = {"word":searchBox.text,"searchMode":isNovel?"s_tag_full":"s_tag"};
                        var qmlfile = isNovel ? "Search/SearchNovelPage.qml" : "Search/SearchResultPage.qml";
                        var p = pageStack.push(Qt.resolvedUrl(qmlfile), prop);
                        p.getlist();
                    }
                }
                MenuItem {
                    visible: isNovel;
                    text: qsTr("Search keyword for novel in the \"%1\"").arg(searchBox.text);
                    onClicked: {
                        internal.addHistory(searchBox.text);
                        var prop = { "word": searchBox.text };
                        var p = pageStack.push(Qt.resolvedUrl("Search/SearchNovelPage.qml"), prop);
                        p.getlist();
                    }
                }
                MenuItem {
                    text: {
                        var type = isNovel ? qsTr("body") : qsTr("captions");
                        return qsTr("Search %1 for %2 in the \"%3\"")
                            .arg(type)
                            .arg(internal.modeString)
                            .arg(searchBox.text);
                    }
                    onClicked: {
                        internal.addHistory(searchBox.text);
                        var prop = { "word": searchBox.text, "searchMode": "s_tc" };
                        var qmlfile = isNovel ? "Search/SearchNovelPage.qml" : "Search/SearchResultPage.qml";
                        var p = pageStack.push(Qt.resolvedUrl(qmlfile), prop);
                        p.getlist();
                    }
                }
                MenuItem {
                    text: qsTr("Search user in the \"%1\"").arg(searchBox.text);
                    onClicked: {
                        internal.addHistory(searchBox.text);
                        var prop = { "word": searchBox.text };
                        var p = pageStack.push(Qt.resolvedUrl("Search/SearchUserPage.qml"), prop);
                        p.getlist();
                    }
                }
            }
            Rectangle {
                anchors { left: parent.left; right: parent.right; }
                height: constant.graphicSizeSmall;
                color: "#D1D2D3";
                z: 10;
                Text {
                    anchors { fill: parent; margins: constant.paddingSmall; }
                    verticalAlignment: Text.AlignVCenter;
                    horizontalAlignment: Text.AlignRight;
                    text: qsTr("Search history");
                    font: constant.subTitleFont;
                    color: constant.colorLight;
                }
            }
            Repeater {
                model: internal.historyList;
                MenuItem {
                    platformStyle: MenuItemStyle { position: "vertical-center"; }
                    text: modelData;
                    onClicked: {
                        searchBox.text = modelData;
                        view.contentY = 0;
                    }
                }
            }
            MenuItem {
                visible: internal.historyList.length == 0;
                enabled: false;
                text: "(" + qsTr("No search history") + ")";
            }
            Rectangle {
                anchors { left: parent.left; right: parent.right; }
                height: constant.graphicSizeSmall;
                color: "#D1D2D3";
                z: 10;
                Text {
                    anchors { fill: parent; margins: constant.paddingSmall; }
                    verticalAlignment: Text.AlignVCenter;
                    horizontalAlignment: Text.AlignRight;
                    text: qsTr("Popular tags");
                    font: constant.subTitleFont;
                    color: constant.colorLight;
                }
            }
            Repeater {
                model: ListModel { id: hotTagsModel; }
                MenuItem {
                    platformStyle: MenuItemStyle { position: "vertical-center"; }
                    text: model.name || "";
                    onClicked: {
                        searchBox.text = model.name;
                        view.contentY = 0;
                    }
                }
            }
            MenuItem {
                visible: hotTagsModel.count == 0;
                enabled: false;
                text: "(" + qsTr("Loading popular tags...") + ")";
            }
        }
    }

    ScrollDecorator { flickableItem: view; }

    Component.onCompleted: internal.getCount();
}
