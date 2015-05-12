import QtQuick 1.0

QtObject {
    id: signalCenter;

    property variant sectionDialogComp: null;
    property variant imageLoaderComp: null;

    signal initialized;

    function showMessage(msg){
        if (msg||false){
            infoBanner.text = msg;
            infoBanner.open();
        }
    }

    function selectSection(currentIndex){
        if (!sectionDialogComp){ sectionDialogComp = Qt.createComponent("Component/SectionDialog.qml"); }
        var diag = sectionDialogComp.createObject(pageStack.currentPage);
        diag.prevIndex = currentIndex;
    }

    function logout(){
        pageStack.pop(welcomePage);
        psettings.username = "";
        psettings.password = "";
        initialized();
    }

    property string currentMiddlePic: "";
    property string currentSavePath: "";

    function saveImage(middlePic, pid, format){
        console.log(middlePic, pid, format)
        var url;
        var tmplist = middlePic.split("/mobile/");
        if (tmplist.length == 2) {
            url = tmplist[0] + "/" + pid + "." + format;
        } else {
            var idx = middlePic.lastIndexOf("/");
            url = middlePic.substring(0, idx + 1);
            url = url.replace("c/480x960/img-master", "img-original");
            if (pid.indexOf("_") < 0) {
                url += pid + "_p0." + format;
            } else {
                url += pid + "." + format;
            }
        }
        var path = psettings.imageFolder + "/" + pid + "." + format;
        currentMiddlePic = middlePic;
        currentSavePath = path;
        startDownload(url, path);
    }

    function startDownload(source, target){
        if (downloader.currentRequest != source && !downloader.existsRequest(source)){
            downloader.appendDownload(source, target);
            signalCenter.showMessage(qsTr("Added to download list"));
        }
    }
}
