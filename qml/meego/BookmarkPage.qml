import QtQuick 1.1
import com.nokia.meego 1.0
import "Component"
import "Bookmark" as Boo

MyPage {
    id: page;

    title: qsTr("Bookmark");

    ViewHeader {
        id: viewHeader;
        title: page.title;
        ToolIcon {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; }
            platformIconId: "toolbar-view-menu";
            onClicked: signalCenter.selectSection(2);
        }
    }

    Rectangle {
        id: heading;
        anchors { left: parent.left; right: parent.right; top: viewHeader.bottom; }
        height: constant.graphicSizeSmall;
        color: "#D1D2D3";
        z: 10;
        Text {
            anchors { fill: parent; margins: constant.paddingSmall; }
            verticalAlignment: Text.AlignVCenter;
            horizontalAlignment: Text.AlignRight;
            text: tabGroup.currentTab.title;
            font: constant.subTitleFont;
            color: constant.colorLight;
        }
    }

    TabGroup {
        id: tabGroup;
        anchors {
            left: parent.left; right: parent.right;
            top: heading.bottom; bottom: parent.bottom;
        }
        currentTab: illustPage;
        Boo.IllustBookmarkPage { id: illustPage; pageStack: page.pageStack; }
        Boo.NovelBookmarkPage { id: novelPage; pageStack: page.pageStack; }
        Boo.UserBookmarkPage { id: userPage; pageStack: page.pageStack; }
    }

    tools: ToolBarLayout {
        ButtonRow {
            TabButton {
                tab: illustPage;
                iconSource: "image://theme/icon-m-toolbar-gallery";
            }
            TabButton {
                tab: novelPage;
                iconSource: "image://theme/icon-m-toolbar-pages-all";
            }
            TabButton {
                tab: userPage;
                iconSource: "image://theme/icon-m-toolbar-addressbook";
            }
        }
    }
}
