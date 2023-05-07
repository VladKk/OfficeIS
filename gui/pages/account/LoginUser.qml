import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import common

import gui

Page {
    id: _localLogInPage

    property var args

    background: Rectangle {
        width: parent.width
        height: parent.height
        color: Style.bgColor
    }

    Rectangle {
        id: appIcon
        width: parent.width
        height: parent.height / 3
        color: Style.bgColor
        Image {
            width: _localLogInPage.width/4
            height: _localLogInPage.height/4
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
            source: "qrc:/gui/images/appIcon.png"
            mipmap: true
        }
    }

    ColumnLayout {
        id: _credFields
        width: parent.width
        anchors.top: appIcon.bottom
        spacing: 15

        FormField {
            id: _localUsrName

            Layout.preferredWidth: parent.width / 2.5
            Layout.alignment: Qt.AlignHCenter
            Layout.minimumHeight: height

            focus: true

            labelText: qsTr( "Login" )
            placeHolderText: qsTr( "Login" )
            fieldIcon: "qrc:/gui/images/symbols/user.png"

            clearSymbolApplicable: true

            Component.onCompleted: {
                if ((typeof _localLogInPage.args !== "undefined")) {
                    _localUsrName.text = _localLogInPage.args.userName
                    console.info( "Newly created userName used for login" )
                }
                else if (Global.settings.lastLoggedLocalUser.username !== "") {
                    console.info("LastLoggedUserName is used")
                    _localUsrName.text = Global.settings.lastLoggedLocalUser.username;
                } else {
                    _localUsrName.text = LOCAL_CRED ? LOCAL_CRED.split(':')[0] : ""
                    console.debug("Env var usrName is used")
                }
            }

            Keys.onReturnPressed: {
                _localUsrPassword.forceActiveFocus();
            }

            onTextChanged: { // Link enabled state to text content and drop isChecked if text is empty to let user set it again
                _rmbMe.enabled = text;

                if (!text)
                        _rmbMe.isChecked = false;
            }
        }
        Item {
            height: 0
        }
        FormField {
            id: _localUsrPassword

            Layout.preferredWidth: parent.width / 2.5
            Layout.alignment: Qt.AlignHCenter
            Layout.minimumHeight: height

            isPassField: true

            labelText: qsTr( "Password" )
            placeHolderText: qsTr( "Password" )
            fieldIcon: (_localUsrPassword.text.length >= 5) ? "qrc:/gui/images/symbols/lock.png" : "qrc:/gui/images/symbols/lock-open.png"

            Component.onCompleted: {
                if (_rmbMe.isChecked) {
                    console.info("RememberMe is checked thus LastLoggedUserName is used to retrive user pass");
                } else {
                    _localUsrPassword.text = LOCAL_CRED ? LOCAL_CRED.split(':')[1] : ""
                    console.debug("usrPassword from environment used")
                }
            }
            Keys.onReturnPressed: {
                _localLogInBtn.clicked();
            }

            onTextChanged: { // Link enabled state to text content and drop isChecked if text is empty to let user set it again
                _rmbMe.enabled = text;

                if (!text)
                        _rmbMe.isChecked = false;
            }
        }

        Item {
            height: 10
        }

        BaseCheckBox {
            id: _rmbMe

            Layout.preferredWidth: parent.width / 2.5
            Layout.alignment: Qt.AlignHCenter
            Layout.leftMargin: 10

            name: "Remember me"
            tooltipText: qsTr( "Check if you do not want to enter credenetials in future?" )

            Component.onCompleted: {
                var userData = DBManager.checkUserIsRemembered(Global.settings.lastLoggedLocalUser.username);

                if ((Global.settings.lastLoggedLocalUser.username !== "") && userData.isRemembered) {
                    _rmbMe.isChecked = true;
                    _localUsrPassword.text = userData.password;
                }
                isCheckedChanged.connect(()=>{
                    DBManager.setRememberMe(_localUsrName.text, isChecked);
                    if (isChecked) {
                        Global.notification.showWarningMessage(qsTr( "'Remember Me' enabled.\nNo need to enter your login information every time you open JirApp.\nNote: Not recommended on shared devices." ), 5000);
                    }
                })
            }
        }
    }

    ColumnLayout {
        id: _credentialButtons
        width: parent.width
        anchors.top: _credFields.bottom
        anchors.topMargin: 30
        spacing: 15

        BaseButton {
            id: _localLogInBtn
            Layout.preferredWidth: parent.width / 2.5
            Layout.alignment: Qt.AlignHCenter
            expectedHeight: 50
            expectedWidth: 100

            buttonText: qsTr( "Log In" )
            baseColor: Style.mainAppColor
            borderColor: Style.mainAppColor

            BusyIndicator {
                id: _busyIndicator
                anchors {
                    centerIn: parent
                    right: parent.right
                }
                width: parent.width / 1.2
                height: parent.height / 1.2
                running: false
                visible: false
            }

            onClicked: {
                const login = _localUsrName.text;
                const password = _localUsrPassword.text;

                internal.validateUserCredentials(login, password)
            }
        }

        BaseButton {
            id: registerBtn
            Layout.preferredWidth: parent.width / 2.5
            Layout.alignment: Qt.AlignHCenter
            expectedHeight: 50
            expectedWidth: 100

            buttonText: qsTr( "Sign Up" )
            baseColor: Style.appTransparent
            borderColor: Style.mainAppColor

            onClicked: {
                if(_localLogInBtn.enabled === false) {
                    Global.notification.showWarningMessage(qsTr( "Unable to open sign up screen during sign in process" ), 3000);
                    return
                }
                Global.mainStackView.replacePage("qrc:/gui/pages/account/RegisterUser.qml");
            }
        }

        Text {
            id: fgtPwd
            text: qsTr( "Forgot password?" )
            font.underline: true
            color: Style.mainTextColor
            opacity: _fgtPwdMArea.containsMouse ? 1.0 : 0.5
            Layout.alignment: Qt.AlignHCenter
            font.pointSize: 12
            Layout.margins: 10

            MouseArea {
                id: _fgtPwdMArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    if(_localLogInBtn.enabled === false) {
                        Global.notification.showWarningMessage(qsTr( "Unable to open sign up screen during sign in process" ), 3000);
                        return
                    }
                    Global.mainStackView.pushPage("qrc:/gui/pages/account/ForgetPass.qml")
                }
            }
        }
    }

    QtObject {
        id: internal

        function validateUserCredentials(usrName, usrPwd) {
            if (DBManager.userIsOnline(usrName)) {
                Global.notification.showWarningMessage("User %1 is already logged in!".arg(usrName), 5000);
                return;
            }

            _localLogInBtn.enabled = false;
            _busyIndicator.running = true;
            _busyIndicator.visible = true;

            var errors = [];

            if (usrName === "") {
                errors.push(qsTr( "User name" ));
                console.warn("No user name");
                _localUsrName.isWarningShown = true;
                _localUsrName.warnToolTiptext = qsTr( "Enter User name" );
                _localUsrName.warnPopUpMessage = qsTr( "User name was not entered!" );
                Global.notification.showWarningMessage(qsTr( "No User Name entered!" ), 5000);
            }

            if (usrPwd === "") {
                errors.push(qsTr( "Password" ));
                console.warn("No password");
                _localUsrPassword.isWarningShown = true;
                _localUsrPassword.warnToolTiptext = qsTr( "Enter User password" );
                _localUsrPassword.warnPopUpMessage = qsTr( "No User password entered!" );
            }

            if (usrName === "" && usrPwd === "" ) {
                errors.push(qsTr( "User credentials!" ));
                console.warn("No credentials")
                _localUsrName.warnToolTiptext = qsTr( "Enter User name" );
                _localUsrName.warnPopUpMessage = qsTr( "User name was not entered!" );
                _localUsrPassword.isWarningShown = true;
                _localUsrPassword.warnToolTiptext = qsTr( "Enter User password" );
                _localUsrPassword.warnPopUpMessage = qsTr( "No User credentials entered!" );
                _localUsrName.warnPopUpMessage = qsTr( "No User credentials entered!" );
            }

            if (errors.length > 0) {
                for(var i = 0; i < errors.length; i++) {
                    Global.notification.showWarningMessage(errors[i], 5000);
                    _localLogInBtn.enabled = true;
                    _busyIndicator.running = false;
                    _busyIndicator.visible = false;
                    return;
                }
            } else {
                var message = ""

                _busyIndicator.running = false;
                _busyIndicator.visible = false;
                _localLogInBtn.enabled = true;

                switch(DBManager.checkAccount(usrName, usrPwd)) {
                case 0:
                    DBManager.setIsOnline(usrName, true);
                    Global.settings.lastLoggedLocalUser = {username: usrName, isRemembered: _rmbMe.isChecked};
                    Global.mainStackView.replacePage("qrc:/gui/pages/StartPage.qml")
                    _localLogInBtn.enabled = true;
                    _busyIndicator.running = false;
                    _busyIndicator.visible = false;
                    break;
                case 1: message = qsTr( "User account does not exist in application!\nPlease \"Sign Up\" first!" );
                    console.warn("Local user: " + usrName + " tried login to the system, but such user doesn't exists in DB");
                    break;
                case 2: message = qsTr( "Something went wrong!\n- You've entered wrong credentials, try again!" );
                    console.warn("Invalid credentials!");
                    break;
                case 3: message = qsTr( "User account does not exist in application!\nPlease \"Sign Up\" first!" );
                    console.error("Undefined clear reason: either UserDB not exists or not existing user!")
                    console.log("Local user: " + usrName + " tried login to the system, but such user doesn't exists in DB")
                    break;
                }

                if (message) {
                    Global.notification.showWarningMessage(message, 5000);
                }
                return;
            }
        }
    }
}
