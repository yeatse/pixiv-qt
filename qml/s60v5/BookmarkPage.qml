import QtQuick 1.0
import com.nokia.symbian 1.0
import "Component"
import "Bookmark" as Boo

MyPage {
    id: page;

    title: qsTr("Bookmark");

    ViewHeader {
        id: viewHeader;
        title: page.title;
        ToolButton {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; }
            iconSource: "toolbar-menu";
            onClicked: signalCenter.selectSection(2);
        }
    }

    ListHeading {
        id: heading;
        anchors.top: viewHeader.bottom;
        z: 10;
        ListItemText {
            anchors.fill: parent.paddingItem;
            role: "Heading";
            text: tabGroup.currentTab.title;
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
        ToolButton {
            iconSource: "../gfx/gallery.svg";
            onClicked: tabGroup.currentTab = illustPage;
        }
        ToolButton {
            iconSource: "../gfx/view_pages.svg";
            onClicked: tabGroup.currentTab = novelPage;
        }
        ToolButton {
            iconSource: "../gfx/group.svg";
            onClicked: tabGroup.currentTab = userPage;
        }
    }
}
