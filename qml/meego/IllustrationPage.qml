import QtQuick 1.1
import com.nokia.meego 1.0
import "Component"
import "Illustration" as Ill

MyPage {
    id: page;

    title: qsTr("Illustration");

    ViewHeader {
        id: viewHeader;
        title: page.title;
        Row {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; }
            ToolIcon {
                platformIconId: "toolbar-search";
                onClicked: pageStack.push(Qt.resolvedUrl("SearchPage.qml"));
            }
            ToolIcon {
                platformIconId: "toolbar-view-menu";
                onClicked: signalCenter.selectSection(0);
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
        currentTab: rankingPage;
        Ill.RankingPage { id: rankingPage; pageStack: page.pageStack; }
        Ill.NewestPage { id: newestPage; pageStack: page.pageStack; }
        Ill.ContestsPage { id: contestsPage; pageStack: page.pageStack; }
        Ill.PopularTagsPage { id: popularTagsPage; pageStack: page.pageStack; }
    }

    tools: ToolBarLayout {
        ButtonRow {
            TabButton {
                iconSource: "image://theme/icon-m-toolbar-favorite-mark";
                tab: rankingPage;
            }
            TabButton {
                iconSource: "image://theme/icon-m-toolbar-clock";
                tab: newestPage;
            }
            TabButton {
                iconSource: "image://theme/icon-m-toolbar-addressbook";
                tab: contestsPage;
            }
            TabButton {
                iconSource: "image://theme/icon-m-toolbar-tag";
                tab: popularTagsPage;
            }
        }
    }
}
