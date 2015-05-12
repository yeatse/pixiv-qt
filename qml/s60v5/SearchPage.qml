import QtQuick 1.0
import com.nokia.symbian 1.0
import com.nokia.extras 1.0
import "Component"
import "../js/main.js" as Script

MyPage {
    id: page;

    property bool isNovel: false;

    title: qsTr("Search");

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ButtonRow {
            id: buttonRow;
            exclusive: false;
            ToolButton {
                checked: !isNovel;
                text: qsTr("Illustration");
                onClicked: {
                    isNovel = false;
                    internal.modeString = text;
                }
            }
            ToolButton {
                checked: isNovel
                text: qsTr("Novel");
                onClicked: {
                    isNovel = true;
                    internal.modeString = text;
                }
            }
        }
        ToolButton {
            iconSource: "toolbar-delete";
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

    SearchBox {
        id: searchBox;
        z: 10;
        placeHolderText: qsTr("Search");
    }

    Flickable {
        id: view;
        anchors { fill: parent; topMargin: searchBox.height; }
        contentWidth: width;
        contentHeight: contentCol.height;
        Column {
            id: contentCol;
            anchors { left: parent.left; right: parent.right; }
            Column {
                visible: searchBox.searchText.length > 0;
                width: parent.width;
                MenuItemWithIcon {
                    platformSubItemIndicator: true;
                    iconSource: "../gfx/tag.svg";
                    text: qsTr("Search tags for %1 in the \"%2\"").arg(internal.modeString).arg(searchBox.searchText);
                    onClicked: {
                        internal.addHistory(searchBox.searchText);
                        var prop = {"word":searchBox.searchText,"searchMode":isNovel?"s_tag_full":"s_tag"};
                        var qmlfile = isNovel ? "Search/SearchNovelPage.qml" : "Search/SearchResultPage.qml";
                        var p = pageStack.push(Qt.resolvedUrl(qmlfile), prop);
                        p.getlist();
                    }
                }
                MenuItemWithIcon {
                    visible: isNovel;
                    platformSubItemIndicator: true;
                    iconSource: "../gfx/document.svg";
                    text: qsTr("Search keyword for novel in the \"%1\"").arg(searchBox.searchText);
                    onClicked: {
                        internal.addHistory(searchBox.searchText);
                        var prop = { "word": searchBox.searchText };
                        var p = pageStack.push(Qt.resolvedUrl("Search/SearchNovelPage.qml"), prop);
                        p.getlist();
                    }
                }
                MenuItemWithIcon {
                    platformSubItemIndicator: true;
                    iconSource: "../gfx/document.svg";
                    text: {
                        var type = isNovel ? qsTr("body") : qsTr("captions");
                        return qsTr("Search %1 for %2 in the \"%3\"")
                            .arg(type)
                            .arg(internal.modeString)
                            .arg(searchBox.searchText);
                    }
                    onClicked: {
                        internal.addHistory(searchBox.searchText);
                        var prop = { "word": searchBox.searchText, "searchMode": "s_tc" };
                        var qmlfile = isNovel ? "Search/SearchNovelPage.qml" : "Search/SearchResultPage.qml";
                        var p = pageStack.push(Qt.resolvedUrl(qmlfile), prop);
                        p.getlist();
                    }
                }
                MenuItemWithIcon {
                    platformSubItemIndicator: true;
                    iconSource: "../gfx/contacts.svg";
                    text: qsTr("Search user in the \"%1\"").arg(searchBox.searchText);
                    onClicked: {
                        internal.addHistory(searchBox.searchText);
                        var prop = { "word": searchBox.searchText };
                        var p = pageStack.push(Qt.resolvedUrl("Search/SearchUserPage.qml"), prop);
                        p.getlist();
                    }
                }
            }
            ListHeading {
                ListItemText {
                    anchors.fill: parent.paddingItem;
                    role: "Heading";
                    text: qsTr("Search history");
                }
            }
            Repeater {
                model: internal.historyList;
                MenuItem {
                    platformSubItemIndicator: true;
                    text: modelData;
                    onClicked: {
                        searchBox.searchText = modelData;
                        view.contentY = 0;
                    }
                }
            }
            MenuItem {
                visible: internal.historyList.length == 0;
                enabled: false;
                text: "(" + qsTr("No search history") + ")";
            }
            ListHeading {
                ListItemText {
                    anchors.fill: parent.paddingItem;
                    role: "Heading";
                    text: qsTr("Popular tags");
                }
            }
            Repeater {
                model: ListModel { id: hotTagsModel; }
                MenuItem {
                    platformSubItemIndicator: true;
                    text: model.name || "";
                    onClicked: {
                        searchBox.searchText = model.name;
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
