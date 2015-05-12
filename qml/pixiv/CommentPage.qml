import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "../js/main.js" as Script

MyPage {
    id: page;

    property bool isNovel: false;
    property string illustId;
    onIllustIdChanged: internal.getCount();

    title: qsTr("List of comment");

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: pageStack.pop();
        }
    }

    QtObject {
        id: internal;

        property int totalNumber: 0;
        property int currentPage: 0;

        function getCount(){
            loading = true;
            view.model.clear();
            currentPage = 0;

            var opt = {"illust_id": illustId, "isNovel": isNovel};
            function s(resp){
                loading = false;
                totalNumber = parseInt(resp);
                getlist();
            }
            function f(err){
                loading = false;
                signalCenter.showMessage(err);
            }
            Script.getComment(opt, s, f);
        }

        function getlist(option){
            if (currentPage >= Math.ceil(totalNumber/50)) return;
            loading = true;
            if (view.count == 0) option = "renew";
            option = option || "renew";
            var opt = {"illust_id": illustId, "isNovel": isNovel, "model": view.model};
            if (option == "renew"){
                opt.renew = true;
                currentPage = 1;
                opt.p = 1;
            } else {
                opt.p = currentPage + 1;
            }
            function s(p){ currentPage = p; loading = false; }
            function f(err){ signalCenter.showMessage(err); loading = false; }
            Script.getComment(opt, s, f);
        }

        function addComment(){
            loading = true;
            var mode = isNovel ? "novel" : "illust";
            var opt = {"mode": mode, "illust_id": illustId, "comment": commentField.text};
            function s(resp){
                loading = false;
                signalCenter.showMessage(resp);
                getCount();
            }
            function f(err){
                loading = false;
                signalCenter.showMessage(err);
            }
            Script.addComment(opt, s, f);
        }
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
    }

    ListView {
        id: view;

        property bool __aboutToNext: false;

        anchors {
            left: parent.left; right: parent.right;
            top: viewHeader.bottom; bottom: commentArea.top;
        }
        model: ListModel {}
        delegate: commentDelegate;
        onAtYEndChanged: {
            if (view.count > 0 && atYEnd && !page.loading) __aboutToNext = true;
        }
        onMovementEnded: {
            if (__aboutToNext && !page.loading){
                __aboutToNext = false;
                internal.getlist("next");
            }
        }
        Component {
            id: commentDelegate;
            ListItem {
                id: root;

                implicitHeight: contentCol.height + constant.paddingLarge*2;

                Image {
                    id: avatar;
                    anchors {
                        left: root.paddingItem.left;
                        top: root.paddingItem.top;
                    }
                    width: 50; height: 50;
                    source: model.portrait;
                }

                Column {
                    id: contentCol;
                    anchors {
                        left: avatar.right; leftMargin: constant.paddingSmall;
                        top: root.paddingItem.top;
                        right: root.paddingItem.right;
                    }
                    spacing: constant.paddingSmall;
                    Text {
                        text: model.contributor;
                        font: constant.labelFont;
                        color: constant.colorMid;
                    }
                    Text {
                        anchors { left: parent.left; right: parent.right; }
                        wrapMode: Text.Wrap;
                        font: constant.labelFont;
                        color: constant.colorLight;
                        text: model.content;
                    }
                    Text {
                        font: constant.subTitleFont;
                        color: constant.colorMid;
                        text: model.date_posted;
                    }
                }
            }
        }
    }

    ScrollDecorator { flickableItem: view; }

    Button {
        anchors.centerIn: parent;
        visible: !loading && view.count == 0;
        text: qsTr("Reload");
        onClicked: internal.getCount();
    }

    Item {
        id: commentArea;
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; }
        height: commentField.height;
        enabled: !loading;
        TextField {
            id: commentField;
            anchors {
                left: parent.left; right: commentButton.left;
                rightMargin: constant.paddingSmall;
            }
            placeholderText: qsTr("Input comment");
        }
        Button {
            id: commentButton;
            anchors {
                right: parent.right; verticalCenter: commentField.verticalCenter;
            }
            text: qsTr("Comment");
            enabled: commentField.text.length > 0;
            onClicked: internal.addComment();
        }
    }
}
