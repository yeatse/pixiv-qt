import QtQuick 1.1
import com.nokia.meego 1.0
import QtWebKit 1.0
import "Component"
import "../js/main.js" as Script

MyPage {
    id: page;

    title:qsTr("Profile");

    property string uid;
    onUidChanged: webView.url = "http://spapi.pixiv.net/iphone/profile.php?id="+uid

    property bool viewHeaderVisible: true;

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back";
            onClicked: pageStack.pop();
        }

        ToolIcon {
            platformIconId: "toolbar-favorite-mark";
            onClicked: addBookmarkMenu.open();
        }
    }

    function addBookmark(isPrivate){
        loading = true;
        var restrict = isPrivate ? 1 : 0;
        var opt = { "isUser": true, "mode": "add", "id": uid, "restrict": restrict };
        function r(resp){ signalCenter.showMessage(resp); loading = false; }
        Script.addBookmark(opt, r, r);
    }

    // rating menu
    ContextMenu {
        id: addBookmarkMenu;
        MenuLayout {
            MenuItem {
                text: qsTr("Add follows to public");
                onClicked: addBookmark(false);
            }
            MenuItem {
                text: qsTr("Add follows to private");
                onClicked: addBookmark(true);
            }
        }
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
        visible: viewHeaderVisible;
        height: viewHeaderVisible ? implicitHeight : 0;
    }

    Flickable {
        id: view;
        anchors.fill: parent;
        anchors.topMargin: viewHeader.height;

        contentWidth: webView.width;
        contentHeight: webView.height;

        WebView {
            id: webView;
            preferredHeight: view.height
            preferredWidth: view.width

            settings {
                defaultFontSize: constant.labelFont.pixelSize;
                minimumFontSize: constant.labelFont.pixelSize;
                minimumLogicalFontSize: constant.labelFont.pixelSize;
            }
        }
    }

    ProgressBar {
        anchors { left: parent.left; right: parent.right; top: viewHeader.bottom; }
        visible: webView.status == WebView.Loading;
        value: webView.progress;
    }
}
