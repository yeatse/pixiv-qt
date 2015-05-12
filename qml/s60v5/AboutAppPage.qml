import QtQuick 1.0
import com.nokia.symbian 1.0
import "Component"

MyPage {
    id: page;

    title: qsTr("About application");

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: pageStack.pop();
        }
    }

    Flickable {
        id: view;
        anchors.fill: parent;
        contentWidth: width;
        contentHeight: contentCol.height;

        Column {
            id: contentCol;
            anchors { left: parent.left; right: parent.right; }

            Item {
                anchors { left: parent.left; right: parent.right; }
                height: constant.graphicSizeLarge;
                Image {
                    id: logo;
                    anchors {
                        left: parent.left; top: parent.top;
                        bottom: parent.bottom; margins: constant.paddingLarge;
                    }
                    source: "../gfx/icon.png";
                    smooth: true;
                    fillMode: Image.PreserveAspectFit;
                }
                Text {
                    anchors {
                        left: logo.right; leftMargin: constant.paddingLarge;
                        verticalCenter: parent.verticalCenter;
                    }
                    font.pixelSize: platformStyle.fontSizeLarge + 2;
                    text: "Pixiv for symbian";
                    color: constant.colorLight;
                }
            }
            Text {
                anchors { right: parent.right; rightMargin: constant.paddingLarge; }
                font: constant.subTitleFont;
                text: qsTr("Version")+" "+appVersion;
                color: constant.colorMid;
            }
            Column {
                anchors { left: parent.left; right: parent.right; }
                spacing: constant.paddingLarge+4;
                DetailItem {
                    title: qsTr("Current user");
                    subTitle: psettings.userData.name;
                }
                Button {
                    width: parent.width * 2/3;
                    anchors.horizontalCenter: parent.horizontalCenter;
                    text: qsTr("Logout");
                    onClicked: signalCenter.logout()
                }
                DetailItem {
                    title: qsTr("Author");
                    subTitle: "Yeatse";
                }
                Text {
                    anchors.left: parent.left;
                    anchors.leftMargin: constant.paddingMedium;
                    font {
                        family: platformStyle.fontFamilyRegular;
                        pixelSize: platformStyle.fontSizeMedium;
                        bold: true;
                    }
                    color: constant.colorLight;
                    elide: Text.ElideRight;
                    text: qsTr("Contact me");
                }
                Item { width: 1; height: 1; }
            }
            Column {
                width: parent.width * 2/3;
                anchors.horizontalCenter: parent.horizontalCenter;
                spacing: constant.paddingMedium;
                Button {
                    width: parent.width;
                    text: qsTr("Baidu Tieba");
                    onClicked: Qt.openUrlExternally("http://tieba.baidu.com/p/2180383845");
                }
                Button {
                    width: parent.width;
                    text: qsTr("Sina Weibo");
                    onClicked: Qt.openUrlExternally("http://m.weibo.cn/u/1786664917");
                }
                Button {
                    width: parent.width;
                    text: qsTr("E-mail");
                    onClicked: Qt.openUrlExternally("mailto:iyeatse@gmail.com?subject="
                                                    +qsTr("Pixiv for symbian feedback")
                                                    +"&body=");
                }
            }
        }
    }
}
