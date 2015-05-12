import QtQuick 1.0
import com.nokia.symbian 1.0
import QtWebKit 1.0
import "Component"
import "../js/main.js" as Script

MyPage {
    id: page;

    property variant parentView;
    property variant modelData;
    onModelDataChanged: if (modelData) internal.getNovel();

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolButton {
            iconSource: "../gfx/add_bookmark.svg";
            onClicked: {
                addBookmarkMenu.isBookmark = true;
                addBookmarkMenu.open();
            }
        }
        ToolButton {
            iconSource: "../gfx/favourite.svg";
            onClicked: {
                addBookmarkMenu.isBookmark = false;
                addBookmarkMenu.open();
            }
        }
        ToolButton {
            iconSource: "toolbar-menu";
            onClicked: internal.openMenu();
        }
    }

    QtObject {
        id: internal;

        property variant novelMenu;

        function getNovel(){
            loading = true;
            var opt = { "id": modelData.pid, "model": view.model };
            function r(resp){ signalCenter.showMessage(resp); loading = false; }
            Script.getNovelText(opt, r, r);
        }

        function addBookmark(isPrivate){
            loading = true;
            var restrict = isPrivate ? 1 : 0;
            var opt = {"illust_id": modelData.pid, "restrict": restrict, "isNovel": true};
            function r(resp){ signalCenter.showMessage(resp); loading = false; }
            Script.addBookmark(opt, r, r);
        }

        function addRating(){
            loading = true;
            var score = 10;
            var opt = {"illust_id": modelData.pid, "score": score, "isNovel": true};
            function r(resp){ signalCenter.showMessage(resp); loading = false; }
            Script.addRating(opt, r, r);
        }

        function setText(){
            if (view.currentIndex < 0) return;
            topBannerTitle.text = "(%1/%2) %3\n%4"
            .arg(view.currentIndex+1)
            .arg(view.count)
            .arg(modelData.title)
            .arg(modelData.contributor);
        }

        function openMenu(){
            if (!novelMenu){ novelMenu = novelMenuComp.createObject(page); }
            novelMenu.open();
        }
    }

    //main menu
    Component {
        id: novelMenuComp;
        Menu {
            id: novelMenu;
            MenuLayout {
                MenuItemWithIcon {
                    iconSource: "../gfx/toolbar_extension.svg";
                    text: qsTr("More");
                    onClicked: {
                        var prop = { "currentIndex": parentView.currentIndex, "model": parentView.model, "isNovel": true }
                        pageStack.push(Qt.resolvedUrl("IllustDetailPage.qml"), prop);
                    }
                }
                MenuItemWithIcon {
                    iconSource: "../gfx/instant_messenger_chat.svg";
                    text: qsTr("Comments");
                    onClicked: {
                        var prop = { "isNovel": true, "illustId": modelData.pid };
                        pageStack.push(Qt.resolvedUrl("CommentPage.qml"), prop);
                    }
                }
//                MenuItemWithIcon {
//                    text: qsTr("Read later");
//                }
                MenuItemWithIcon {
                    iconSource: privateStyle.toolBarIconPath("toolbar-share");
                    text: qsTr("Share");
                    onClicked: {
                        var pid = modelData.pid;
                        var msg = "http://p.tl/t/" + pid + " #pixiv"
                        Qt.openUrlExternally("sms:?body=" + msg);
                    }
                }
                MenuItemWithIcon {
                    iconSource: "../gfx/internet.svg";
                    text: qsTr("View on browser");
                    onClicked: {
                        var url = "http://touch.pixiv.net/novel/show.php?id="+modelData.pid;
                        Qt.openUrlExternally(url);
                    }
                }
            }
        }
    }

    // rating menu
    ContextMenu {
        id: addBookmarkMenu;
        property bool isBookmark: true;
        MenuLayout {
            MenuItem {
                visible: addBookmarkMenu.isBookmark;
                text: qsTr("Add public bookmark");
                onClicked: internal.addBookmark(false);
            }
            MenuItem {
                visible: addBookmarkMenu.isBookmark;
                text: qsTr("Add private bookmark");
                onClicked: internal.addBookmark(true);
            }
            MenuItem {
                visible: !addBookmarkMenu.isBookmark;
                text: qsTr("Rate it (10 points)");
                onClicked: internal.addRating();
            }
        }
    }

    ListView {
        id: view;
        anchors { fill: parent; topMargin: heading.height; }
        preferredHighlightBegin: 0;
        preferredHighlightEnd: view.width;
        highlightMoveDuration: 250;
        highlightRangeMode: ListView.StrictlyEnforceRange;
        snapMode: ListView.SnapOneItem;
        boundsBehavior: ListView.StopAtBounds;
        orientation: ListView.Horizontal;
        model: ListModel {}
        delegate: novelDelegate;

        onCurrentIndexChanged: internal.setText();

        Component {
            id: novelDelegate;
            Flickable {
                id: root;

                width: ListView.view.width;
                height: ListView.view.height;

                contentWidth: width;
                contentHeight: contentView.height;

                interactive: !ListView.view.moving;
                onMovementStarted: ListView.view.interactive = false;
                onMovementEnded: ListView.view.interactive = true;

                WebView {
                    id: contentView;
                    anchors { left: parent.left; right: parent.right; }
                    preferredWidth: root.width;
                    preferredHeight: root.height;
                    settings {
                        defaultFontSize: platformStyle.fontSizeMedium;
                        minimumFontSize: platformStyle.fontSizeMedium;
                        minimumLogicalFontSize: platformStyle.fontSizeMedium;
                    }

                    javaScriptWindowObjects: QtObject {
                        WebView.windowObjectName: "handler";

                        function viewImage(src){
                            Qt.openUrlExternally(src);
                        }

                        function jumpToPage(pageNumber){
                            root.ListView.view.positionViewAtIndex(pageNumber-1, ListView.Center);
                        }

                        function jumpUri(url){
                            Qt.openUrlExternally(url)
                        }

                        function viewManga(illustId, pageId){
                            var prop = { "illustId": illustId, "pageId": pageId }
                            pageStack.push(Qt.resolvedUrl("MangaViewPage.qml"), prop);
                        }
                    }

                    Timer {
                        id: bufferTimer;
                        interval: 250;
                        onTriggered: contentView.html = model.text;
                    }
                    Component.onCompleted: bufferTimer.start();
                }

                ScrollDecorator { flickableItem: root; }
            }
        }
    }

    Rectangle {
        id: heading;
        anchors { left: parent.left; right: parent.right; top: parent.top; }
        height: constant.graphicSizeLarge;
        color: "#A0463D3B"
        Text {
            id: topBannerTitle;
            anchors.fill: parent;
            font: constant.labelFont;
            color: constant.colorLight;
            style: Text.Raised;
            styleColor: constant.colorMid;
            wrapMode: Text.Wrap;
            horizontalAlignment: Text.AlignHCenter;
            verticalAlignment: Text.AlignVCenter;
        }
    }

    //navi controls
    MouseArea {
        id: leftButton;
        anchors { left: parent.left; bottom: parent.bottom; }
        visible: view.currentIndex > 0;
        width: childrenRect.width;
        height: childrenRect.height;
        onClicked: view.decrementCurrentIndex();
        Image {
            source: "../gfx/button_prev_"+(parent.pressed?"pressed":"normal")+".png";
        }
    }
    MouseArea {
        id: rightButton;
        anchors { right: parent.right; bottom: parent.bottom; }
        visible: view.currentIndex >= 0 && view.currentIndex < view.count-1;
        width: childrenRect.width;
        height: childrenRect.height;
        onClicked: view.incrementCurrentIndex();
        Image {
            source: "../gfx/button_next_"+(parent.pressed?"pressed":"normal")+".png"
        }
    }

    Button {
        anchors.centerIn: parent;
        visible: !loading && view.count == 0;
        text: qsTr("Reload");
        onClicked: internal.getNovel();
    }
}
