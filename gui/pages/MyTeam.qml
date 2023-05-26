import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import gui
import common

Page {
    id: _docsPage

    background: Rectangle {
        width: parent.width
        height: parent.height
        color: Style.bgColor
    }

    header: ToolBar {
        id: toolBar

        background:
            Rectangle {
            implicitHeight: _docsPage.height / 12
            implicitWidth: parent.width
            color: Style.bgColor
        }

        Text {
            text: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER" ? "All teams" : "My team"
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
                source: "qrc:/gui/images/appControls/home.png"
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
                    Global.mainStackView.replacePage("qrc:/gui/pages/StartPage.qml");
                }
            }
        }
    }
}
