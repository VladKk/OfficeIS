import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import gui

Item {
    id: root
    property string toolTiptext
    property string popUpMessage

    signal clear
    signal removeLast

    visible: false

    height: parent.height
    width: height

    Image {
        id: _clearIcon
        source: "qrc:/gui/images/symbols/close.png"
        width: 13
        height: 13
        anchors.centerIn: parent
        anchors.rightMargin: 5
        fillMode: Image.PreserveAspectFit
        smooth: true
        visible: false
        mipmap: true
    }

    ColorOverlay {
        id: _clearIconOverlay
        anchors.fill: _clearIcon
        source: _clearIcon
        color: Style.mainTextColor
        scale:  _clearMouseArea.containsMouse ? 1.1 : 1.0
    }

    MouseArea {
        id: _clearMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (root.visible) {
                root.clear()
            }
        }
    }

    ToolTip{
    id: _clearTextTooltip
        delay: 100
        timeout: 9000
        visible: _clearMouseArea.containsMouse

        contentItem: Text {
            text: root.toolTiptext
            color: Style.mainTextColor
        }

        background: Rectangle {
            color: Style.appTransparent
        }
        x: root.width - root.width / 500
        y: root.height/2 - 15
    }
}
