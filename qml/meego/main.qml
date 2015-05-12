import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import com.yeatse.pixiv 1.0
import "../js/main.js" as Script

PageStackWindow {
    id: app;

    showStatusBar: true;
    showToolBar: pageStack.currentPage != welcomePage;

    initialPage: WelcomePage { id: welcomePage; }

    PixivService { id: pixiv; }

    PSettings { id: psettings; }

    Constant { id: constant; }

    WorkerScript { id: worker; source: "../js/Parser.js"; }

    SignalCenter { id: signalCenter; }

    InfoBanner { id: infoBanner; topMargin: 36; }

    InfoBanner {
        id: downloadInfoBanner;
        timerEnabled: false;
        topMargin: 36;
        text: qsTr("Loading image: %1%(Click to cancel)").arg(Math.floor(downloader.progress*100))
        MouseArea {
            anchors.fill: parent;
            onClicked: downloader.abortDownload(false);
        }
    }

    Connections {
        target: downloader;
        onStateChanged: {
            if (downloader.state == 1){
                downloadInfoBanner.show();
            } else if (downloader.state == 3){
                downloadInfoBanner.hide();
                if (downloader.error == 0){
                    Qt.openUrlExternally("file:///"+downloader.currentFile);
                } else if (downloader.error != 5) {
                    if (signalCenter.currentMiddlePic != ""){
                        signalCenter.startDownload(signalCenter.currentMiddlePic,
                                                   signalCenter.currentSavePath);
                        signalCenter.currentMiddlePic = "";
                    }
                }
            }
        }
    }

    Component.onCompleted: Script.initialize(worker, signalCenter);
}
