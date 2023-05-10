import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import gui
import filteringmodel
import common

Page {
    id: root

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
                source: "qrc:/gui/images/appControls/logout.png"
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
                    if (DBManager.userIsOnline(Global.settings.lastLoggedLocalUser.username))
                        DBManager.setIsOnline(Global.settings.lastLoggedLocalUser.username, false);

                    Global.mainStackView.replacePage("qrc:/gui/pages/account/LoginUser.qml");
                    Global.notification.showMessage(qsTr( "See you next time" ), 5000);
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

        model: AppElements {}

        boundsBehavior: Flickable.StopAtBounds

        delegate: MenuTile {}
    }

    QtObject {
        id: internal
        function getWelcomeText() {
            return qsTr("Welcome, ") + Global.settings.lastLoggedLocalUser.username.charAt(0).toUpperCase() + Global.settings.lastLoggedLocalUser.username.slice(1); //Capitalize first letter
        }
    }
}
