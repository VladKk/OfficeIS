import QtQuick
import QtQuick.Controls

import gui

Page {
    id: _about

    background: Rectangle {
        anchors.fill: parent
        color: Style.bgColor
    }

    header: ToolBar {
        id: _aboutHeadar

        background:
            Rectangle {
            implicitHeight: _about.height / 12
            implicitWidth: parent.width
            color: Style.bgColor
        }

        Item {
            id: logOut
            anchors {
                left: parent.left
                top: parent.top
            }
            implicitWidth: 50;
            implicitHeight: 50;

            Text {
                text: "\uf060"
                font.family: Style.fontName
                font.pixelSize: Qt.application.font.pixelSize * 2
                anchors.centerIn: logOut

                color: mArealogOut.containsMouse ? Style.mainAppColor : Style.mainTextColor
                scale:  mArealogOut.containsMouse ? 1.10 : 1.0
                smooth: mArealogOut.containsMouse
            }

            MouseArea {
                id: mArealogOut
                anchors.fill: parent
                hoverEnabled: true

                onClicked: {
                    Global.mainStackView.pop()
                }
            }
        }

        Text {
            text: qsTr( "About OfficeIS" )
            font.family: Style.fontName
            anchors.centerIn: parent
            font.pointSize: 15
            color: Style.mainTextColor
            opacity: 0.6
        }

    }

    Text {
        id: _appName
        anchors{
            top: parent.top
            topMargin: 50
            leftMargin: 50
            left: parent.left
        }
        text: qsTr( "OfficeIS application" )
        color: Style.mainTextColor
    }

    Text {
        id: _author
        anchors{
            top: _appName.bottom
            topMargin: _appName.height * 1.5
            leftMargin: 50
            left: parent.left
        }

        text: qsTr( "Author: " )
        color: Style.mainTextColor
    }

    Text {
        id: _authorText
        anchors{
            top: _appName.bottom
            topMargin: _appName.height * 1.5
            leftMargin: 10
            left: _author.right
        }

        text: "Koliadenko Vladyslav, IN-401z-m"
        color: Style.mainTextColor
        font.bold: true
    }

    Text {
        id: _stack
        anchors{
            top: _author.bottom
            topMargin: _appName.height * 1.5
            leftMargin: 50
            left: parent.left
        }

        text: qsTr( "Used stack: " )
        color: Style.mainTextColor
    }

    Text {
        id: _stackText
        anchors{
            top: _authorText.bottom
            topMargin: _appName.height * 1.5
            leftMargin: 10
            left: _stack.right
        }

        text: qsTr( "Qt6.2, C++, QML, PostgreSQL, CMake, Linux Ubuntu 20.04" )
        color: Style.mainTextColor
        font.bold: true
    }

    Component.onCompleted: {
        console.log("AppAbout page opened")
    }
}
