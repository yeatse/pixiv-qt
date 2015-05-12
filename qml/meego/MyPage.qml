import QtQuick 1.1
import com.nokia.meego 1.0
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
            ToolIcon {
                platformIconId: "toolbar-settings";
                onClicked: pageStack.push(Qt.resolvedUrl("AboutAppPage.qml"));
            }
            ToolIcon {
                platformIconId: "toolbar-view-menu";
                onClicked: signalCenter.selectSection(3);
            }
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
                tab: profilePage;
                iconSource: "image://theme/icon-m-toolbar-addressbook";
            }
        }
    }
}
