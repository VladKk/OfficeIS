import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import gui

Button {
    id: root

    property alias buttonName: _textButton.text
    property alias buttonImage: _buttonImage.source
    flat: true
    hoverEnabled: false

    width: 140
    height: 140

    //Button animation
    background: Rectangle {
        anchors.fill: parent
        color: _controlMouseArea.containsMouse ? Style.bgColor : Style.bgTileColor
        border.color: _controlMouseArea.containsMouse ? Style.bgTileColor : Style.bgColor

        opacity: _controlMouseArea.containsMouse ? 0.6 : 1
        scale:  _controlMouseArea.containsMouse ? 1.01 : 1.0
        smooth: _controlMouseArea.containsMouse

        MouseArea {
            id: _controlMouseArea
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            hoverEnabled: true
        }
    }

    //Button name
    Text {
        id: _textButton
        text: buttonName

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 5
            rightMargin: 5
        }

        font.pointSize: 15
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: Style.mainTextColor
        scale: root.down ? 1.03 : 1.0

        wrapMode: Text.Wrap
        clip: true
    }

    Image {
        id: _buttonImage
        width: 35
        height: 35
        anchors.centerIn: parent
        source: _buttonImage.source
        mipmap: true
        smooth: true
    }

    ColorOverlay {
        id: _overlay
        anchors.fill: _buttonImage
        source: _buttonImage
        color: Style.mainTextColor
        scale: root.down ? 1.03 : 1.0
    }

    onClicked: {
        Global.notification.showMessage(qsTr( "Functionality not implemented yet" ), 10000);
        console.log("%1 clicked".arg(buttonName));
    }
}
