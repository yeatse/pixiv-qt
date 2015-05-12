import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "../js/main.js" as Script

MyPage {
    id: page;

    Connections {
        target: signalCenter;
        onInitialized: {
            autoLoginTimer.stop();
            if (psettings.username != "" && psettings.password != ""){
                page.loading = true;
                unInput.text = psettings.username;
                pwInput.text = psettings.password;
                autoLoginTimer.restart();
            } else {
                internal.getlist();
            }
        }
    }

    Connections {
        target: pixiv;
        onPhpsessidChanged: Script.phpsessid = pixiv.phpsessid;
        onLoginFinished: {
            page.loading = false;
            psettings.username = unInput.text;
            psettings.password = pwInput.text;
            psettings.userData = pixiv.userData;
            if (page.status == PageStatus.Active){
                pageStack.push(Qt.resolvedUrl("IllustrationPage.qml"));
            }
        }
        onLoginFailed: {
            page.loading = false;
            autoLoginTimer.stop();
            signalCenter.showMessage(qsTr("Login failed!"));
        }
    }

    // login timer;
    // refresh token every 50 minutes;
    Timer {
        id: autoLoginTimer;
        interval: 50*60*1000;
        repeat: true;
        triggeredOnStart: true;
        onTriggered: {
            page.loading = true;
            pixiv.login(unInput.text, pwInput.text);
        }
    }

    QtObject {
        id: internal;

        function getlist(){
            var opt = {"mode": "day", "content": "illust", "p": 1, "model": view.model, "renew": true};
            function f(err){ signalCenter.showMessage(err); }
            Script.getRanking(opt, new Function(), f);
        }
    }

    Rectangle {
        id: bgRect;
        anchors.fill: parent;
        gradient: Gradient {
            GradientStop { position: 0; color: "#8ACEEE"; }
            GradientStop { position: 1; color: "#0065BB"; }
        }
    }

    ListView {
        id: view;
        anchors.fill: parent;
        clip: true;
        interactive: false;
        cacheBuffer: parent.width;
        snapMode: ListView.SnapOneItem;
        orientation: ListView.Horizontal;
        model: ListModel {}

        function setOpacity(){
            var x = view.mapFromItem(view.currentItem, 0, 0).x;
            view.opacity = Math.cos(x/view.width * 2 * Math.PI);
        }

        onContentXChanged: setOpacity();

        delegate: background;
        Component {
            id: background;
            Image {
                id: backgroundImage;
                opacity: 0;
                Behavior on opacity { NumberAnimation { duration: 200; } }
                clip: true;
                smooth: true;
                width: ListView.view.width;
                height: ListView.view.height;
                fillMode: Image.PreserveAspectCrop;
                source: model.pic_medium;
                onStatusChanged: { if (status == Image.Ready) opacity = 1; }

                Column {
                    anchors {
                        left: parent.left; right: parent.right; top: parent.top;
                        margins: constant.paddingLarge;
                    }
                    spacing: constant.paddingSmall;
                    Text {
                        anchors { left: parent.left; right: parent.right; }
                        text: qsTr("Illust")+": "+model.title+" by "+model.contributor;
                        font: constant.labelFont;
                        wrapMode: Text.Wrap;
                        color: constant.colorLight;
                        style: Text.Raised;
                        styleColor: constant.colorMid;
                    }
                    Text {
                        anchors { left: parent.left; right: parent.right; }
                        text: model.date_posted+" "+qsTr("Daily ranking")+" No."+model.ranking;
                        font: constant.labelFont;
                        wrapMode: Text.Wrap;
                        color: constant.colorLight;
                        style: Text.Raised;
                        styleColor: constant.colorMid;
                    }
                }
            }
        }
    }

    Timer {
        id: timer;
        interval: 8000;
        repeat: true;
        running: page.visible
                 && Qt.application.active
                 && view.count > 0
                 && view.currentItem.status != Image.Loading;
        onTriggered: {
            if (view.currentIndex == view.count-1) view.positionViewAtBeginning();
            else view.incrementCurrentIndex();
        }
    }

    Column {
        anchors {
            horizontalCenter: parent.horizontalCenter;
            bottom: parent.bottom;
            bottomMargin: constant.paddingLarge * 2;
        }
        spacing: constant.paddingLarge * 2;
        Image {
            anchors.horizontalCenter: parent.horizontalCenter;
            width: page.width / 3 * 2;
            fillMode: Image.PreserveAspectFit;
            source: "../gfx/logo.png";
            smooth: true;
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter;
            font: constant.labelFont;
            color: constant.colorLight;
            style: Text.Raised;
            styleColor: constant.colorMid;
            text: qsTr("It's fun drawing!");
        }
        Item { width: 1; height:1 }
        Button {
            anchors.horizontalCenter: parent.horizontalCenter;
            width: page.width / 2;
            enabled: !page.loading;
            text: qsTr("Login");
            onClicked: loginDialog.open();
        }
    }

    CommonDialog {
        id: loginDialog;
        titleText: qsTr("Log in pixiv");
        titleIcon: "../gfx/accounts.svg";
        content: Column {
            anchors {
                left: parent.left; right: parent.right;
                margins: constant.paddingLarge;
            }
            spacing: constant.paddingLarge;
            Item { width: 1; height: 1; }
            TextField {
                id: unInput;
                anchors { left: parent.left; right: parent.right; }
                placeholderText: qsTr("pixiv ID");
                enabled: !page.loading;
                inputMethodHints: Qt.ImhNoAutoUppercase;
            }
            TextField {
                id: pwInput;
                anchors { left: parent.left; right: parent.right; }
                placeholderText: qsTr("Password");
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText;
                echoMode: TextInput.Password;
                enabled: !page.loading;
            }
            Item { width: 1; height: 1; }
        }
        buttonTexts: [qsTr("Login")];
        onClickedOutside: close();
        onButtonClicked: {
            if (unInput.text != "" && pwInput.text != ""){
                autoLoginTimer.restart();
            }
        }
    }
}
