import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
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

    BaseComboBox {
        id: _teamBox

        anchors {
            left: parent.left
            top: parent.top
        }

        model: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER" ? DBManager.getAllTeams()
                        : DBManager.getTeamsByCurrentUser(Global.settings.lastLoggedLocalUser.username)

        width: 150

        onCurrentTextChanged: {
            listView.model = DBManager.getUsersByTeam(currentText);
        }
    }

    BaseButton {
        id: _addTeam

        anchors {
            top: parent.top
            left: _teamBox.right
            leftMargin: 10
        }

        buttonText: "Add team"
        expectedWidth: 50
        expectedHeight: 40
        baseColor: Style.bgColor
        borderColor: Style.mainTextColor
        enabled: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER"

        onClicked: {
            _teamDiag.open();
        }
    }

    TeamDialog {
        id: _teamDiag

        onNewModelChanged: {
            _teamBox.model = newModel;
        }
    }

    RowLayout {
        id: _removeTeam

        anchors {
            left: _addTeam.right
            leftMargin: 10
            top: parent.top
        }
        spacing: 5
        width: 500

        FormField {
            id: _teamName

            Layout.preferredWidth: parent.width / 2.5
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.minimumHeight: height

            labelText: "Team name"
            placeHolderText: "Team name"
            fieldIcon: "qrc:/gui/images/symbols/pencil.png"

            clearSymbolApplicable: true
            visible: false

            Keys.onEnterPressed: {
                _rmTeamBtn.clicked();
            }
        }

        BaseButton {
            id: _rmTeamBtn

            Layout.preferredWidth: parent.width / 2.5
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.minimumHeight: height

            property var newModel

            buttonText: "Remove team"
            expectedWidth: 50
            expectedHeight: 40
            baseColor: Style.bgColor
            borderColor: Style.mainTextColor
            enabled: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER"

            onNewModelChanged: {
                _teamBox.model = newModel;
            }

            onClicked: {
                if (!_teamName.visible)
                    _teamName.visible = true;
                else {
                    if (_teamName.text === "") {
                        _teamName.isWarningShown = true;
                        _teamName.warnToolTiptext = "Enter team name";
                        _teamName.warnPopUpMessage = "Team name was not entered";
                        return;
                    }

                    var res = DBManager.removeTeam(_teamName.text);

                    if (res) {
                        Global.notification.showSuccessMessage("Team %1 was removed".arg(_teamName.text));
                        console.log("Team removed");
                        newModel = DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER" ? DBManager.getAllTeams()
                                            : DBManager.getTeamsByCurrentUser(Global.settings.lastLoggedLocalUser.username);
                    } else {
                        Global.notification.showErrorMessage("Team %1 could not be removed. Please, check if you entered name of existing team".arg(_teamName.text));
                        console.log("DB error");
                        return;
                    }

                    _teamName.visible = false;
                }
            }
        }
    }

    ScrollView {
        id: scrollView

        anchors {
            left: parent.left
            top: _teamBox.bottom
            topMargin: 10
        }

        clip: true

        height: parent.height
        width: visible ? 250 : 0

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ListView {
            id: listView

            anchors.fill: parent

            spacing: 5

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
            }
        }
    }
}
