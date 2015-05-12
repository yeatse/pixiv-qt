import QtQuick 1.1
import com.nokia.symbian 1.1

AbstractDelegate {
    id: root;

    implicitHeight: Math.max(150, contentCol.height+constant.paddingLarge*2 );

    Rectangle {
        id: logoContainer;
        anchors { left: parent.left; top: root.paddingItem.top; }
        width: 120; height: 120;
        color: logo.status == Image.Ready ? "transparent" : "#616361";
        Image {
            id: logo;
            anchors.fill: parent;
            fillMode: Image.PreserveAspectFit;
            source: model.pic_thumbnail;
        }
    }
    Column {
        id: contentCol;
        anchors {
            left: logoContainer.right; top: root.paddingItem.top;
            right: root.paddingItem.right;
        }
        spacing: constant.paddingSmall;
        Text {
            anchors { left: parent.left; right: parent.right; }
            font: constant.titleFont;
            color: constant.colorLight;
            wrapMode: Text.Wrap;
            text: model.title;
        }
        Text {
            anchors { left: parent.left; right: parent.right; }
            font: constant.labelFont;
            color: constant.colorLight;
            wrapMode: Text.Wrap;
            elide: Text.ElideRight;
            text: model.contributor;
        }
        Text {
            font: constant.subTitleFont;
            color: constant.colorMid;
            text: qsTr("Pages")+"  "+model.pages;
        }
        Text {
            anchors { left: parent.left; right: parent.right; }
            font: constant.subTitleFont;
            color: constant.colorMid;
            wrapMode: Text.Wrap;
            text: qsTr("Tags")+"  "+model.tags;
        }
    }
}
