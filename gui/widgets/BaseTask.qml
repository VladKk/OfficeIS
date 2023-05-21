import QtQuick
import QtQuick.Controls

import gui
import common

Rectangle {
    id: root

    property string projectName
    property alias taskName: _taskName.text
    property string currentName

    color: Style.bgColor
    border.color: Style.mainAppColor
    border.width: 1

    TextField {
        id: _taskName
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 10
        }

        readOnly: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) !== "MANAGER"
        placeholderTextColor: Style.mainAppColor
        color: Style.mainTextColor
        font.pointSize: 12
        verticalAlignment: Text.AlignVCenter
        font.family: Style.fontName
        font.bold: true
        selectionColor: Style.mainAppColor

        background: Rectangle {
            color: Style.appTransparent
            border.color: Style.mainAppColor
            border.width: 1

            MouseArea {
                id: _taskNameMouseArea
                anchors {
                    fill: parent
                    margins: -10
                }
                cursorShape: Qt.IBeamCursor
                hoverEnabled: true
            }
        }

        onTextChanged: _ok.enabled = true
    }

    Label {
        id: _dueDateText

        anchors {
            verticalCenter: parent.verticalCenter
            right: _dueDate.left
            rightMargin: 5
        }

        text: "Due:"
        font.pointSize: 12
        color: Style.mainTextColor
    }

    BaseDateField {
        id: _dueDate

        width: _status.width
        height: _status.height
        defaultDate: DBManager.getTaskDueDate(root.projectName, _taskName.text)
        readonly: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) !== "MANAGER"

        anchors {
            verticalCenter: parent.verticalCenter
            right: _status.left
            rightMargin: 10
        }

        onTextChanged: _ok.enabled = true;
    }

    BaseComboBox {
        id: _status

        anchors {
            verticalCenter: parent.verticalCenter
            right: _ok.left
            rightMargin: 10
        }

        model: ["To do", "In progress", "Done"]
        height: parent.height - 10
        enabled: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER"

        onCurrentTextChanged: _ok.enabled = true

        Component.onCompleted: {
            var currentStatus = DBManager.getTaskStatus(root.projectName, _taskName.text);
            currentStatus = currentStatus.charAt(0).toUpperCase() + currentStatus.slice(1).toLowerCase();

            currentIndex = model.indexOf(currentStatus);
        }
    }

    BaseButton {
        id: _ok

        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: 5
        }

        expectedWidth: parent.height - 10
        baseColor: Style.bgColor
        borderColor: Style.mainTextColor
        enabled: false

        ColorImage {
            anchors.centerIn: parent
            color: Style.mainAppColor
            source: "qrc:/gui/images/symbols/checkmark.png"
            fillMode: Image.PreserveAspectFit
            width: parent.width - 5
            height: parent.height - 5
        }

        onClicked: {
            DBManager.updateTask(currentName, projectName, _taskName.text, Date.fromLocaleString(Qt.locale(), _dueDate.text, "dd/MM/yyyy"), _status.currentText);
            Global.notification.showSuccessMessage("Task %1 was changed successfully".arg(_taskName.text));
        }
    }

    Component.onCompleted: {
        currentName = _taskName.text;
    }
}
