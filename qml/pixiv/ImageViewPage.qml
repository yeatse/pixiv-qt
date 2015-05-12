import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "../js/main.js" as Script

MyPage {
    id: page;

    property Item parentView: null;
    onStatusChanged: {
        if (status == PageStatus.Active){
            view.positionViewAtIndex(parentView.currentIndex, ListView.Center);
        } else if (status == PageStatus.Deactivating){
            parentView.positionViewAtIndex(view.currentIndex, ListView.Contain);
            parentView.currentIndex = view.currentIndex;
            page.state = "";
        }
    }

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolButton {
            iconSource: "../gfx/add_bookmark.svg";
            enabled: view.currentItem != null;
            onClicked: {
                addBookmarkMenu.isBookmark = true;
                addBookmarkMenu.open();
            }
        }
        ToolButton {
            iconSource: "../gfx/favourite.svg";
            enabled: view.currentItem != null;
            onClicked: {
                addBookmarkMenu.isBookmark = false;
                addBookmarkMenu.open();
            }
        }
        ToolButton {
            iconSource: "toolbar-menu";
            enabled: view.currentItem != null;
            onClicked: {
                if (!internal.imageMenu){
                    internal.imageMenu = imageMenuComp.createObject(page);
                }
                internal.imageMenu.open();
            }
        }
    }

    QtObject {
        id: internal;

        property variant imageMenu: null;

        function setText(){
            if (view.currentIndex < 0) return;

            var data = view.model.get(view.currentIndex);
            topBannerTitle.text = "(%1/%2) %3\n%4".arg(view.currentIndex+1).arg(view.count).arg(data.title).arg(data.contributor);
        }

        function addBookmark(isPrivate){
            loading = true;
            var pid = internal.getPid();
            var restrict = isPrivate ? 1 : 0;
            var opt = {"illust_id": pid, "restrict": restrict};
            function r(resp){ signalCenter.showMessage(resp); loading = false; }
            Script.addBookmark(opt, r, r);
        }

        function addRating(){
            loading = true;
            var pid = internal.getPid();
            var score = 10;
            var opt = {"illust_id": pid, "score": score};
            function r(resp){ signalCenter.showMessage(resp); loading = false; }
            Script.addRating(opt, r, r);
        }

        function getPid(){
            return view.model.get(view.currentIndex).pid;
        }
    }

    //main menu
    Component {
        id: imageMenuComp;
        Menu {
            id: imageMenu;
            MenuLayout {
                MenuItemWithIcon {
                    iconSource: "../gfx/toolbar_extension.svg";
                    text: qsTr("More");
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("IllustDetailPage.qml"),
                                       {"currentIndex": view.currentIndex, "model": view.model});
                    }
                }
                MenuItemWithIcon {
                    iconSource: "../gfx/instant_messenger_chat.svg";
                    text: qsTr("Comments");
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("CommentPage.qml"), {"illustId": internal.getPid()})
                    }
                }
                MenuItemWithIcon {
                    iconSource: "../gfx/save.svg";
                    text: qsTr("Save image");
                    onClicked: {
                        signalCenter.saveImage(view.model.get(view.currentIndex).pic_medium,
                                               internal.getPid(),
                                               view.model.get(view.currentIndex).format);
                    }
                }
                MenuItemWithIcon {
                    iconSource: privateStyle.toolBarIconPath("toolbar-share");
                    text: qsTr("Share");
                    onClicked: {
                        var pid = internal.getPid();
                        var msg = "http://p.tl/i/" + pid + " #pixiv"
                        Qt.openUrlExternally("sms:?body=" + msg);
                    }
                }
                MenuItemWithIcon {
                    iconSource: "../gfx/internet.svg";
                    text: qsTr("View on browser");
                    onClicked: {
                        Qt.openUrlExternally("http://touch.pixiv.net/member_illust.php?mode=medium&illust_id="
                                             +internal.getPid());
                    }
                }
            }
        }
    }

    // rating menu
    ContextMenu {
        id: addBookmarkMenu;
        property bool isBookmark: true;
        MenuLayout {
            MenuItem {
                visible: addBookmarkMenu.isBookmark;
                text: qsTr("Add public bookmark");
                onClicked: internal.addBookmark(false);
            }
            MenuItem {
                visible: addBookmarkMenu.isBookmark;
                text: qsTr("Add private bookmark");
                onClicked: internal.addBookmark(true);
            }
            MenuItem {
                visible: !addBookmarkMenu.isBookmark;
                text: qsTr("Rate it (10 points)");
                onClicked: internal.addRating();
            }
        }
    }

    // main view
    ListView {
        id: view;
        clip: true;
        anchors.fill: parent;
        onCurrentIndexChanged: internal.setText();
        cacheBuffer: screen.width;
        preferredHighlightBegin: 0;
        preferredHighlightEnd: view.width;
        highlightMoveDuration: 250;
        highlightRangeMode: ListView.StrictlyEnforceRange;
        snapMode: ListView.SnapOneItem;
        orientation: ListView.Horizontal;
        model: parentView ? parentView.model : null;
        delegate: viewDelegate;

        Component {
            id: viewDelegate;
            Flickable {
                id: root;

                property alias imageStatus: mediumPic.status;
                property alias loadingProgress: mediumPic.progress;

                function zoomIn(){
                    bounceBackAnimation.to = mediumPic.scale < 1 ? 1 : pinchArea.maxScale;
                    bounceBackAnimation.start();
                }
                function zoomOut(){
                    bounceBackAnimation.to = pinchArea.minScale;
                    bounceBackAnimation.start();
                }
                function reload(){
                    mediumPic.source = "";
                    mediumPic.source = model.pic_medium;
                }

                clip: true;

                implicitWidth: ListView.view.width;
                implicitHeight: ListView.view.height;

                contentWidth: imageContainer.width;
                contentHeight: imageContainer.height;

                onHeightChanged: if (mediumPic.status == Image.Ready) mediumPic.fitToScreen();

                Item {
                    id: imageContainer;

                    width: Math.max(mediumPic.width * mediumPic.scale, root.width);
                    height: Math.max(mediumPic.height * mediumPic.scale, root.height);

                    Image {
                        id: mediumPic;

                        property real prevScale;

                        function fitToScreen() {
                            scale = Math.min(root.width / width, root.height / height, 1)
                            pinchArea.minScale = scale
                            prevScale = scale
                        }

                        anchors.centerIn: parent;
                        fillMode: Image.PreserveAspectFit;
                        source: model.pic_medium;
                        sourceSize.height: 1000;
                        smooth: !root.moving;

                        onStatusChanged: {
                            if (status == Image.Ready){
                                fitToScreen();
                                loadedAnimation.start();
                            }
                        }

                        NumberAnimation {
                            id: loadedAnimation
                            target: mediumPic;
                            property: "opacity"
                            duration: 250
                            from: 0; to: 1
                            easing.type: Easing.InOutQuad
                        }

                        onScaleChanged: {
                            if ((width * scale) > root.width) {
                                var xoff = (root.width / 2 + root.contentX) * scale / prevScale;
                                root.contentX = xoff - root.width / 2
                            }
                            if ((height * scale) > root.height) {
                                var yoff = (root.height / 2 + root.contentY) * scale / prevScale;
                                root.contentY = yoff - root.height / 2
                            }
                            prevScale = scale
                        }
                    }
                }

                PinchArea {
                    id: pinchArea

                    property real minScale: 1.0
                    property real maxScale: 3.0

                    anchors.fill: parent
                    enabled: mediumPic.status === Image.Ready
                    pinch.target: mediumPic
                    pinch.minimumScale: minScale * 0.5 // This is to create "bounce back effect"
                    pinch.maximumScale: maxScale * 1.5 // when over zoomed

                    onPinchFinished: {
                        root.returnToBounds()
                        if (mediumPic.scale < pinchArea.minScale) {
                            bounceBackAnimation.to = pinchArea.minScale
                            bounceBackAnimation.start()
                        }
                        else if (mediumPic.scale > pinchArea.maxScale) {
                            bounceBackAnimation.to = pinchArea.maxScale
                            bounceBackAnimation.start()
                        }
                    }

                    NumberAnimation {
                        id: bounceBackAnimation
                        target: mediumPic
                        duration: 250
                        property: "scale"
                        from: mediumPic.scale
                    }
                }

                MouseArea {
                    anchors.fill: parent;
                    visible: mediumPic.status == Image.Ready || thumbnailPic.status == Image.Ready;
                    onClicked: page.state == "" ? page.state = "fullScreen" : page.state = "";
                }

                ScrollDecorator { flickableItem: root; }

                Image {
                    id: thumbnailPic;
                    anchors.fill: parent;
                    fillMode: Image.PreserveAspectFit;
                    source: mediumPic.status == Image.Ready ? "" : model.pic_thumbnail;
                    visible: mediumPic.status != Image.Ready;
                }
            }
        }
    }

    // ViewHeader
    Column {
        id: viewHeader;
        anchors { left: parent.left; right: parent.right; top: parent.top; }
        z: 10;
        ViewHeader {
            title: page.title;
        }
        Rectangle {
            anchors { left: parent.left; right: parent.right; }
            height: constant.graphicSizeLarge;
            color: "#A0463D3B"
            Text {
                id: topBannerTitle;
                anchors.fill: parent;
                font: constant.labelFont;
                color: constant.colorLight;
                style: Text.Raised;
                styleColor: constant.colorMid;
                wrapMode: Text.Wrap;
                horizontalAlignment: Text.AlignHCenter;
                verticalAlignment: Text.AlignVCenter;
            }
        }
    }

    //navi controls
    MouseArea {
        id: leftButton;
        anchors { left: parent.left; verticalCenter: parent.verticalCenter; }
        visible: view.currentIndex > 0;
        width: childrenRect.width;
        height: childrenRect.height;
        onClicked: view.decrementCurrentIndex();
        Image {
            source: "../gfx/button_prev_"+(parent.pressed?"pressed":"normal")+".png";
        }
    }
    MouseArea {
        id: rightButton;
        anchors { right: parent.right; verticalCenter: parent.verticalCenter; }
        visible: view.currentIndex >= 0 && view.currentIndex < view.count-1;
        width: childrenRect.width;
        height: childrenRect.height;
        onClicked: view.incrementCurrentIndex();
        Image {
            source: "../gfx/button_next_"+(parent.pressed?"pressed":"normal")+".png"
        }
    }

    //zoom button
    ButtonRow {
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; }
        visible: view.currentItem != null
                 && view.model.get(view.currentIndex).pages == ""
                 && view.currentItem.imageStatus == Image.Ready;
        ToolButton {
            iconSource: "../gfx/zoom_in.svg";
            onClicked: {
                page.state = "fullScreen";
                view.currentItem.zoomIn();
            }
        }
        ToolButton {
            iconSource: "../gfx/zoom_out.svg";
            onClicked: {
                view.currentItem.zoomOut();
            }
        }
    }

    //manga button
    Button {
        anchors {
            horizontalCenter: parent.horizontalCenter;
            bottom: progressBar.top;
        }
        width: height;
        visible: view.currentItem != null
                 && view.model.get(view.currentIndex).pages != ""
        iconSource: "../gfx/view_pages.svg";
        onClicked: {
            pageStack.push(Qt.resolvedUrl("MangaViewPage.qml"),
                           {"illustId": internal.getPid()});
        }
    }

    //reload button
    ToolButton {
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; }
        visible: view.currentItem != null && view.currentItem.imageStatus == Image.Error;
        iconSource: "toolbar-refresh";
        onClicked: view.currentItem.reload();
    }

    ProgressBar {
        id: progressBar;
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; }
        visible: view.currentItem != null && view.currentItem.imageStatus == Image.Loading;
        value: visible ? view.currentItem.loadingProgress : 0;
    }

    states: [
        State {
            name: "fullScreen";
            AnchorChanges { target: viewHeader; anchors.top: undefined; anchors.bottom: page.top; }
            AnchorChanges { target: leftButton; anchors.left: undefined; anchors.right: page.left; }
            AnchorChanges { target: rightButton; anchors.right: undefined; anchors.left: page.right; }
            PropertyChanges { target: app; showToolBar: false; }
        }
    ]
    transitions: [
        Transition {
            AnchorAnimation { duration: 200; }
        }
    ]
}
