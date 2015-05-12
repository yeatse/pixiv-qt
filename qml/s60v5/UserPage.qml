import QtQuick 1.0
import com.nokia.symbian 1.0
import "Component"
import "User" as Usr

MyPage {
    id: page;

    property string uid;
    property string userName;
    property url avatarUrl;

    property int illustCount;
    property int novelCount;
    property int bookmarkCount;
    property int followingCount;

    title: qsTr("Users");

    BorderImage {
        id: viewHeader;
        anchors { left: parent.left; right: parent.right; top: parent.top; }
        height: childrenRect.height;
        source: privateStyle.imagePath("qtg_fr_list_heading_normal");
        border { left: 28; top: 5; right: 28; bottom: 0 }
        smooth: true;
        z: 10;
        Image {
            id: headerImage;
            anchors { left: parent.left; top: parent.top; margins: constant.paddingSmall; }
            width: 80;
            height: 80;
            source: avatarUrl;
            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom; }
                height: constant.titleFont.pixelSize;
                color: "#A0463D3B";
                Text {
                    anchors.centerIn: parent;
                    font: constant.subTitleFont;
                    color: constant.colorLight;
                    text: qsTr("Profile");
                }
            }
            MouseArea {
                anchors.fill: parent;
                onClicked: {
                    var prop = { "uid": uid };
                    pageStack.push(Qt.resolvedUrl("ProfilePage.qml"), prop);
                }
            }
        }
        Text {
            id: headerText;
            anchors {
                left: headerImage.right; right: parent.right;
                top: parent.top; margins: constant.paddingSmall;
            }
            font: constant.titleFont;
            wrapMode: Text.Wrap;
            color: constant.colorLight;
            style: Text.Raised;
            styleColor: constant.colorMid;
            text: userName;
        }
        Row {
            id: headerRow;
            anchors {
                left: headerImage.right; leftMargin: constant.paddingSmall;
                right: parent.right; rightMargin: constant.paddingSmall;
                top: headerText.bottom; topMargin: constant.paddingLarge;
            }
            Column {
                width: parent.width / 3;
                spacing: constant.paddingMedium;
                Text {
                    width: parent.width;
                    font: constant.subTitleFont;
                    color: "#8ACEEE";
                    wrapMode: Text.Wrap;
                    text: illustCount + novelCount;
                }
                Text {
                    width: parent.width;
                    font: constant.subTitleFont;
                    color: constant.colorMid;
                    wrapMode: Text.Wrap;
                    text: qsTr("Work posted");
                }
            }
            Column {
                width: parent.width / 3;
                spacing: constant.paddingMedium;
                Text {
                    width: parent.width;
                    font: constant.subTitleFont;
                    color: "#8ACEEE";
                    wrapMode: Text.Wrap;
                    text: bookmarkCount;
                }
                Text {
                    width: parent.width;
                    font: constant.subTitleFont;
                    color: constant.colorMid;
                    wrapMode: Text.Wrap;
                    text: qsTr("Bookmark results");
                }
            }
            Column {
                width: parent.width / 3;
                spacing: constant.paddingMedium;
                Text {
                    width: parent.width;
                    font: constant.subTitleFont;
                    color: "#8ACEEE";
                    wrapMode: Text.Wrap;
                    text: followingCount;
                }
                Text {
                    width: parent.width;
                    font: constant.subTitleFont;
                    color: constant.colorMid;
                    wrapMode: Text.Wrap;
                    text: qsTr("Following");
                }
            }
        }
        Item { width: 1; height: constant.paddingSmall; anchors.top: headerRow.bottom; }
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
        Usr.UserIllustPage { id: illustPage; pageStack: page.pageStack; }
        Usr.UserNovelPage { id: novelPage; pageStack: page.pageStack; }
        Usr.UserBMPage { id: bookmarkPage; pageStack: page.pageStack; }
        Usr.UserBookmarkPage { id: userPage; pageStack: page.pageStack; }
    }

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolButton {
            iconSource: "../gfx/gallery.svg";
            onClicked: tabGroup.currentTab = illustPage;
        }
        ToolButton {
            iconSource: "../gfx/view_pages.svg";
            onClicked: tabGroup.currentTab = novelPage;
        }
        ToolButton {
            iconSource: "../gfx/favourite.svg";
            onClicked: tabGroup.currentTab = bookmarkPage;
        }
        ToolButton {
            iconSource: "../gfx/group.svg";
            onClicked: tabGroup.currentTab = userPage;
        }
    }
}
