import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import common
import gui

Dialog {
    id: root

    property bool refresh: false

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
            text: "Add equipment"
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
                buttonText: "Add"
                font.family: Style.fontName
                tooltipText: "Add equipment"
                clip: true
                DialogButtonBox.buttonRole: DialogButtonBox.ApplyRole

                onClicked: {
                    if (!verifyData())
                        return;

                    refresh = false;

                    var res = DBManager.addEquipment(_name.text, _inventoryNum.text);

                    if (!res) {
                        Global.notification.showSuccessMessage("Equipment added successfully");
                        refresh = true;
                        console.log("Equipment added");
                    } else if (res === 1) {
                        Global.notification.showErrorMessage("Something went wrong. Please, try again later");
                        console.log("DB error");
                    } else {
                        Global.notification.showWarningMessage("%1 with this inventory number already exists".arg(_name.text));
                        console.log("Duplicate equipment");
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
                tooltipText: "Cancel equipment addition"
                clip: true
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole

                onClicked: {
                    console.log("Equipment addition cancelled");
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
            id: _name

            Layout.preferredWidth: parent.width / 2.5
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.minimumHeight: height

            labelText: "Equipment name"
            placeHolderText: "Equipment name"
            fieldIcon: "qrc:/gui/images/symbols/pencil.png"

            clearSymbolApplicable: true

            Keys.onEnterPressed: {
                _inventoryNum.forceActiveFocus()
            }
        }

        FormField {
            id: _inventoryNum

            Layout.preferredWidth: parent.width / 2.5
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.minimumHeight: height

            labelText: "Inventory number"
            placeHolderText: "Inventory number"
            fieldIcon: "qrc:/gui/images/symbols/pencil.png"

            clearSymbolApplicable: true
        }
    }

    function verifyData() {
        if (_name.text === "") {
            _name.isWarningShown = true;
            _name.warnToolTiptext = "Enter equipment name";
            _name.warnPopUpMessage = "Equipment name was not entered";
            return false;
        }

        if (_inventoryNum.text === "") {
            _inventoryNum.isWarningShown = true;
            _inventoryNum.warnToolTiptext = "Enter inventory number";
            _inventoryNum.warnPopUpMessage = "Inventory number was not entered";
            return false;
        }

        return true;
    }
}
