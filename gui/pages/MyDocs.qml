import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Qt5Compat.GraphicalEffects

import Qt.labs.platform

import gui
import filehandler
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
            text: "My Documents"
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

    BaseButton {
        id: _hideButton

        anchors {
            left: parent.left
            leftMargin: 5
        }

        z: 1
        expectedWidth: 20
        expectedHeight: 20
        baseColor: Style.bgColor
        borderColor: Style.mainTextColor
        textColor: Style.mainTextColor
        buttonText: scrollView.visible ? "\uf060" : "\uf061"
        font.family: Style.fontName
        tooltipText: "Hide left panel"
        clip: true

        onClicked: {
            scrollView.visible = !scrollView.visible;
        }
    }

    BaseButton {
        id: _openFile

        anchors {
            rightMargin: 5
            right: _tabBar.left
        }

        z: 1
        expectedWidth: 30
        expectedHeight: 20
        baseColor: Style.bgColor
        borderColor: Style.mainTextColor
        textColor: Style.mainTextColor
        buttonText: "Open files..."
        font.family: Style.fontName
        tooltipText: "Open file with file browser"
        clip: true

        onClicked: {
            console.log("File selection opened")
            _fileDialog.visible = true;
        }

        FileDialog {
            id: _fileDialog

            visible: false
            folder: StandardPaths.writableLocation(StandardPaths.AppDataLocation) + "/docs"
            fileMode: FileDialog.OpenFiles
            nameFilters: ["Documents (*.doc *.docx *.odt *.pdf *txt)", "Spreadsheets (*.xls *.xlsx *.ods)", "All files (*)"]
            options: FileDialog.ReadOnly | FileDialog.DontResolveSymlinks

            onRejected: {
                console.log("File selection cancelled")
            }

            onAccepted: {
                var combined = FileHandler.getFileNames(currentFiles);
                combined = _docLoader.model.concat(combined);
                combined = combined.filter(function(file, index) {
                    return combined.indexOf(file) === index;
                });

                _docLoader.model = combined;
                console.log("New model: %1".arg(_docLoader.model));
            }
        }
    }

    ScrollView {
        id: scrollView

        anchors {
            left: parent.left
            top: _hideButton.bottom
            topMargin: 10
        }

        clip: true

        height: parent.height
        width: visible ? 250 : 0

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ListView {
            id: listView

            anchors.fill: parent

            spacing: 5
            model: FileHandler.getFileList()

            delegate: ItemDelegate {
                id: itemDelegate

                width: listView.width
                height: 50

                background: Rectangle {
                    color: itemDelegate.hovered ? Style.bgTileColor : Style.appTransparent
                    border.width: 1
                    border.color: Style.bgTileColor
                }

                contentItem: Text {
                    id: _itemText

                    text: listView.model[index]
                    color: Style.mainTextColor
                    verticalAlignment: Text.AlignVCenter
                    padding: 10
                }

                onClicked: {
                    console.log("Opened file: " + listView.model[index]);
                    if (!_docLoader.model.includes(listView.model[index])) {
                        var updatedModel = _docLoader.model.concat(listView.model[index]);
                        _docLoader.model = updatedModel;
                    }

                    _tabBar.currentIndex = _docLoader.model.indexOf(_itemText.text);
                }
            }
        }
    }

    TabBar {
        id: _tabBar

        anchors {
            left: scrollView.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }

        background: Rectangle {
            color: Style.bgColor
        }

        Repeater {
            id: _docLoader

            model: []

            TabButton {
                id: _tabButton

                width: _tabBar.width / _docLoader.model.length
                height: 50

                background: Rectangle {
                    color: _tabButton.checked ? Style.mainAppColor : Style.appTransparent
                }

                contentItem: Item {
                    anchors.fill: parent

                    Label {
                        id: _tabLabel

                        anchors {
                            bottom: parent.bottom
                            left: parent.left
                            right: _tabClose.left
                            rightMargin: 10
                        }

                        text: modelData
                        elide: Text.ElideRight
                        font.family: Style.fontName
                        font.pixelSize: 14
                        color: Style.mainTextColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Button {
                        id: _tabClose

                        anchors {
                            bottom: parent.bottom
                            right: parent.right
                        }

                        width: 20
                        height: 20
                        z: 1

                        icon.source: "qrc:/gui/images/symbols/close.png"

                        background: Rectangle {
                            color: Style.appTransparent
                        }

                        contentItem: Image {
                            source: parent.icon.source
                            fillMode: Image.PreserveAspectFit
                            anchors.centerIn: parent
                            mipmap: true
                        }

                        onClicked: {
                            console.log("%1 closed".arg(_tabLabel.text))
                            _docLoader.removeTab(_tabLabel.text);
                        }
                    }
                }
            }

            function removeTab(tabName) {
                var index = model.indexOf(tabName);

                if (index !== -1) {
                    var refreshedModel = model;
                    refreshedModel.splice(index, 1);
                    model = refreshedModel;
                }
            }
        }
    }

    StackLayout {
        id: _stackLayout

        anchors.topMargin: 50
        anchors.fill: _tabBar
        currentIndex: _tabBar.currentIndex

        Repeater {
            id: _textModel
            model: _docLoader.model

            Rectangle {
                id: _textEditWrapper
                width: 200
                height: 100
                color: Style.bgColor
                border.color: Style.mainAppColor
                border.width: 1

                ScrollView {
                    anchors.fill: parent

                    TextEdit {
                        id: _textEdit
                        width: _textEditWrapper.width
                        height: _textEditWrapper.height
                        text: FileHandler.openFile(_textModel.model[index])
                        readOnly: true
                        color: Style.mainTextColor
                        font.family: Style.fontName
                        wrapMode: TextEdit.Wrap
                        anchors.fill: parent
                        padding: 10
                        selectByMouse: true
                    }
                }
            }
        }
    }
}
