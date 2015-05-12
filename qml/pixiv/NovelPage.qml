import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "Novel" as Nov

MyPage {
    id: page;

    title: qsTr("Novel");

    ViewHeader {
        id: viewHeader;
        title: page.title;
        Row {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; }
            ToolButton {
                iconSource: "toolbar-search";
                onClicked: pageStack.push(Qt.resolvedUrl("SearchPage.qml"), {"isNovel": true});
            }
            ToolButton {
                iconSource: "toolbar-menu";
                onClicked: signalCenter.selectSection(1);
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
        currentTab: rankingPage;
        Nov.RankingPage { id: rankingPage; pageStack: page.pageStack; }
        Nov.NewestPage { id: newestPage; pageStack: page.pageStack; }
        Nov.ContestsPage { id: contestsPage; pageStack: page.pageStack; }
    }

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "../gfx/favourite.svg";
            onClicked: tabGroup.currentTab = rankingPage;
        }
        ToolButton {
            iconSource: "../gfx/recent.svg";
            onClicked: tabGroup.currentTab = newestPage;
        }
        ToolButton {
            iconSource: "../gfx/group.svg";
            onClicked: tabGroup.currentTab = contestsPage;
        }
    }
}
