import QtQuick 1.1

Item {
    id: root;

    signal clicked;

    implicitWidth: GridView.view.cellWidth;
    implicitHeight: GridView.view.cellHeight;

    Image {
        id: thumbnail;
        anchors { fill: parent; margins: 1; }
        source: model.pic_thumbnail;
    }

    Image {
        id: placeHolder;
        anchors.centerIn: parent;
        source: "../../gfx/loading.png";
        visible: thumbnail.status != Image.Ready;
    }

    Rectangle {
        anchors.fill: parent;
        color: constant.colorDisabled;
        opacity: mouseArea.pressed ? 0.5 : 0;
    }

    MouseArea {
        id: mouseArea;
        anchors.fill: parent;
        onClicked: {
            root.GridView.view.currentIndex = index;
            root.clicked();
        }
    }
}
