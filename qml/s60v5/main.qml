import QtQuick 1.0
import com.nokia.symbian 1.0
import com.nokia.extras 1.0
import com.yeatse.pixiv 1.0
import "../js/main.js" as Script
import "Component"

PageStackWindow {
    id: app;

    showStatusBar: true;
    showToolBar: true;

    initialPage: WelcomePage { id: welcomePage; }

    PixivService { id: pixiv; }

    PSettings { id: psettings; }

    Constant { id: constant; }

    WorkerScript { id: worker; source: "../js/Parser.js"; }

    SignalCenter { id: signalCenter; }

    InfoBanner { id: infoBanner; }

    InfoBanner {
        id: downloadInfoBanner;
        iconSource: "../gfx/icon.png";
        timeout: 0;
        interactive: true;
        text: qsTr("Loading image: %1%(Click to cancel)").arg(Math.floor(downloader.progress*100))
        onClicked: downloader.abortDownload(false);
    }

    Connections {
        target: downloader;
        onStateChanged: {
            if (downloader.state == 1){
                downloadInfoBanner.open();
            } else if (downloader.state == 3){
                downloadInfoBanner.close();
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
