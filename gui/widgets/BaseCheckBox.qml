import QtQuick
import QtQuick.Controls

import gui

Item {
    id: root
    height: _label.height + _checkBox.height + 5

    property string tooltipText: _toolTip.text
    property string name: _checkBox.text
    property alias isChecked: _checkBox.checked

    Item {
        id: _label
        anchors.top: parent.top
    }

    Item {
        anchors{
            topMargin: 5
            left: parent.left
            right: parent.right
            top: _label.bottom
        }

        CheckBox {
            id: _checkBox

            indicator: Rectangle {
                id: _checkBoxIndicator
                implicitWidth: 16
                implicitHeight: 16
                radius: 2
                scale:  _mAreaCheckBox.containsMouse ? 1.05 : 1.0


                color: _checkBox.down ? _checkBox.palette.light : _checkBox.palette.base
                border.width: _checkBox.visualFocus ? 2 : 1
                border.color: _checkBox.visualFocus ? _checkBox.palette.highlight : _checkBox.palette.mid

                ColorImage {
                    width: parent.width - 2
                    height: parent.height - 2
                    x: (_checkBoxIndicator.width - width) / 2
                    y: (_checkBoxIndicator.height - height) / 2
                    color: (_checkBox.checked) ? Style.mainAppColor : Style.bgColor
                    source: "qrc:/gui/images/symbols/checkmark.png"
                    visible: _checkBox.checkState === Qt.Checked
                }

                Rectangle {
                    x: (parent.width - width) / 2
                    y: (parent.height - height) / 2
                    width: 16
                    height: 3
                    color: _checkBox.palette.text
                    visible: _checkBox.checkState === Qt.PartiallyChecked
                }
            }

            contentItem:  Text {
                anchors.fill: parent
                anchors.leftMargin: _checkBox.indicator.width + 5
                color: _checkBox.checked ? Style.mainTextColor : Style.mainAppColor
                text: name
            }
        }
    }

    MouseArea {
        id: _mAreaCheckBox
        anchors.fill: parent
        cursorShape: Qt.ArrowCursor
        acceptedButtons: Qt.NoButton
        hoverEnabled: true
    }

    ToolTip {
        id: _toolTip
        timeout: 7000
        delay: 1500
        visible: tooltipText ? _mAreaCheckBox.containsMouse : false

        background: Rectangle {
            color: Style.appTransparent
        }
        contentItem: Text {
            text: _toolTip.text
            color: Style.mainTextColor
        }

        x: -6
        y: root.height/1.3
    }
}
