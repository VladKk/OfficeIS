import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import gui

Item {
    id: _echoMode

    property bool isToggled: true

    visible: false

    height: parent.height
    width: height

    Image {
        id: _echoIcon
        source: _echoMode.isToggled ? "qrc:/gui/images/symbols/eye-slash.png" : "qrc:/gui/images/symbols/eye.png"
        width: 18
        height: 18
        anchors.centerIn: parent
        anchors.rightMargin: 5
        fillMode: Image.PreserveAspectFit
        visible: false
        smooth: true
    }

    ColorOverlay {
        id: _echoIconOverlay
        anchors.fill: _echoIcon
        source: _echoIcon
        color: Style.mainTextColor
        scale:  _echoMouseArea.containsMouse ? 1.1 : 1.0
    }

    MouseArea {
        id: _echoMouseArea
        hoverEnabled: true
        anchors.fill: parent
        onClicked: {
            _echoMode.isToggled = !_echoMode.isToggled
        }
    }
}
