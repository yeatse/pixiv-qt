import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: root;

    property string title;
    property bool loading: false;
    property bool timeoutEnabled: true;

    onLoadingChanged: {
        if (timeoutEnabled){
            if (loading) timeoutTimer.restart();
            else timeoutTimer.stop();
        }
    }

    orientationLock: PageOrientation.LockPortrait;

    BusyIndicator {
        id: busyInd;
        z: 10001;
        anchors.centerIn: parent;
        visible: root.loading;
        running: true;
        width: constant.graphicSizeLarge;
        height: constant.graphicSizeLarge;
    }

    Timer {
        id: timeoutTimer;
        interval: 40000;
        onTriggered: root.loading = false;
    }
}
