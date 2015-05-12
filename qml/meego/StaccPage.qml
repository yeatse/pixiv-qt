import QtQuick 1.1
import com.nokia.meego 1.0
import "Component"

MyPage {
    id: page;

    title: qsTr("Stacc");

    ViewHeader {
        id: viewHeader;
        title: page.title;
        ToolButton {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; }
            iconSource: "toolbar-menu";
            onClicked: signalCenter.selectSection(3);
        }
    }
}
