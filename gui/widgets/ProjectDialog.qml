import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import common
import gui

Dialog {
    id: root

    property var newModel

    modal: true
    width: 600
    height: 600
    x: (rootWindow.width - width) / 2
    closePolicy: Popup.NoAutoClose

    background: Rectangle {
        id: _bg
        anchors.fill: parent
        color: Style.bgColor
    }

    header: Item {
        Text {
            text: "Create new project"
            font.family: Style.fontName
            anchors {
                topMargin: 10
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            font.pointSize: 14
            color: Style.mainTextColor
        }
    }

    footer: Item {
        DialogButtonBox {
            id: _buttonBox

            anchors {
                rightMargin: 10
                right: parent.right
                bottom: parent.top
            }

            background: Rectangle {
                id: _buttonBoxBg
                anchors.fill: parent
                color: Style.bgColor
            }

            BaseButton {
                id: _createButton

                anchors {
                    rightMargin: 10
                    right: _cancelButton.left
                }

                expectedWidth: 30
                expectedHeight: 20
                baseColor: Style.bgColor
                borderColor: Style.mainTextColor
                textColor: Style.mainTextColor
                buttonText: "Create"
                font.family: Style.fontName
                tooltipText: "Create project"
                clip: true
                DialogButtonBox.buttonRole: DialogButtonBox.ApplyRole

                onClicked: {
                    console.log("Project created");
                    if (!verifyData())
                        return;

                    var res = DBManager.createProject(_projectName.text, _projectDescription.text, suggestionsList.selectedUsers);

                    if (!res) {
                        Global.notification.showSuccessMessage("Project %1 created successfully!".arg(_projectName.text));
                        newModel = DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER" ? DBManager.getAllProjects()
                                        : DBManager.getUserProjects(Global.settings.lastLoggedLocalUser.username);
                    }
                    else if (res === 1) {
                        Global.notification.showErrorMessage("Could not create new project!");
                        return;
                    }
                    else {
                        Global.notification.showWarningMessage("Project %1 already exists!".arg(_projectName.text));
                        return;
                    }

                    root.close();
                }
            }

            BaseButton {
                id: _cancelButton

                anchors {
                    right: parent.right
                    rightMargin: 10
                }

                expectedWidth: 30
                expectedHeight: 20
                baseColor: Style.bgColor
                borderColor: Style.mainTextColor
                textColor: Style.mainTextColor
                buttonText: "Cancel"
                font.family: Style.fontName
                tooltipText: "Cancel project creation"
                clip: true
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole

                onClicked: {
                    console.log("Project creation cancelled");
                    root.close();
                }
            }
        }
    }

    ColumnLayout {
        width: parent.width
        anchors {
            left: parent.left
            top: parent.top
            leftMargin: 10
            topMargin: 10
        }
        spacing: 15

        FormField {
            id: _projectName

            Layout.preferredWidth: parent.width / 2.5
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.minimumHeight: height

            labelText: "Project name"
            placeHolderText: "Project name"
            fieldIcon: "qrc:/gui/images/symbols/pencil.png"

            clearSymbolApplicable: true

            Keys.onEnterPressed: {
                _projectDescription.forceActiveFocus()
            }
        }

        FormField {
            id: _projectDescription

            Layout.preferredWidth: parent.width / 2.5
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.minimumHeight: height

            labelText: "Project description"
            placeHolderText: "Project description"
            fieldIcon: "qrc:/gui/images/symbols/pencil.png"

            clearSymbolApplicable: true

            Keys.onEnterPressed: {
                searchField.forceActiveFocus();
            }
        }

        FormField {
            id: searchField

            Layout.preferredWidth: parent.width / 2.5
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.minimumHeight: height

            labelText: "Add users"
            placeHolderText: "Add users"
            fieldIcon: "qrc:/gui/images/symbols/pencil.png"

            clearSymbolApplicable: true

            onTextChanged: {
                if (text.length >= 3) {
                    suggestionsList.model = DBManager.searchUsers(text);
                }

                var combined = suggestionsList.model.concat(suggestionsList.selectedUsers);
                combined = combined.filter(function(name, index) {
                    return combined.indexOf(name) === index;
                });
                suggestionsList.model = text ? combined : suggestionsList.selectedUsers;
            }
        }

        Label {
            Layout.preferredWidth: parent.width / 2.5
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            Layout.minimumHeight: height

            text: "User list"
            font.family: Style.fontName
            font.pointSize: 14
            color: Style.mainTextColor
        }

        ScrollView {
            Layout.preferredWidth: parent.width / 2.5
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            Layout.minimumHeight: height

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ListView {
                id: suggestionsList

                anchors.fill: parent

                property var selectedUsers: [Global.settings.lastLoggedLocalUser.username]

                model: []

                delegate: BaseCheckBox {
                    id: _itemDelegate

                    tooltipText: "Users list"
                    name: modelData

                    onIsCheckedChanged: {
                        suggestionsList.updateSelectedUsers(name, isChecked);
                    }

                    Component.onCompleted: {
                        if (name === Global.settings.lastLoggedLocalUser.username)
                            enabled = false;

                        if (suggestionsList.selectedUsers.indexOf(name) !== -1)
                            isChecked = true;
                    }
                }

                Component.onCompleted: {
                    model = selectedUsers;
                }

                function updateSelectedUsers(name, isChecked) {
                    var updatedList;
                    if (isChecked) {
                        updatedList = selectedUsers.concat([name]);
                        updatedList = updatedList.filter(function(name, index) {
                           return updatedList.indexOf(name) === index;
                        });
                    } else {
                        var index = selectedUsers.indexOf(name);

                        if (index !== -1) {
                            updatedList = selectedUsers.slice(0, index).concat(selectedUsers.slice(index + 1));
                        }
                    }
                    selectedUsers = updatedList;
                }
            }
        }
    }

    function verifyData() {
        if (_projectName.text === "") {
            _projectName.isWarningShown = true;
            _projectName.warnToolTiptext = "Enter project name";
            _projectName.warnPopUpMessage = "Project name was not entered";
            return false;
        }

        if (suggestionsList.selectedUsers === []) {
            searchField.isWarningShown = true;
            searchField.warnToolTiptext = "Add users to projects";
            searchField.warnPopUpMessage = "Users were not added to project";
            return false;
        }

        return true;
    }
}
