import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import gui

Rectangle {
    id: _titleBarButton

    property alias buttonImageSource: _buttonImage.source
    property color iconColor
    signal clicked

    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: rootWindow.visibility === Window.Maximized ? -0.5 : -bw/2+0.5

    height: parent.height - (rootWindow.visibility === Window.Maximized ? 1 : bw/2)
    width: height

    radius: 3

    color: _tltBarButtonMouseArea.containsMouse ? Style.appLightGrey : Style.mainAppColor
    border.color: _tltBarButtonMouseArea.pressed ? Style.appLightGrey : Style.mainAppColor

    Image {
        id: _buttonImage
        width: 20
        height: 20
        anchors.centerIn: parent
        source: _titleBarButton.source
        mipmap: true
        smooth: true
    }

    ColorOverlay {
        id: _overlay
        anchors.fill: _buttonImage
        source: _buttonImage
        color: iconColor
        scale:  _tltBarButtonMouseArea.containsMouse ? 1.05 : 1.0
    }

    MouseArea {
        id: _tltBarButtonMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            _titleBarButton.clicked()
        }
    }
}
