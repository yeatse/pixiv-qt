import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"

MyPage {
    id: page;

    property bool isNovel: false;
    property variant model: null;
    property int currentIndex: -1;

    title: qsTr("More");
    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: pageStack.pop();
        }
    }

    Image {
        id: background;
        clip: true;
        anchors.fill: parent;
        fillMode: Image.PreserveAspectCrop;
        sourceSize.height: 1000;
        source: model ? model.get(currentIndex).pic_medium : "";
        opacity: 0.5;
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
    }

    Loader {
        id: viewLoader;
        anchors { fill: parent; topMargin: viewHeader.height; }
        sourceComponent: model ? viewComp : undefined;
    }

    Component {
        id: viewComp;

        Flickable {
            id: view;
            anchors.fill: parent;
            contentWidth: width;
            contentHeight: contentCol.height;
            Column {
                id: contentCol;
                anchors { left: parent.left; right: parent.right; }
                Item { width: 1; height: constant.paddingLarge; }
                Text {
                    anchors {
                        left: parent.left; right: parent.right;
                        margins: constant.paddingMedium;
                    }
                    text: model.get(currentIndex).title;
                    font: constant.titleFont;
                    color: constant.colorLight;
                    style: Text.Raised;
                    styleColor: constant.colorMid;
                    wrapMode: Text.Wrap;
                }
                Item { width: 1; height: constant.paddingLarge; }
                DetailItem {
                    enabled: true;
                    title: qsTr("Contributor");
                    subTitle: model.get(currentIndex).contributor;
                    onClicked: {
                        var uid = model.get(currentIndex).uid;
                        var userName = model.get(currentIndex).contributor;
                        var avatarUrl = model.get(currentIndex).portrait;
                        var prop = { "uid": uid, "userName": userName, "avatarUrl": avatarUrl };
                        pageStack.push(Qt.resolvedUrl("UserPage.qml"), prop);
                    }
                }
                DetailItem {
                    title: qsTr("Date posted");
                    subTitle: model.get(currentIndex).date_posted;
                }
                Column {
                    anchors { left: parent.left; right: parent.right; }
                    spacing: constant.paddingMedium;
                    Text {
                        anchors { left: parent.left; leftMargin: constant.paddingMedium; }
                        font {
                            family: platformStyle.fontFamilyRegular;
                            pixelSize: platformStyle.fontSizeMedium;
                            bold: true;
                        }
                        color: constant.colorLight;
                        text: qsTr("Caption")
                    }
                    Rectangle {
                        anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium; }
                        height: captionText.height + constant.paddingMedium*2;
                        color: "#A0282828";
                        Text {
                            id: captionText;
                            anchors {
                                left: parent.left; right: parent.right; top: parent.top;
                                margins: constant.paddingMedium;
                            }
                            text: model.get(currentIndex).caption;
                            font: constant.subTitleFont;
                            color: constant.colorLight;
                            wrapMode: Text.Wrap;
                        }
                    }
                    Rectangle { width: parent.width; height: 1; color: constant.colorDisabled; }
                    Text {
                        anchors { left: parent.left; leftMargin: constant.paddingMedium; }
                        font {
                            family: platformStyle.fontFamilyRegular;
                            pixelSize: platformStyle.fontSizeMedium;
                            bold: true;
                        }
                        color: constant.colorLight;
                        text: qsTr("Tags")
                    }
                    Flow {
                        anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium; }
                        spacing: constant.paddingSmall;
                        Repeater {
                            model: page.model.get(currentIndex).tags.split(" ");
                            Button {
                                text: modelData;
                                onClicked: {
                                    var prop = { "word": modelData }
                                    var qmlfile = isNovel ? "Search/SearchNovelPage.qml" : "Search/SearchResultPage.qml"
                                    var p = pageStack.push(Qt.resolvedUrl(qmlfile), prop);
                                    p.getlist();
                                }
                            }
                        }
                    }
                    Rectangle { width: parent.width; height: 1; color: constant.colorDisabled; }
                    Text {
                        anchors { left: parent.left; leftMargin: constant.paddingMedium; }
                        font {
                            family: platformStyle.fontFamilyRegular;
                            pixelSize: platformStyle.fontSizeMedium;
                            bold: true;
                        }
                        color: constant.colorLight;
                        text: qsTr("Tools used");
                    }
                    Flow {
                        anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium; }
                        spacing: constant.paddingSmall;
                        Repeater {
                            model: page.model.get(currentIndex).tools_used.split(" ");
                            Rectangle {
                                width: toolsText.width + constant.paddingMedium*2;
                                height: toolsText.height + constant.paddingMedium*2;
                                color: "#A0282828";
                                Text {
                                    id: toolsText;
                                    anchors { left: parent.left; top: parent.top; margins: constant.paddingMedium; }
                                    text: modelData;
                                    font: constant.subTitleFont;
                                    color: constant.colorLight;
                                }
                            }
                        }
                    }
                    Rectangle { width: parent.width; height: 1; color: constant.colorDisabled; }
                }
                DetailItem {
                    title: qsTr("Views");
                    subTitle: model.get(currentIndex).views;
                }
                DetailItem {
                    title: qsTr("Rating");
                    subTitle: model.get(currentIndex).rating;
                }
                DetailItem {
                    title: qsTr("Score");
                    subTitle: model.get(currentIndex).score;
                }
                DetailItem {
                    title: qsTr("Bookmarks");
                    subTitle: model.get(currentIndex).bookmarks;
                }
                DetailItem {
                    title: qsTr("Comments");
                    subTitle: model.get(currentIndex).comments;
                }
            }
            ScrollDecorator { flickableItem: view; }
        }
    }
}
