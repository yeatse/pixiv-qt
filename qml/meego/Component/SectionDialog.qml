import QtQuick 1.1
import com.nokia.meego 1.0

SelectionDialog {
    id: root;

    property int prevIndex: 0;
    property bool __isClosing: false;

    titleText: qsTr("Select section");

    model: ListModel {}

    Component.onCompleted: {
        var list = [[qsTr("Illustration"), Qt.resolvedUrl("../IllustrationPage.qml")],
                    [qsTr("Novel"), Qt.resolvedUrl("../NovelPage.qml")],
                    [qsTr("Bookmark"), Qt.resolvedUrl("../BookmarkPage.qml")],
                    // not supported:
                    //[qsTr("Stacc"), Qt.resolvedUrl("../StaccPage.qml")],
                    [qsTr("My Page"), Qt.resolvedUrl("../MyPage.qml")]]
        list.forEach(function(item){
                         model.append({"modelData": item[0],"name": item[0],"filename": item[1]})
                     });
        selectedIndex = 0;
        open();
    }

    onAccepted: {
        if (prevIndex != selectedIndex){
            app.pageStack.replace(model.get(selectedIndex).filename);
            prevIndex = selectedIndex;
        }
    }

    onStatusChanged: {
        if (status == DialogStatus.Opening){
            selectedIndex = prevIndex;
        } else if (status == DialogStatus.Closing){
            __isClosing = true;
        } else if (status == DialogStatus.Closed && __isClosing){
            root.destroy(1000);
        }
    }
}
