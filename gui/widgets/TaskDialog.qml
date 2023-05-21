import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import common
import gui

Dialog {
    id: root

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
            text: "Create new task"
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
                tooltipText: "Create task"
                clip: true
                DialogButtonBox.buttonRole: DialogButtonBox.ApplyRole

                onClicked: {
                    if (!verifyData())
                        return;

                    var res = DBManager.createTask(_project.currentText, _taskName.text, Date.fromLocaleString(Qt.locale(), dateField.text, "dd/MM/yyyy"), searchField.text);

                    if (!res) {
                        Global.notification.showSuccessMessage("Task %1 created successfully!".arg(_taskName.text));
                        console.log("Task created");
                    }
                    else if (res === 1) {
                        Global.notification.showErrorMessage("Could not create new task!");
                        return;
                    }
                    else {
                        Global.notification.showWarningMessage("Task %1 already exists!".arg(_taskName.text));
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
                tooltipText: "Cancel task creation"
                clip: true
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole

                onClicked: {
                    console.log("Task creation cancelled");
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
            topMargin: 30
        }
        spacing: 15

        Label {
            Layout.preferredWidth: parent.width / 2.5
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.minimumHeight: height

            text: "Select project:"
            font.family: Style.fontName
            font.pointSize: 14
            color: Style.mainTextColor
        }

        BaseComboBox {
            id: _project
            model: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER" ? DBManager.getAllProjects()
                                            : DBManager.getUserProjects(Global.settings.lastLoggedLocalUser.username);

            Layout.preferredWidth: parent.width / 2.5
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.minimumHeight: height
        }

        Label {
            Layout.preferredWidth: parent.width / 2.5
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.minimumHeight: height

            text: "Due date:"
            font.family: Style.fontName
            font.pointSize: 14
            color: Style.mainTextColor
        }

        BaseDateField {
            id: dateField

            Layout.preferredWidth: parent.width / 2.5
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.minimumHeight: height

            defaultDate: new Date()
        }

        FormField {
            id: _taskName

            Layout.preferredWidth: parent.width / 2.5
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.minimumHeight: height

            labelText: "Task name"
            placeHolderText: "Task name"
            fieldIcon: "qrc:/gui/images/symbols/pencil.png"

            clearSymbolApplicable: true

            Keys.onEnterPressed: {
                _projectDescription.forceActiveFocus()
            }
        }

        FormField {
            id: searchField

            Layout.preferredWidth: parent.width / 2.5
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.minimumHeight: height

            labelText: "Assignee"
            placeHolderText: "Assignee"
            fieldIcon: "qrc:/gui/images/symbols/pencil.png"

            clearSymbolApplicable: true

            onTextChanged: {
                if (text.length >= 3 && !suggestionsList.chosen) {
                    suggestionsList.model = DBManager.searchUsers(text);
                } else if (text.length === 0)
                    suggestionsList.chosen = false;
            }
        }

        ScrollView {
            Layout.preferredWidth: parent.width / 2.5
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.minimumHeight: height

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ListView {
                id: suggestionsList

                anchors.fill: parent

                property bool chosen: false

                model: []

                delegate: ItemDelegate {
                    id: itemDelegate

                    width: suggestionsList.width
                    height: 50

                    background: Rectangle {
                        color: itemDelegate.hovered ? Style.bgTileColor : Style.appTransparent
                        border.width: 1
                        border.color: Style.bgTileColor
                    }

                    contentItem: Item {
                        anchors.fill: parent

                        Text {
                            id: _itemText

                            anchors {
                                left: parent.left
                                leftMargin: 5
                                verticalCenter: parent.verticalCenter
                            }

                            text: suggestionsList.model[index]
                            color: Style.mainTextColor
                            verticalAlignment: Text.AlignVCenter
                            padding: 10
                        }
                    }

                    onClicked: {
                        suggestionsList.chosen = true;
                        searchField.text = _itemText.text;
                        suggestionsList.model = [];
                    }
                }
            }
        }
    }

    function verifyData() {
        if (_taskName.text === "") {
            _taskName.isWarningShown = true;
            _taskName.warnToolTiptext = "Enter task name";
            _taskName.warnPopUpMessage = "Task name was not entered";
            return false;
        }

        if (searchField.text === "") {
            searchField.isWarningShown = true;
            searchField.warnToolTiptext = "Add user to task";
            searchField.warnPopUpMessage = "User was not added to task";
            return false;
        }

        return true;
    }
}
