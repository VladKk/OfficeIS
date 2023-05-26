import QtQuick
import QtQuick.Controls

import gui
import common as Common

ApplicationWindow {
    id: rootWindow

    visible: true
    width: Global.appData.windowWidth
    height: Global.appData.windowHeight

    minimumWidth: 800
    minimumHeight: 600
    title: qsTr( "OfficeIS" )

    flags: Qt.FramelessWindowHint |
           Qt.WindowMaximizeButtonHint |
           Qt.Window

    property int bw: 5

    // The mouse area is just for setting the required cursor shape
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: {
            const p = Qt.point(mouseX, mouseY);
            const b = bw + 10; // Increase the corner size slightly
            if (p.x < b && p.y < b) return Qt.SizeFDiagCursor;
            if (p.x >= width - b && p.y >= height - b) return Qt.SizeFDiagCursor;
            if (p.x >= width - b && p.y < b) return Qt.SizeBDiagCursor;
            if (p.x < b && p.y >= height - b) return Qt.SizeBDiagCursor;
            if (p.x < b || p.x >= width - b) return Qt.SizeHorCursor;
            if (p.y < b || p.y >= height - b) return Qt.SizeVerCursor;
        }
        acceptedButtons: Qt.NoButton // don't handle actual events
        Rectangle {
            id: _header_back
            color: _page.header.color
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: _page.header.height + bw
        }
        Rectangle {
            color: Style.bgColor
            anchors.top: _header_back.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height - _header_back.height
        }
    }

    DragHandler {
        id: resizeHandler
        grabPermissions: TapHandler.TakeOverForbidden
        target: null
        onActiveChanged: if (active) {
                             const p = resizeHandler.centroid.position;
                             const b = bw + 10; // Increase the corner size slightly
                             let e = 0;
                             if (p.x < b) { e |= Qt.LeftEdge }
                             if (p.x >= width - b) { e |= Qt.RightEdge }
                             if (p.y < b) { e |= Qt.TopEdge }
                             if (p.y >= height - b) { e |= Qt.BottomEdge }
                             rootWindow.startSystemResize(e);
                         }
    }

    Page {
        id: _page
        anchors.fill: parent
        anchors.margins: rootWindow.visibility === Window.Windowed ? bw : 0

        background: Rectangle {
            color: Style.bgColor
        }

        header: Rectangle {
            id: _header_root
            height: 40
            color: Style.mainAppColor

            Item {
                anchors.fill: parent
                TapHandler {
                    onTapped: if (tapCount === 2) toggleMaximized()
                    gesturePolicy: TapHandler.DragThreshold
                }
                DragHandler {
                    grabPermissions: TapHandler.CanTakeOverFromAnything
                    onActiveChanged: if (active) { rootWindow.startSystemMove(); }
                }

                Row {
                    id: _titleBar
                    anchors.fill: parent

                    MenuBar {
                        id: _menuBar

                        anchors.top: parent.top
                        anchors.bottom: parent.bottom

                        //disabled when personal setting popup is opened
                        enabled: !_popupDim.visible

                        //restrict mirroring of Menu elements
                        LayoutMirroring.enabled: false
                        LayoutMirroring.childrenInherit: true

                        //Customizing MenuBar
                        delegate: MenuBarItem {
                            id: menuBarItem

                            contentItem: Text {
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter

                                text: menuBarItem.text
                                color: Style.getContrastingColor(_header_root.color)
                                elide: Text.ElideRight
                                scale:  _menuBarItmMouseArea.containsMouse ? 1.05 : 1.0
                            }

                            //MenuBar titel highlight
                            background: Rectangle {
                                id: _menuBarItemCustom

                                anchors.verticalCenter: parent.verticalCenter
                                anchors.verticalCenterOffset: rootWindow.visibility === Window.Maximized ? -0.5 : -bw/2+0.5

                                height: parent.height - (rootWindow.visibility === Window.Maximized ? 0 : bw/2)
                                scale:  _menuBarItmMouseArea.containsMouse ? 0.9 : 1.0

                                radius: 3

                                color: _menuBarItmMouseArea.containsMouse ? Style.appLightGrey : Style.appTransparent
                                border.color: _menuBarItmMouseArea.pressed ? Style.appLightGrey : Style.appTransparent
                            }
                            //to be able react on hover
                            MouseArea {
                                id: _menuBarItmMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.NoButton
                            }
                        }

                        //Remove MenuBar background color
                        background: Rectangle {
                            anchors.fill: parent
                            color: Style.appTransparent
                        }

                        BaseMenu {
                            title: qsTr("File")
                            Action {
                                text: qsTr("&Quit")
                                 shortcut: "Ctrl+Alt+Q"
                                onTriggered: Qt.quit()
                            }
                        }

                        BaseMenu {
                            title: qsTr("Edit")
                            Action {
                                text: qsTr("Cut")
                                onTriggered: {
                                    if (Global.copyItem) {
                                        Global.copyItem.cut();
                                    }
                                }
                            }
                            Action {
                                text: qsTr("Copy")
                                onTriggered: {
                                    if (Global.copyItem) {
                                        Global.copyItem.copy();
                                    }
                                }
                            }
                            Action {
                                text: qsTr("Paste")
                                onTriggered: {
                                    if (Global.copyItem) {
                                        Global.copyItem.paste();
                                    }
                                }
                            }
                        }

                        BaseMenu {
                        id: _helpMenu

                        title: qsTr("Help")
                        Action {
                            text: qsTr("&About")
                            shortcut: "Ctrl+Alt+A"
                            onTriggered: Global.mainStackView.pushPage("qrc:/gui/pages/AppAbout.qml")
                        }
                        }
                    }

                    //Spanner between elements
                    Item {
                        id: _spanner
                        height: 1
                        width: _page.width - _windowButtons.width - _menuBar.width - _userPersSettings.width - _spanner2.width
                    }

                    TitleBarButton {
                        id: _userPersSettings
                        height: parent.height
                        width: parent.height

                        iconColor: Style.getContrastingColor(_header_root.color)
                        buttonImageSource: "qrc:/gui/images/windowControls/window-settings.png" //

                        onClicked: {
                            pesonalSettingsPopUp.open()
                            console.log("Personalization button pressed")
                        }
                    }

                    Item {
                        id: _spanner2
                        height: 1
                        width: 30
                    }

                    Row {
                        id: _windowButtons

                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                        }

                        spacing: 1

                        //Min App_Window
                        TitleBarButton {
                            id: _minButton
                            height: parent.height
                            width: parent.height

                            iconColor: Style.getContrastingColor(_header_root.color)
                            buttonImageSource: "qrc:/gui/images/windowControls/window-minimize.png" //"🗕"
                            onClicked: {
                                console.log("App minimized")
                                rootWindow.showMinimized()
                            }
                        }

                        //Max_Norm App_Window
                        TitleBarButton {
                            id: _maxButton
                            height: parent.height
                            width: parent.height

                            iconColor: Style.getContrastingColor(_header_root.color)
                            buttonImageSource: rootWindow.visibility == Window.Maximized ? "qrc:/gui/images/windowControls/window-restore.png" : "qrc:/gui/images/windowControls/window-maximize.png" //"🗗" : "🗖"
                            onClicked: {
                                console.log("App window maximized/normilized")
                                rootWindow.toggleMaximized()
                            }
                        }

                        //Close AppWindow
                        TitleBarButton {
                            id: _closeButton
                            height: parent.height
                            width: parent.height

                            iconColor: Style.getContrastingColor(_header_root.color)
                            buttonImageSource: "qrc:/gui/images/windowControls/window-close.png" //"🗙"
                            onClicked: {
                                console.log("App closed")
                                rootWindow.close()
                            }
                        }
                    }
                }

                Text {
                    id: _titleWindow
                    anchors.centerIn: parent
                    text: rootWindow.title
                    elide: Text.ElideRight
                    color: Style.getContrastingColor(_header_root.color)
                    font.bold: true
                }
            }
        }

        StackView {
            id: stackView
            focus: true
            anchors.fill: parent

            function pushPage(compName) {
                stackView.push(compName);
            }

            function replacePage(compName, param) {
                stackView.replace(compName, param);
            }
        }

        Item {
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }

            height: _notification.notificationHeight

            Notification {
                id: _notification

                width: parent.width
                anchors.centerIn: parent
            }
        }

        Component.onCompleted: {
            Common.DBManager.connectDB("localhost", 5432, "OfficeIS", "postgres", "8712");

            Global.mainStackView = stackView;
            Global.notification = _notification;
            Global.personalSettingsPopUp = pesonalSettingsPopUp;
            stackView.replacePage("qrc:/gui/pages/account/LoginUser.qml");
        }

        Component.onDestruction: {
            if (Common.DBManager.userIsOnline(Global.settings.lastLoggedLocalUser.username))
                Common.DBManager.setIsOnline(Global.settings.lastLoggedLocalUser.username, false);
        }
    }

    Rectangle {
        id: _popupDim
        anchors.fill: parent
        color: Style.bgColor
        visible: pesonalSettingsPopUp.opened
        opacity: 0.5
        z: _page.z + 1
        MouseArea {
            anchors.fill: parent
            anchors.topMargin: _page.y + _page.header.height
            onClicked: pesonalSettingsPopUp.close()
            hoverEnabled: true
        }

        PersonalSettingsPopUp {
            id: pesonalSettingsPopUp
        }
    }

    function toggleMaximized() {
        if (rootWindow.visibility === Window.Maximized) {
            rootWindow.showNormal();
        } else {
            rootWindow.showMaximized();
        }
    }
}
