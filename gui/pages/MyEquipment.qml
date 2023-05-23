import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import Qt.labs.qmlmodels

import gui
import common

Page {
    id: _docsPage

    background: Rectangle {
        width: parent.width
        height: parent.height
        color: Style.bgColor
    }

    header: ToolBar {
        id: toolBar

        background:
            Rectangle {
            implicitHeight: _docsPage.height / 12
            implicitWidth: parent.width
            color: Style.bgColor
        }

        Text {
            text:  DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER" ? "All equipment" : "My equipment"
            font.family: Style.fontName
            anchors.centerIn: parent
            font.pointSize: 20
            color: Style.mainTextColor
        }

        Item {
            id: logOut
            anchors {
                right: parent.right
                top: parent.top
            }
            implicitWidth: 50;
            implicitHeight: 50;

            Image {
                id: _logOut
                width: 32
                height: 32
                anchors.centerIn: logOut
                source: "qrc:/gui/images/appControls/home.png"
                smooth: true
                visible: false
                mipmap: true
            }

            ColorOverlay {
                id: _logOutOverlay
                anchors.fill: _logOut
                source: _logOut
                color: mArealogOut.containsMouse ? Style.mainAppColor : Style.mainTextColor
                scale:  mArealogOut.containsMouse ? 1.05 : 1.0
            }

            MouseArea {
                id: mArealogOut
                anchors.fill: parent
                hoverEnabled: true

                onClicked: {
                    Global.mainStackView.replacePage("qrc:/gui/pages/StartPage.qml");
                }
            }
        }
    }

    Row {
        id: _colNames
        anchors {
            top: parent.top
            left: _addRow.right
            leftMargin: 1
        }

        spacing: 1

        Text {
            text: "Equipment name"
            font.family: Style.fontName
            font.pointSize: 20
            color: Style.mainTextColor
            height: 40
            width: _tableView.width / 4
            horizontalAlignment: Text.AlignHCenter
        }
        Text {
            text: "Assignee"
            font.family: Style.fontName
            font.pointSize: 20
            color: Style.mainTextColor
            height: 40
            width: _tableView.width / 4
            horizontalAlignment: Text.AlignHCenter
        }
        Text {
            text: "Inventory number"
            font.family: Style.fontName
            font.pointSize: 20
            color: Style.mainTextColor
            height: 40
            width: _tableView.width / 4
            horizontalAlignment: Text.AlignHCenter
        }
        Text {
            text: "Status"
            font.family: Style.fontName
            font.pointSize: 20
            color: Style.mainTextColor
            height: 40
            width: _tableView.width / 4
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Column {
        id: _rowsNums
        anchors {
            left: parent.left
            top: _addRow.bottom
            topMargin: 1
        }

        spacing: 1

        Repeater {
            model: _tableView.rows

            Text {
                text: modelData + 1
                font.family: Style.fontName
                font.pointSize: 20
                color: Style.mainTextColor
                height: 40
                width: 40
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    BaseButton {
        id: _addRow

        anchors {
            top: parent.top
            left: parent.left
        }

        expectedWidth: _rowsNums.width
        expectedHeight: 40
        baseColor: Style.bgColor
        borderColor: Style.mainTextColor

        ColorImage {
            anchors.centerIn: parent
            color: Style.mainAppColor
            source: "qrc:/gui/images/symbols/plus.png"
            fillMode: Image.PreserveAspectFit
            width: parent.width - 5
            height: parent.height - 5
        }

        onClicked: {
            console.log("addrow Clicked");
        }
    }

    BaseButton {
        id: _deleteRow

        anchors {
            bottom: parent.bottom
            right: _saveChanges.left
            rightMargin: 10
        }

        expectedWidth: 40
        expectedHeight: 40
        baseColor: Style.bgColor
        borderColor: Style.mainTextColor
        buttonText: "Delete row"
        tooltipText: "Delete selected row"

        onClicked: {
            console.log("delete Clicked");
        }
    }

    BaseButton {
        id: _saveChanges

        anchors {
            bottom: parent.bottom
            right: parent.right
        }

        expectedWidth: 40
        expectedHeight: 40
        baseColor: Style.bgColor
        borderColor: Style.mainTextColor
        buttonText: "Save changes"
        tooltipText: "Save entered changes"

        onClicked: {
            console.log("save Clicked");
        }
    }

    ScrollView {
        anchors {
            top: _colNames.bottom
            topMargin: 1
            bottom: _saveChanges.top
            bottomMargin: 1
            left: _rowsNums.right
            leftMargin: 1
            right: parent.right
        }

        clip: true

        TableView {
            id: _tableView

            anchors.fill: parent

            columnSpacing: 1
            rowSpacing: 1
            boundsBehavior: Flickable.StopAtBounds

            model: EquipmentTableModel {
                id: _model
            }

            delegate: DelegateChooser {
                DelegateChoice {
                    column: 0
                    delegate: Rectangle {
                        implicitHeight: 40
                        implicitWidth: _tableView.width / 4

                        color: Style.bgColor
                        border.color: Style.mainAppColor
                        border.width: 1

                        TextEdit {
                            text: model.name
                            anchors.fill: parent
                            readOnly: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) !== "MANAGER"
                            color: Style.mainTextColor
                            font.family: Style.fontName
                            wrapMode: TextEdit.Wrap
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            padding: 10
                        }
                    }
                }
                DelegateChoice {
                    column: 1
                    delegate: Rectangle {
                        implicitHeight: 40
                        implicitWidth: _tableView.width / 4

                        color: Style.bgColor
                        border.color: Style.mainAppColor
                        border.width: 1

                        TextEdit {
                            text: model.username
                            anchors.fill: parent
                            readOnly: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) !== "MANAGER"
                            color: Style.mainTextColor
                            font.family: Style.fontName
                            wrapMode: TextEdit.Wrap
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            padding: 10
                        }
                    }
                }
                DelegateChoice {
                    column: 2
                    delegate: Rectangle {
                        implicitHeight: 40
                        implicitWidth: _tableView.width / 4

                        color: Style.bgColor
                        border.color: Style.mainAppColor
                        border.width: 1

                        TextEdit {
                            text: model.inventory_number
                            anchors.fill: parent
                            readOnly: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) !== "MANAGER"
                            color: Style.mainTextColor
                            font.family: Style.fontName
                            wrapMode: TextEdit.Wrap
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            padding: 10
                        }
                    }
                }
                DelegateChoice {
                    column: 3
                    delegate: Rectangle {
                        implicitHeight: 40
                        implicitWidth: _tableView.width / 4

                        color: Style.bgColor
                        border.color: Style.mainAppColor
                        border.width: 1

                        TextEdit {
                            text: model.status
                            anchors.fill: parent
                            readOnly: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) !== "MANAGER"
                            color: Style.mainTextColor
                            font.family: Style.fontName
                            wrapMode: TextEdit.Wrap
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            padding: 10
                        }
                    }
                }
            }
        }
    }
}
