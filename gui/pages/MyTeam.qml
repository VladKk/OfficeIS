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
            text: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER" ? "All teams" : "My teams"
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

    BaseButton {
        id: _saveChanges

        anchors {
            top: parent.top
            left: _addTeam.right
            leftMargin: 10
        }

        buttonText: "Save changes"
        expectedWidth: 50
        expectedHeight: 40
        baseColor: Style.bgColor
        borderColor: Style.mainTextColor
        enabled: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER"
        visible: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER"

        onClicked: {
            var ok = DBManager.updateUserData(_userData.clickedUser, _userEmail.text, _userPhone.text, _userSalary.text, _userManager.text, _userVacation.text, _userStartDate.text, _userEndDate.text);

            if (ok) {
                Global.notification.showSuccessMessage("User data updated successfully");
                console.log("User data updated");
            } else {
                Global.notification.showErrorMessage("Could not update user data. Please, check if email and phone number are unique");
                console.log("User data update failed");
            }
        }
    }

    RowLayout {
        id: _removeTeam

        anchors {
            left: _saveChanges.right
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

                onClicked: {
                    _userData.currentUserData = DBManager.getUserData(_itemText.text);
                    _userData.clickedUser = _itemText.text;
                }
            }
        }
    }

    Item {
        id: _userData

        anchors {
            left: scrollView.right
            leftMargin: 5
            top: _removeTeam.bottom
            topMargin: 5
            right: parent.right
            bottom: parent.bottom
        }

        property var currentUserData
        property string clickedUser

        Label {
            id: _userDataLabel

            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }

            text: "User data"
            font.family: Style.fontName
            font.pointSize: 14
            color: Style.mainTextColor
        }

        ColumnLayout {
            anchors {
                left: parent.left
                top: _userDataLabel.bottom
                topMargin: 5
                leftMargin: 5
            }
            spacing: 20
            width: 250

            Label {
                id: _userEmailLabel

                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.minimumHeight: height

                text: "Email"
                font.family: Style.fontName
                font.pointSize: 14
                color: Style.mainTextColor
            }
            FormField {
                id: _userEmail

                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.minimumHeight: height

                width: 150

                placeHolderText: "User email"
                text: _userData.currentUserData.email
                regExpression: /\\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z|a-z]{2,}\\b/

                textUneditable: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) !== "MANAGER"
            }

            Label {
                id: _userPhoneLabel

                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.minimumHeight: height

                text: "Phone number"
                font.family: Style.fontName
                font.pointSize: 14
                color: Style.mainTextColor
            }
            FormField {
                id: _userPhone

                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.minimumHeight: height

                width: 150

                placeHolderText: "User phone number"
                text: _userData.currentUserData.phone
                regExpression: /^\\+\\d{1,3}\\d+$/

                textUneditable: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) !== "MANAGER"
            }

            Label {
                id: _userManagerLabel

                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.minimumHeight: height

                text: "Manager"
                font.family: Style.fontName
                font.pointSize: 14
                color: Style.mainTextColor
            }
            FormField {
                id: _userManager

                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.minimumHeight: height

                width: 150

                placeHolderText: "User manager"
                text: _userData.currentUserData.manager_name

                textUneditable: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) !== "MANAGER"
            }

            Label {
                id: _userSalaryLabel

                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.minimumHeight: height

                text: "Salary"
                font.family: Style.fontName
                font.pointSize: 14
                color: Style.mainTextColor

                visible: _userData.clickedUser === Global.settings.lastLoggedLocalUser.username || DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER"
            }
            FormField {
                id: _userSalary

                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.minimumHeight: height

                width: 150

                placeHolderText: "User salary"
                text: _userData.currentUserData.salary

                textUneditable: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) !== "MANAGER"
                visible: _userData.clickedUser === Global.settings.lastLoggedLocalUser.username || DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER"
            }

            Label {
                id: _userVacationLabel

                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.minimumHeight: height

                text: "Vacation days"
                font.family: Style.fontName
                font.pointSize: 14
                color: Style.mainTextColor

                visible: _userData.clickedUser === Global.settings.lastLoggedLocalUser.username || DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER"
            }
            FormField {
                id: _userVacation

                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.minimumHeight: height

                width: 150

                placeHolderText: "User vacation days"
                text: _userData.currentUserData.vacation_days

                textUneditable: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) !== "MANAGER"
                visible: _userData.clickedUser === Global.settings.lastLoggedLocalUser.username || DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER"
            }

            Label {
                id: _userStartDateLabel

                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.minimumHeight: height

                text: "Works from"
                font.family: Style.fontName
                font.pointSize: 14
                color: Style.mainTextColor
            }
            FormField {
                id: _userStartDate

                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.minimumHeight: height

                width: 150

                placeHolderText: "User start date"
                text: _userData.currentUserData.start_date
                regExpression: /^\\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$/

                textUneditable: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) !== "MANAGER"
            }

            Label {
                id: _userEndDateLabel

                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.minimumHeight: height

                text: "Left after"
                font.family: Style.fontName
                font.pointSize: 14
                color: Style.mainTextColor

                visible: _userEndDate.text
            }
            FormField {
                id: _userEndDate

                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.minimumHeight: height

                width: 150

                placeHolderText: "User end date"
                text: _userData.currentUserData.end_date
                regExpression: /^\\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$/

                textUneditable: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) !== "MANAGER"
                visible: text
            }
        }
    }
}
