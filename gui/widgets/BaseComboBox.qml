import QtQuick
import QtQuick.Controls

import gui

ComboBox {
    id: comboBox

    delegate: ItemDelegate {
        width: comboBox.width
        height: comboBox.height

        Text {
            text: modelData
            color: Style.mainTextColor
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
        }

        background: Rectangle {
            color: highlighted ? Style.appAmbientLightColor : Style.bgTileColor
        }
    }

    contentItem: Text {
        text: comboBox.currentText
        color: Style.mainTextColor
        verticalAlignment: Text.AlignVCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 12
    }

    background: Rectangle {
        color: Style.bgColor
        implicitWidth: 160
        implicitHeight: 40
        border.color: Style.mainAppColor
        border.width: 1
        radius: 4
    }

    indicator: Text {
        font.family: Style.fontName
        text: "\uf0d7"
        color: Style.mainTextColor
        font.pixelSize: 14
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
    }
}
