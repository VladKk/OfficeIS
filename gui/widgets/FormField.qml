import QtQuick.Controls
import QtQuick
import Qt5Compat.GraphicalEffects

import gui

Item {
    id: root
    height: labelText.length > 0 ? _label.height + _textField.height + 5 : _textField.height + 5

    property alias labelText: _label.text
    property alias placeHolderText: _textField.placeholderText
    property alias tooltipText: _toolTip.text
    property string fieldIcon: ""

    property string weekPassMessage: ""
    property string weekPassToolTip: ""
    property alias validInput: _textField.acceptableInput
    property alias setUnderlineColor: _underline.color
    property alias warnIconColor: _warnSign.warningSymbolColor
    property var regExpression

    property alias text: _textField.text
    property alias echoMode: _textField.echoMode
    property alias textUneditable: _textField.readOnly

    property alias isWarningShown: _warnSign.visible
    property alias isEditShown: _editSymbol.visible
    property alias warnPopUpMessage: _warnSign.popUpMessage
    property alias warnToolTiptext: _warnSign.toolTiptext

    property bool isPassField: false
    property bool clearSymbolApplicable: false
    property bool fieldValidation: false

    function copy() { _textField.copy() }
    function cut() { _textField.cut() }
    function paste() { _textField.paste() }

    echoMode: (_echoMode.isToggled && isPassField) ? TextField.Password : TextField.Normal

    onTextChanged: {
        _warnSign.visible = false

        if (_textField.text.trim().length === 0) {
            // Text is empty
            _underline.color = Style.mainAppColor;
        } else if (_textField.acceptableInput && fieldValidation) {
            // Text is valid
            _underline.color = Style.appSuccessColor;
            _underlineColorTimer.stop();
            _underlineColorTimer.interval = 500;
            _underlineColorTimer.start();
        } else if (!_textField.acceptableInput && _textField.text && fieldValidation) {
            // Text is still not valid
            _underlineColorTimer.stop();
            _underline.color = Style.appWarnColor;
            setWeekPassWarning(weekPassMessage, weekPassToolTip);
        } else if (_textField.text.trim().length === _textField.length && !_textField.acceptableInput) {
            // Text is not valid
            _underline.color = Style.appErrColor;
            _underlineColorTimer.stop();
            _underlineColorTimer.interval = 500;
            _underlineColorTimer.start();
        }
    }

    Label {
        id: _label
        text: _label.text
        color: Style.mainAppColor
        font.pixelSize: 12
        elide: Text.ElideRight
        visible: _textField.text !== "" ? true : false

        anchors {
            top: parent.top
            left: _textField.left
            right: _textField.right
        }
    }

    TextField {
        id: _textField

        opacity: textUneditable ? 0.5 : 1

        onActiveFocusChanged: {
            if (focus) {
                Global.copyItem = root;
            }
        }

        anchors {
            topMargin: 5
            left: parent.left
            right: parent.right
            top: _label.bottom
        }

        selectByMouse: true
        rightPadding: _echoMode.width + 10

        validator: RegularExpressionValidator {
            regularExpression: (typeof root.regExpression !== 'undefined') ? root.regExpression : /.*/
        }

        placeholderTextColor: Style.mainAppColor
        color: Style.mainTextColor
        font.pointSize: 12
        leftPadding: fieldIcon !== "" ? 35 : 10
        font.family: Style.fontName
        selectionColor: Style.mainAppColor

        background: Rectangle {
            color: Style.appTransparent
            Image {
                id: _fieldIcon

                visible: false

                height: 16
                width: 16
                source: fieldIcon

                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter

                fillMode: Image.PreserveAspectFit
                mipmap: true
            }

            ColorOverlay {
                id: _fieldIconOverlay
                anchors.fill: _fieldIcon
                source: _fieldIcon
                color: Style.mainAppColor
                scale:  _textFieldMouseArea.containsMouse ? 1.1 : 1.0
            }

            MouseArea {
                id: _textFieldMouseArea
                anchors {
                    fill: parent
                    margins: -10
                }
                cursorShape: Qt.IBeamCursor
                hoverEnabled: true
            }

            ToolTip {
                id: _toolTip
                text: _toolTip.text
                delay: 1000
                timeout: 7000
                visible: tooltipText.length > 0 ? _textFieldMouseArea.containsMouse : null
            }

            Rectangle {
                id: _underline
                width: parent.width - 10
                height: 1
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                }
                color: Style.mainAppColor;
            }
        }

        ContextMenu {
            id: _contextMenu
        }

        MouseArea {
            anchors {
                fill: parent
                margins: -10
            }
            acceptedButtons: Qt.RightButton
            hoverEnabled: false
            cursorShape: Qt.IBeamCursor
            onClicked: (mouse)=> {
                           if (mouse.button === Qt.RightButton)
                           _contextMenu.popup()
                           console.log(placeHolderText,"Context menu called")
                       }
        }
    }

    Timer {
        id: _underlineColorTimer
        interval: 1000
        running: false
        onTriggered: {
            if (_textField.text.trim().length === 0) {
                _underline.color = Style.mainAppColor;
            } else if (_textField.text.trim().length !== 0 && _textField.acceptableInput ) {
                _underline.color = Style.mainAppColor;
                unSetWeekPassWarning();
            } else {
                _underline.color = Style.appErrColor;
            }
        }
    }

    function setWeekPassWarning(message, toolTip) {
        _warnSign.popUpMessage = message;
        _warnSign.toolTiptext = toolTip;
        _warnSign.warningSymbolColor = Style.mainAppColor;
        _warnSign.visible = true;
    }

    function unSetWeekPassWarning() {
        weekPassMessage = "";
        weekPassToolTip = "";
        _warnSign.visible = false;
        _warnSign.warningSymbolColor = Style.appErrColor;
    }

    WarningSymbol {
        id: _warnSign
        anchors {
            top: _textField.top
            topMargin: 5
            right: _textField.right
            rightMargin: -23
            verticalCenter: _textField.verticalCenter
        }
    }

    EditFieldSymbol {
        id: _editSymbol

        visible: !isWarningShown && isEditShown
        anchors {
            top: _textField.top
            topMargin: 5
            right: _textField.right
            rightMargin: -29
            verticalCenter: _textField.verticalCenter
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (parent.visible) {
                    console.log(placeHolderText,"- form field Edit clicked and set:",isEditShown)
                    parent.visible = false;
                    _textField.readOnly = false;
                }
            }
        }
    }

    EchoModeSymbol {
        id: _echoMode
        visible: _textField.text !== "" && isPassField && !textUneditable

        anchors {
            top: _textField.top
            topMargin: 5
            right: _textField.right
            rightMargin: 5
            verticalCenter: _textField.verticalCenter
        }
    }

    //clear text field
    ClearSymbol {
        id: _clearSign

        visible: _textField.text !== "" && !isPassField && clearSymbolApplicable && !textUneditable

        anchors {
            top: _textField.top
            topMargin: 5
            right: _textField.right
            rightMargin: 5
            verticalCenter: _textField.verticalCenter
        }

        //catch signal
        onClear: { _textField.text = "" }

        //remove lastChar
        onRemoveLast: {
            _textField.text = _textField.text.substring(0, _textField.text.length - 1);
        }
    }
}
