import QtQuick 1.1
import com.nokia.meego 1.0

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
        platformStyle: BusyIndicatorStyle { size: "large"; }
    }

    Timer {
        id: timeoutTimer;
        interval: 40000;
        onTriggered: root.loading = false;
    }
}
