import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: root;

    property alias title: label.text;
    property QtObject platformStyle: SheetStyle {}

    z: 10;

    anchors { left: parent.left; right: parent.right; }
    implicitHeight: headerBackground.height;

    BorderImage {
        id: headerBackground
        border {
            left: platformStyle.headerBackgroundMarginLeft
            right: platformStyle.headerBackgroundMarginRight
            top: platformStyle.headerBackgroundMarginTop
            bottom: platformStyle.headerBackgroundMarginBottom
        }
        source: platformStyle.headerBackground
        width: root.width;
    }

    Image {
        id: icon;
        anchors {
           verticalCenter: parent.verticalCenter;
           left: parent.left;
           leftMargin: root.platformStyle.rejectButtonLeftMargin;
        }
        width: constant.graphicSizeSmall;
        height: constant.graphicSizeSmall;
        sourceSize: Qt.size(width, height);
        source: "../../gfx/icon.png";
    }

    Text {
        id: label;
        anchors {
            left: icon.right;
            leftMargin: root.platformStyle.rejectButtonLeftMargin;
            verticalCenter: parent.verticalCenter;
        }
        font: constant.titleFont;
        color: constant.colorLight;
        style: Text.Raised;
        styleColor: constant.colorMid;
    }
}
