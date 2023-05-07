import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import gui
import filteringmodel
import common

Page {
    id: root
    property string systemModel

    Loader {
        id: _backendModelLoader
        sourceComponent: Qt.createComponent(systemModel)
    }

    property var backendModel: {
        var model = _backendModelLoader.item;
        if (model) {
            model.appElementSelected.connect(pageViewer.setupLeftPaneModel);
        }
        return model;
    }

    property var model: AppElements {
        onAppElementSelected: panelModelUrl => {
            pageViewer.setupLeftPaneModel(panelModelUrl);
        }
    }

    background: Rectangle {
        width: parent.width
        height: parent.height
        color: Style.bgColor
    }

    header: ToolBar {
        id: toolBar

        background:
            Rectangle {
            implicitHeight: root.height / 12
            implicitWidth: parent.width
            color: Style.bgColor
        }

        Item {
            id: backToStartPage

            anchors {
                left: parent.left
                top: parent.top
            }

            width: 50; height: 50
            visible: pageViewer.visible

            MouseArea {
                id: mAreaBackToStart
                anchors.fill: parent
                hoverEnabled: true

                onClicked: {
                    pageViewer.visible = false;
                }
            }

            Image {
                id: _upperAppsGrid
                source: "qrc:/gui/images/appControls/apps-grid.png"
                width: 32
                height: 32
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
                smooth: true
                visible: false
                mipmap: true
            }

            ColorOverlay {
                id: _upperAppsGridOverlay
                anchors.fill: _upperAppsGrid
                source: _upperAppsGrid
                color: mAreaBackToStart.containsMouse ? Style.mainAppColor : Style.mainTextColor
                scale:  mAreaBackToStart.containsMouse ? 1.05 : 1.0
            }
        }

        Text {
            text: internal.getWelcomeText()
            font.family: Style.fontName
            anchors.centerIn: parent
            font.pointSize: 20
            color: Style.mainTextColor
        }

        Item {
            id: logOut
            anchors {
                right: parent.right
                top: parent.top
            }
            implicitWidth: 50;
            implicitHeight: 50;

            Image {
                id: _logOut
                width: 32
                height: 32
                anchors.centerIn: logOut
                source: root.systemModel !== "" ? "qrc:/gui/images/appControls/home.png" : "qrc:/gui/images/appControls/logout.png"
                smooth: true
                visible: false
                mipmap: true
            }

            ColorOverlay {
                id: _logOutOverlay
                anchors.fill: _logOut
                source: _logOut
                color: mArealogOut.containsMouse ? Style.mainAppColor : Style.mainTextColor
                scale:  mArealogOut.containsMouse ? 1.05 : 1.0
            }

            MouseArea {
                id: mArealogOut
                anchors.fill: parent
                hoverEnabled: true

                onClicked: {
                    if (root.systemModel !== "") {
                        Global.mainStackView.replacePage("qrc:/gui/pages/StartPage.qml");
                    } else {
                        if (DBManager.userIsOnline(Global.settings.lastLoggedLocalUser.username))
                            DBManager.setIsOnline(Global.settings.lastLoggedLocalUser.username, false);

                        Global.mainStackView.replacePage("qrc:/gui/pages/account/LoginUser.qml");
                        Global.notification.showMessage(qsTr( "See you next time" ), 5000);
                    }
                }
            }
        }
    }

    GridView {
        id: grid

        //Define width and height of delegate
        cellWidth: 160
        cellHeight: cellWidth

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        //Grid Alignment
        anchors {
            topMargin: parent.height / 2 - ((model.count / (parent.width / cellWidth) + 1) * cellWidth) / 2
            leftMargin: anchors.rightMargin
            rightMargin: model.count * cellWidth < parent.width ? (parent.width / 2 - (model.count * cellWidth) / 2) : parent.width % cellWidth / 2
            bottomMargin: anchors.topMargin
        }

        Component.onCompleted: {
            console.log( "System Section loaded:", ( systemModel !== "" ) ? systemModel : "1st level of tiles" )
        }

        model: root.systemModel !== "" ? root.backendModel : root.model

        boundsBehavior: Flickable.StopAtBounds

        delegate: MenuTile {}
    }

    //Custom component to cache opened pages
    PageViewer {
        id: pageViewer
        anchors {
            fill: parent
            topMargin: toolBar.height / 2.0
            bottomMargin: 20
        }
        visible: false
    }

    Keys.onEscapePressed: {
        if (pageViewer.visible) {
             pageViewer.visible = false;
        }
    }

    QtObject {
        id: internal
        function getWelcomeText() {

            if (pageViewer.visible) {
                return Global.settings.lastLoggedLocalUser.username.charAt(0).toUpperCase() + Global.settings.lastLoggedLocalUser.username.slice(1) + qsTr(", choose ") + pageViewer.currentPageName + qsTr(" activity");
            } else if (root.systemModel !== "") {
                return root.systemModel.substring((root.systemModel.indexOf("AppElements") + "AppElements".length), root.systemModel.lastIndexOf(".qml")) + " activities"
            }
            return qsTr("Welcome, ") + Global.settings.lastLoggedLocalUser.username.charAt(0).toUpperCase() + Global.settings.lastLoggedLocalUser.username.slice(1); //Capitalize first letter
        }
    }
}
