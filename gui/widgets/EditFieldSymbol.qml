import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import gui

Item {
    id: root
    property string toolTiptext
    property string popUpMessage

    visible: false

    height: parent.height
    width: height

    Image {
        id: _clearSymb
        source: "qrc:/gui/images/symbols/edit.png"
        width: 20
        height: 20
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        smooth: true
        visible: false
        mipmap: true
    }

    ColorOverlay {
        id: _clearSymbOverlay
        anchors.fill: _clearSymb
        source: _clearSymb
        color: Style.mainTextColor
        scale:  _editFieldMouseArea.containsMouse ? 1.1 : 1.0
    }

    MouseArea {
        id: _editFieldMouseArea
        anchors.fill: parent
        hoverEnabled: true
    }

    ToolTip{
    id: _clearTextTooltip
        delay: 100
        timeout: 9000
        visible: _editFieldMouseArea.containsMouse

        contentItem: Text {
            text: root.toolTiptext
            color: Style.mainTextColor
        }

        background: Rectangle {
            color: Style.appTransparent
        }
        x: root.width - root.width / 500
        y: root.height / 2 - 15
    }
}
