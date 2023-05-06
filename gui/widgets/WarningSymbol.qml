import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import gui

Item {
    id: root
    property string toolTiptext
    property string popUpMessage
    property alias warningSymbolColor: _warningIconOverlay.color
    visible: false
    z:100

    height: parent.height
    width: height

    Image {
        id: _warningIcon
        source: "qrc:/gui/images/symbols/info.png"
        width: 20
        height: 20
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        smooth: true
        visible: false
        mipmap: true
    }

    ColorOverlay {
        id: _warningIconOverlay
        anchors.fill: _warningIcon
        source: _warningIcon
        color: Style.appErrColor
        scale:  _warningIconMouseArea.containsMouse ? 1.1 : 1.0
    }

    MouseArea {
        id: _warningIconMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            console.log("tap on warning symbol, MessageText: ", root.popUpMessage)
            if (root.visible && root.popUpMessage !== "") {
                Global.notification.showWarningMessage(root.popUpMessage, 10000)
                root.visible = false;
            }
        }
    }

    ToolTip{
    id: _warningTooltip
        delay: 100
        timeout: 9000
        visible: _warningIconMouseArea.containsMouse

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
