import QtQuick 1.1
import com.nokia.meego 1.0
import QtWebKit 1.0
import "Component"
import "../js/main.js" as Script

MyPage {
    id: page;

    property variant parentView;
    property variant modelData;
    onModelDataChanged: if (modelData) internal.getNovel();

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolIcon {
            platformIconId: "toolbar-add";
            enabled: view.currentItem != null;
            onClicked: {
                addBookmarkMenu.isBookmark = true;
                addBookmarkMenu.open();
            }
        }
        ToolIcon {
            platformIconId: "toolbar-favorite-mark";
            enabled: view.currentItem != null;
            onClicked: {
                addBookmarkMenu.isBookmark = false;
                addBookmarkMenu.open();
            }
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu";
            enabled: view.currentItem != null;
            onClicked: {
                internal.openMenu();
            }
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

            page.title = modelData.title;
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
                MenuItem {
                    text: qsTr("More");
                    onClicked: {
                        var prop = { "currentIndex": parentView.currentIndex, "model": parentView.model, "isNovel": true }
                        pageStack.push(Qt.resolvedUrl("IllustDetailPage.qml"), prop);
                    }
                }
                MenuItem {
                    text: qsTr("Comments");
                    onClicked: {
                        var prop = { "isNovel": true, "illustId": modelData.pid };
                        pageStack.push(Qt.resolvedUrl("CommentPage.qml"), prop);
                    }
                }
//                MenuItem {
//                    text: qsTr("Read later");
//                }
                MenuItem {
                    text: qsTr("Share");
                    onClicked: {
                        var pid = modelData.pid;
                        var msg = "http://p.tl/t/" + pid + " #pixiv"
                        Qt.openUrlExternally("mailto:?subject=&body="+msg);
                    }
                }
                MenuItem {
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
    SelectionDialog {
        id: addBookmarkMenu;
        titleText: page.title;
        property bool isBookmark: true;
        model: isBookmark ? [qsTr("Add public bookmark"), qsTr("Add private bookmark")]
                          : [qsTr("Rate it (10 points)")]
        onAccepted: {
            if (isBookmark){
                if (selectedIndex == 0){
                    internal.addBookmark(false);
                } else {
                    internal.addBookmark(true);
                }
            } else {
                internal.addRating();
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
                        defaultFontSize: constant.labelFont.pixelSize;
                        minimumFontSize: constant.labelFont.pixelSize;
                        minimumLogicalFontSize: constant.labelFont.pixelSize;
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
            }
        }
    }

    Rectangle {
        id: heading;
        anchors { left: parent.left; right: parent.right; top: parent.top; }
        height: 90;
        color: "#A0313233"
        Text {
            id: topBannerTitle;
            anchors.fill: parent;
            font: constant.labelFont;
            color: "white";
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
        platformStyle: ButtonStyle { buttonWidth: buttonHeight; }
        iconSource: "image://theme/icon-m-toolbar-refresh";
        onClicked: internal.getNovel();
    }
}
