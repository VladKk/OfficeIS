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
            text: "My Projects"
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

    BaseButton {
        id: _createProjectButton

        anchors {
            left: parent.left
            leftMargin: 5
        }

        z: 1
        expectedWidth: 30
        expectedHeight: 20
        baseColor: Style.bgColor
        borderColor: Style.mainTextColor
        textColor: Style.mainTextColor
        buttonText: "Create project"
        font.family: Style.fontName
        tooltipText: "Create new project"
        clip: true
        visible: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER"

        onClicked: {
            _projectCreation.open();
        }

        ProjectDialog {
            id: _projectCreation

            onNewModelChanged: {
                listView.model = newModel ? newModel : listView.model;
            }
        }
    }

    BaseButton {
        id: _deleteProjectButton

        anchors {
            left: _createProjectButton.right
            leftMargin: 10
        }

        z: 1
        expectedWidth: 30
        expectedHeight: 20
        baseColor: Style.bgColor
        borderColor: Style.mainTextColor
        textColor: Style.mainTextColor
        buttonText: "Delete project(s)"
        font.family: Style.fontName
        tooltipText: "Delete selected projects"
        clip: true
        visible: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER"
    }

    ScrollView {
        id: scrollView

        anchors {
            left: parent.left
            top: _createProjectButton.bottom
            topMargin: 10
        }

        clip: true

        height: parent.height
        width: 250

        ListView {
            id: listView

            anchors.fill: parent

            spacing: 5
            model: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER" ? DBManager.getAllProjects()
                     : DBManager.getUserProjects(Global.settings.lastLoggedLocalUser.username)

            delegate: ItemDelegate {
                id: itemDelegate

                width: listView.width
                height: 50

                background: Rectangle {
                    color: itemDelegate.hovered ? Style.bgTileColor : Style.appTransparent
                    border.width: 1
                    border.color: Style.bgTileColor
                }

                contentItem: Text {
                    id: _itemText

                    text: listView.model[index]
                    color: Style.mainTextColor
                    verticalAlignment: Text.AlignVCenter
                    padding: 10
                }

                onClicked: {
                    console.log("Opened project: " + listView.model[index]);
                }
            }
        }
    }
}
