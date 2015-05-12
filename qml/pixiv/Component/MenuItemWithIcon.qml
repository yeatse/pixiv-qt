import QtQuick 1.1
import com.nokia.symbian 1.1

MenuItem {
    id: root;

    property alias iconSource: icon.source;
    platformLeftMargin: 2 * platformStyle.paddingMedium + platformStyle.graphicSizeSmall;

    Image {
        id: icon;
        anchors {
            left: parent.left;
            leftMargin: platformStyle.paddingMedium;
            verticalCenter: parent.verticalCenter;
        }
        sourceSize: Qt.size(platformStyle.graphicSizeSmall,
                            platformStyle.graphicSizeSmall)
    }
}
