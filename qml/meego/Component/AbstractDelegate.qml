import QtQuick 1.1
import com.nokia.meego 1.0
import "../Component"

Item {
    id: root;

    property alias paddingItem: paddingItem;

    signal clicked;
    signal pressAndHold;

    implicitWidth: ListView.view ? ListView.view.width : 0;
    implicitHeight: constant.graphicSizeLarge;

    Item {
        id: paddingItem;
        anchors {
            left: parent.left; leftMargin: constant.paddingLarge;
            right: parent.right; rightMargin: constant.paddingLarge;
            top: parent.top; topMargin: constant.paddingLarge;
            bottom: parent.bottom; bottomMargin: constant.paddingLarge;
        }
    }

    Loader {
        id: highlightLoader;
        anchors.fill: parent;
        Component {
            id: highlightComp;
            Image {
                visible: mouseArea.pressed;
                source: theme.inverted ? "image://theme/meegotouch-panel-inverted-background-pressed"
                                       : "image://theme/meegotouch-panel-background-pressed";
            }
        }
    }

    MouseArea {
        id: mouseArea;
        anchors.fill: parent;
        onClicked: root.clicked();
        onPressAndHold: root.pressAndHold();
        onPressed: if (highlightLoader.status == Loader.Null)
                       highlightLoader.sourceComponent = highlightComp;
    }

    NumberAnimation {
        id: onAddAnimation
        target: root
        property: "scale"
        duration: 250
        from: 0.25; to: 1
        easing.type: Easing.OutBack
    }

    ListView.onAdd: {
        onAddAnimation.start();
    }
}
