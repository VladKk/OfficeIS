import QtQuick
import QtQuick.Controls

import gui

ScrollIndicator {
    id: _scrollIndicator
    size: 0.3
    position: 0.2
    active: true
    orientation: Qt.Vertical

    contentItem: Rectangle {
        implicitWidth: 3
        implicitHeight: 100
        radius: width / 2
        color: Style.appLightGrey
        opacity: _scrollIndicator.policy === _scrollIndicator.active || (_scrollIndicator.active && _scrollIndicator.size < 1.0) ? 0.75 : 0
        Behavior on opacity {
            NumberAnimation {}
        }
    }
}
