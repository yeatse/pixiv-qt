import QtQuick 1.1
import com.nokia.symbian 1.1

Rectangle {
    id: root;

    property alias title: label.text;

    z: 10;
    anchors { left: parent.left; right: parent.right; }
    implicitHeight: 48;

    gradient: Gradient {
        GradientStop { position: 0.0; color: "#696964" }
        GradientStop { position: 1.0; color: "#373732" }
    }

    Image {
        id: icon;
        anchors {
           verticalCenter: parent.verticalCenter; left: parent.left;
           leftMargin: constant.paddingMedium;
        }
        width: constant.graphicSizeSmall;
        height: constant.graphicSizeSmall;
        sourceSize: Qt.size(width, height);
        source: "../../gfx/icon.png";
    }

    Text {
        id: label;
        anchors {
            left: icon.right; leftMargin: constant.paddingMedium;
            verticalCenter: parent.verticalCenter;
        }
        font: constant.titleFont;
        color: constant.colorLight;
        style: Text.Raised;
        styleColor: constant.colorMid;
    }
}
