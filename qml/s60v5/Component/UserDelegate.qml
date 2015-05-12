import QtQuick 1.0

AbstractDelegate {
    id: root;

    implicitHeight: 58 + constant.paddingLarge*2;

    Row {
        anchors.fill: parent.paddingItem;
        spacing: constant.paddingMedium;
        Rectangle {
            width: 58; height: 58;
            color: logo.status == Image.Ready ? "transparent" : "#616361";
            Image {
                id: logo;
                anchors.fill: parent;
                fillMode: Image.PreserveAspectFit;
                source: model.avatar;
            }
        }

        Text {
            text: model.contributor;
            font: constant.titleFont;
            color: constant.colorLight;
        }
    }
}
