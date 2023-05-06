import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform

import common
import gui

Page {
    id: _registerLocalUserPage

    property string weekPass: qsTr("Password does not meet the required security standards. Please ensure that your password meets the following criteria:/n
                                        - at least 8 characters long/n
                                        - contains at least one uppercase letter./n
                                        - contains at least one digit/n
                                        - contains at least one special character !@#$%^&*()-_=+{};:,<.>[]|/~")
    property string weekPassTip: qsTr("Passwors is still not enough secure")

    property bool similarPasswords: false

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
            text: qsTr("Create account")
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

            FormField {
                id: _userName
                Layout.preferredWidth: parent.width / 2.5
                Layout.alignment: Qt.AlignHCenter
                Layout.minimumHeight: height

                focus: true

                labelText: qsTr("User name")
                tooltipText: qsTr("")
                placeHolderText: qsTr("User Name")
                fieldIcon: "qrc:/gui/images/symbols/user.png"
            }

            Item {
                height: 0
            }

            FormField {
                id: _usrPass

                Layout.preferredWidth: parent.width / 2.5
                Layout.alignment: Qt.AlignHCenter
                Layout.minimumHeight: height

                isPassField: true
                fieldValidation: true

                weekPassMessage: _registerLocalUserPage.weekPass
                weekPassToolTip: _registerLocalUserPage.weekPassTip

                regExpression: /^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()\-_=+{};:,<.>[\]\\|/`~]).{8,}$/

                labelText: qsTr("Password")
                tooltipText: qsTr("")
                placeHolderText: qsTr("User password")
                fieldIcon: (_usrPass.text.length >= 5) ? "qrc:/gui/images/symbols/lock.png" : "qrc:/gui/images/symbols/lock-open.png"

                onTextChanged: {
                    if (_usrPass.text !== _usrPass2.text) {
                        console.error("Passwords do not match")
                        _registerLocalUserPage.similarPasswords = false;
                    } else if (_usrPass.text !== _usrPass2.text && _usrPass.text !== "" && _usrPass2.text !== "") {
                        setErrorPassFields(_usrPass,_usrPass2);
                    } else {
                        console.error("Passowrds are similar");
                        _registerLocalUserPage.similarPasswords = true;
                    }
                }
            }
            Item {
                height: 0
            }
            FormField {
                id: _usrPass2

                Layout.preferredWidth: parent.width / 2.5
                Layout.alignment: Qt.AlignHCenter
                Layout.minimumHeight: height

                isPassField: true
                fieldValidation: true

                weekPassMessage: _registerLocalUserPage.weekPass
                weekPassToolTip: _registerLocalUserPage.weekPassTip

                regExpression: /^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()\-_=+{};:,<.>[\]\\|/`~]).{8,}$/

                labelText: qsTr("Confirm Password")
                tooltipText: qsTr("")
                placeHolderText: qsTr("Confirm password")
                fieldIcon: (_usrPass2.text.length >= 5) ? "qrc:/gui/images/symbols/lock.png" : "qrc:/gui/images/symbols/lock-open.png"

                onTextChanged: {
                    if (_usrPass2.text !== _usrPass.text) {
                        console.error("Passwords do not match")
                        _registerLocalUserPage.similarPasswords = false;
                    } else if (_usrPass2.text !== _usrPass.text && _usrPass2.text !== "" && _usrPass.text !== "") {
                        setErrorPassFields(_usrPass,_usrPass2);
                    } else {
                        console.error("Passowrds are similar");
                        _registerLocalUserPage.similarPasswords = true;
                    }
                }
            }

            Item {
                height: _registerLocalUserPage.height / 25
            }

            BaseButton {
                id: _signUpBtn

                Layout.preferredWidth: parent.width / 2.5
                Layout.alignment: Qt.AlignHCenter
                expectedHeight: 50
                expectedWidth: 100

                visible: true
                autoExclusive: false
                buttonText: qsTr("Create")
                baseColor: Style.mainAppColor
                borderColor: Style.mainAppColor

                onClicked: {
                    internal.validateUserData()
                }
            }

            BaseButton {
                id: _cnlBtn

                Layout.preferredWidth: parent.width / 2.5
                Layout.alignment: Qt.AlignHCenter
                expectedHeight: 50
                expectedWidth: 100

                buttonText: qsTr("Cancel")
                baseColor: Style.appTransparent
                borderColor: Style.mainAppColor
                onClicked: Global.mainStackView.replacePage("qrc:/gui/pages/localAccount/JAP_LocalLogInPage.qml")
            }
        }
    }

    QtObject {
        id: internal
        function validateUserData() {
            var errors = []

            if (_userName.text === "") {
                errors.push(qsTr("User name"));
                console.warn("No user name");
                _userName.isWarningShown = true;
                _userName.warnToolTiptext = qsTr("No User Name");
                _userName.warnPopUpMessage = qsTr("User name was not entered!");
            }

            if (_usrPass.text === "") {
                errors.push(qsTr("User password"));
                console.warn("No User pass1");
                _usrPass.warnIconColor = Style.appErrColor;
                _usrPass.isWarningShown = true;
                _usrPass.warnToolTiptext = qsTr("Field can't be empty");
                _usrPass.warnPopUpMessage = qsTr("Password not entered!");
            }

            if (_usrPass2.text === "") {
                errors.push(qsTr("User password confirmation"));
                console.warn("No User pass2");
                _usrPass2.warnIconColor = Style.appErrColor;
                _usrPass2.isWarningShown = true;
                _usrPass2.warnToolTiptext = qsTr("Field can't be empty");
                _usrPass2.warnPopUpMessage = qsTr("Password confirmation not entered!");
            }

            if (!_registerLocalUserPage.similarPasswords && _usrPass.text && _usrPass2.text) {
                errors.push(qsTr("Passwords do not match"));
                console.warn("Different passwords");
                setErrorPassFields(_usrPass,_usrPass2);
                _usrPass.warnToolTiptext = qsTr("Those passwords didn’t match.");
                _usrPass.warnPopUpMessage = qsTr("Please enter similar passwords");
                _usrPass2.warnToolTiptext = qsTr("Those passwords didn’t match.");
                _usrPass2.warnPopUpMessage = qsTr("Please enter similar passwords");
            }

            if (errors.length > 0) {
                Global.notification.showWarningMessage("Please, fill marked fields to proceed!\nFields to check: %1".arg(errors.join(", ")));
                return
            }

            if (!_usrPass.validInput || !_usrPass2.validInput) {
                console.log("Password insecure")
                Global.notification.showWarningMessage(_registerLocalUserPage.weekPass, 20000);
            }

            if (!errors.length && _usrPass.validInput && _usrPass2.validInput && _registerLocalUserPage.similarPasswords) {
                console.log("Validation successfuly done")
                var res = DBManager.registerNewUser(_userName.text, _usrPass.text);

                if (!res) {
                    console.log("User created succesfully");
                    Global.mainStackView.replacePage("qrc:/gui/pages/localAccount/LoginUser.qml", {args: {userName: _userName.text}});
                } else if (res === 1) {
                    console.error("DB error!");
                    Global.notification.showErrorMessage("An error occurred! Please, try again", 5000);
                } else {
                    Global.notification.showWarningMessage("User already exists!", 5000);
                }
            }

            function setErrorPassFields(field1, field2) {
                field1.isWarningShown = true;
                field2.isWarningShown = true;
                if (field1.validInput || field2.validInput) {
                    field1.setUnderlineColor = Style.appErrColor;
                    field2.setUnderlineColor = Style.appErrColor;
                    field1.warnIconColor = Style.appErrColor;
                    field2.warnIconColor = Style.appErrColor;
                }
            }
        }
    }
}
