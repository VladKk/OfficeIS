import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import common
import gui

Page {
    id: registerUserPage

    property string weekPass: qsTr("Password does not meet the required security standards. Please ensure that your password meets the following criteria:/n
                                        - at least 8 characters long/n
                                        - contains at least one uppercase letter./n
                                        - contains at least one digit/n
                                        - contains at least one special character !@#$%^&*()-_=+{};:,<.>[]|/~")
    property string weekPassTip: qsTr("Passwors is still not enough secure")

    property string userName: ""

    background: Rectangle {
        width: parent.width
        height: parent.height
        color: Style.bgColor
    }

    Rectangle {
        id: _signupText
        width: parent.width
        height: parent.height / 8
        color: Style.bgColor

        Text {
            text: qsTr( "Set new password" )
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
            anchors.top: _signupText.bottom
            spacing: 10

            //New password
            FormField {
                id: _newPass
                objectName: "NewPassword"
                Layout.preferredWidth: parent.width / 2.5
                Layout.alignment: Qt.AlignHCenter
                Layout.minimumHeight: height

                isPassField: true

                weekPassMessage: registerUserPage.weekPass
                weekPassToolTip: registerUserPage.weekPassTip

                regExpression: /^.*(?=.{12,})(?=.*[a-z])(?=.*[A-Z])(?=.*\d).*$/

                labelText: qsTr( "New password" )
                placeHolderText: qsTr( "New password" )
                fieldIcon: (_newPass.text.length >= 5) ? "qrc:/gui/images/symbols/lock.png" : "qrc:/gui/images/symbols/lock-open.png"
            }

            //New password
            FormField {
                id: _newPass2
                objectName: "NewPasswordConfirm"
                Layout.preferredWidth: parent.width / 2.5
                Layout.alignment: Qt.AlignHCenter
                Layout.minimumHeight: height

                isPassField: true

                weekPassMessage: registerUserPage.weekPass
                weekPassToolTip: registerUserPage.weekPassTip

                regExpression: /^.*(?=.{12,})(?=.*[a-z])(?=.*[A-Z])(?=.*\d).*$/

                labelText: qsTr( "Confirm new password" )
                placeHolderText: qsTr( "Confirm new password" )
                fieldIcon: (_newPass.text.length >= 5) ? "qrc:/gui/images/symbols/lock.png" : "qrc:/gui/images/symbols/lock-open.png"
            }

            Item {
                height: registerUserPage.height / 45
            }

            BaseButton {
                id: _rstButton
                objectName: "SetPasswordButton"
                Layout.preferredWidth: parent.width / 2.5
                Layout.alignment: Qt.AlignHCenter
                expectedHeight: 50
                expectedWidth: 100

                visible: true
                autoExclusive: false
                buttonText: qsTr( "Set New Password" )
                baseColor: Style.mainAppColor
                borderColor: Style.mainAppColor

                onClicked: {
                    const password1 = _newPass.text;
                    const password2 = _newPass2.text;

                    internal.validateUserCredentials(password1, password2);
                }
            }

            BaseButton {
                id: _cnlBtn
                objectName: "cancelButton"
                Layout.preferredWidth: parent.width / 2.5
                Layout.alignment: Qt.AlignHCenter
                expectedHeight: 50
                expectedWidth: 100

                buttonText: qsTr( "Cancel" )
                baseColor: Style.appTransparent
                borderColor: Style.mainAppColor
                onClicked: Global.mainStackView.pushPage("qrc:/gui/pages/account/LoginUser.qml")
            }
        }
    }

    QtObject {
        id: internal

        function validateUserCredentials(pwd1, pwd2) {

            var errors = [];

            if (pwd1 === "") {
                errors.push(qsTr( "Password" ));
                console.warn(qsTr( "No pass1" ));
                _newPass.isWarningShown = true;
                _newPass.warnToolTiptext = qsTr( "Field can't be empty" );
                _newPass.warnPopUpMessage = qsTr( "Enter new password!" );
            }

            if (pwd2 === "") {
                errors.push(qsTr( "Password confirmation" ));
                console.warb("No pass2");
                _newPass2.isWarningShown = true;
                _newPass2.warnToolTiptext = qsTr( "Field can't be empty!" );
                _newPass2.warnPopUpMessage = qsTr( "Enter new password confirmation!" );
            }

            if (pwd1 !== pwd2) {
                errors.push(qsTr( "Passwords do not match" ));
                console.warn("Different passwords");
                _newPass.isWarningShown = true;
                _newPass2.isWarningShown = true;
                _newPass.warnToolTiptext = qsTr( "Passwords should be the same!" );
                _newPass2.warnToolTiptext = qsTr( "Passwords should be the same!" );
            }

            if (errors.length > 0) {
                Global.notification.showWarningMessage("Please, fill marked fields to proceed!\nFields to check: %1".arg(errors.join(", ")));
                return
            } else if (errors.length === 0) {
                DBManager.resetPass(userName, pwd1, pwd1);
                Global.notification.showSuccessMessage(qsTr( "New password succesfully set!" ), 3500);
                Global.mainStackView.replacePage("qrc:/gui/pages/account/LoginUser.qml")
            }
        }
    }
}
