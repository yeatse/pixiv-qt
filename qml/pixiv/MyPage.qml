import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "User" as Usr

MyPage {
    id: page;

    property string uid: psettings.userData.id;

    property int illustCount;
    property int novelCount;
    property int bookmarkCount;
    property int followingCount;

    title: qsTr("My Page");

    ViewHeader {
        id: viewHeader;
        title: page.title;
        Row {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; }
            ToolButton {
                iconSource: "../gfx/accounts.svg";
                onClicked: pageStack.push(Qt.resolvedUrl("AboutAppPage.qml"));
            }
            ToolButton {
                iconSource: "toolbar-menu";
                onClicked: signalCenter.selectSection(3);
            }
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
        onCurrentTabChanged: if (currentTab == profilePage) profilePage.uid = psettings.userData.id;
        Usr.UserIllustPage { id: illustPage; pageStack: page.pageStack; }
        Usr.UserNovelPage { id: novelPage; pageStack: page.pageStack; }
        ProfilePage {
            id: profilePage;
            pageStack: page.pageStack;
            viewHeaderVisible: false;
        }
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
            iconSource: "../gfx/contacts.svg";
            onClicked: tabGroup.currentTab = profilePage;
        }
    }
}
