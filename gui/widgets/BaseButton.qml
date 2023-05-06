import QtQuick
import QtQuick.Controls

import gui

Button {
    id: _control
    font.pointSize: 15
    flat: true
    hoverEnabled: false

    property alias buttonText: _control.text
    property alias tooltipText: _toolTip.text
    property color baseColor
    property color borderColor
    property color textColor
    property int expectedWidth
    property int expectedHeight

    onDownChanged: {
        _toolTip.hide()
    }

    contentItem: Text {
        text: _control.text
        font: _control.font
        color: (Style.getContrastingColor(baseColor) === "black") ? Style.bgColor : Style.mainAppColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        implicitWidth: expectedWidth
        implicitHeight: expectedHeight
        color: baseColor
        border.color: borderColor
        opacity: _controlMouseArea.containsMouse ? 0.6 : 1
        scale:  _controlMouseArea.containsMouse ? 1.005 : 1.0
        smooth: _controlMouseArea.containsMouse

        radius: 3

        ToolTip {
            id: _toolTip
            delay: 1500
            timeout: 7000
            visible: tooltipText ? _controlMouseArea.containsMouse : false

            contentItem: Text {
                text: _toolTip.text
                color: Style.mainTextColor
            }
            background: Rectangle {
                color: Style.appTransparent
            }
            x: _control.width + _control.width / 32
            y: _control.height - (_control.height / 1.25)
        }

        MouseArea {
            id: _controlMouseArea
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            hoverEnabled: true
        }
    }
}
