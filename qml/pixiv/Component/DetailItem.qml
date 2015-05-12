import QtQuick 1.1
import com.nokia.symbian 1.1

MenuItem {
    id: root;

    property alias title: title.text;
    property alias subTitle: subTitle.text;

    enabled: false;

    Text {
        id: title;
        anchors {
            left: parent.left; top: parent.top; right: parent.right;
            margins: constant.paddingMedium;
        }
        font {
            family: platformStyle.fontFamilyRegular;
            pixelSize: platformStyle.fontSizeMedium;
            bold: true;
        }
        color: constant.colorLight;
        elide: Text.ElideRight;
    }

    Text {
        id: subTitle;
        anchors {
            left: parent.left; bottom: parent.bottom; right: parent.right;
            margins: constant.paddingMedium;
        }
        font: constant.subTitleFont;
        color: constant.colorLight;
        horizontalAlignment: Text.AlignRight;
        elide: Text.ElideRight;
    }
}
