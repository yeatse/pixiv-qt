import QtQuick 1.0
import com.nokia.symbian 1.0

QtObject {
    id: constant;

// public
    property color colorLight: platformStyle.colorNormalLight;
    property color colorMid: platformStyle.colorNormalMid;
    property color colorDisabled: platformStyle.colorDisabledLight;

    property int paddingSmall: platformStyle.paddingSmall;
    property int paddingMedium: platformStyle.paddingMedium;
    property int paddingLarge: platformStyle.paddingLarge;

    property int graphicSizeTiny: platformStyle.graphicSizeTiny;
    property int graphicSizeSmall: platformStyle.graphicSizeSmall;
    property int graphicSizeMedium: platformStyle.graphicSizeMedium;
    property int graphicSizeLarge: platformStyle.graphicSizeLarge;

    property variant labelFont: __label.font;
    property variant titleFont: __titleText.font;
    property variant subTitleFont: __subTitleText.font;

// private
    property ListItemText __titleText: ListItemText {}
    property ListItemText __subTitleText: ListItemText { role: "SubTitle"; }
    property Text __label: Text {
        font {
            pixelSize: platformStyle.fontSizeMedium;
            family: platformStyle.fontFamilyRegular;
        }
    }
}
