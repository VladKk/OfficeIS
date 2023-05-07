import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import common
import gui

Page {
    id: _forgetPassLocal

    background: Rectangle {
        width: parent.width
        height: parent.height
        color: Style.bgColor
    }

    Rectangle {
        id: _restoreText
        width: parent.width
        height: parent.height / 8
        color: Style.bgColor

        Text {
            text: qsTr("Restore account's password")
            font.pointSize: 25
            anchors {
                top: parent.top
                topMargin: 30
                horizontalCenter: parent.horizontalCenter
            }
            color: Style.mainTextColor
        }

        ColumnLayout {
            id: _column
            width: parent.width
            anchors.top: _restoreText.bottom
            spacing: 10

            FormField {
                id: _userName
                objectName: "UserName"

                Layout.preferredWidth: parent.width / 2.5
                Layout.alignment: Qt.AlignHCenter
                Layout.minimumHeight: height

                focus: true

                labelText: qsTr("User Name")
                placeHolderText: qsTr("User Name")
                fieldIcon: "qrc:/gui/images/symbols/user.png"
            }

            Item {
                height: _forgetPassLocal.height / 25
            }

            BaseButton {
                id: _rstBtn
                objectName: "RestoreButton"
                Layout.preferredWidth: parent.width / 2.5
                Layout.alignment: Qt.AlignHCenter
                expectedHeight: 50
                expectedWidth: 100

                visible: true
                autoExclusive: false
                buttonText: qsTr("Restore")
                baseColor: Style.mainAppColor
                borderColor: Style.mainAppColor

                onClicked: {
                    internal.validateUserCredentials()
                }
            }

            BaseButton {
                id: _cnlBtn
                objectName: "CancelButton"
                Layout.preferredWidth: parent.width / 2.5
                Layout.alignment: Qt.AlignHCenter
                expectedHeight: 50
                expectedWidth: 100

                buttonText: qsTr("Cancel")
                baseColor: Style.appTransparent
                borderColor: Style.mainAppColor
                onClicked: Global.mainStackView.pushPage("qrc:/gui/pages/account/LoginUser.qml")
            }
        }
    }

    QtObject {
        id: internal

        function validateUserCredentials() {
            var errors = [];

            if (_userName.text === "") {
                errors.push(qsTr( "User name"));
                console.warn("No User Name")
                _userName.isWarningShown = true;
                _userName.warnToolTiptext = qsTr("No User Name");
                _userName.warnPopUpMessage = qsTr("User name was not entered!");
                Global.notification.showWarningMessage(qsTr( "No User Name entered!"), 5000);
            }

            if (errors.length > 0) {
                Global.notification.showWarningMessage("Please, fill marked fields to proceed!\nFields to check: %1".arg(errors.join(", ")));
                return
            }

            if (errors.length === 0 && !DBManager.findUser(_userName.text)) {
                Global.notification.showWarningMessage( qsTr("User account not exists or set of credentials is incorrect"), 5000);
                console.error("Requested userName not exists")
                return;
            } else if (errors.length === 0 && DBManager.findUser(_userName.text)) {
                Global.notification.showSuccessMessage(qsTr( "User account exist and new password can be set!"), 5000);
                Global.mainStackView.replacePage("qrc:/gui/pages/account/SetNewPass.qml", {userName: _userName.text})
            }
        }
    }
}
