import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

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
            text: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER" ? "All projects" : "My projects"
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
        id: _createProjectButton

        anchors {
            left: parent.left
            leftMargin: 5
        }

        z: 1
        expectedWidth: 30
        expectedHeight: 20
        baseColor: Style.bgColor
        borderColor: Style.mainTextColor
        textColor: Style.mainTextColor
        buttonText: "Create project"
        font.family: Style.fontName
        tooltipText: "Create new project"
        clip: true
        visible: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER"

        onClicked: {
            _projectCreation.open();
        }

        ProjectDialog {
            id: _projectCreation

            onNewModelChanged: {
                listView.model = newModel ? newModel : listView.model;
            }
        }
    }

    BaseButton {
        id: _deleteProjectButton

        anchors {
            left: _createProjectButton.right
            leftMargin: 10
        }

        z: 1
        expectedWidth: 30
        expectedHeight: 20
        baseColor: Style.bgColor
        borderColor: Style.mainTextColor
        textColor: Style.mainTextColor
        buttonText: "Delete project(s)"
        font.family: Style.fontName
        tooltipText: "Delete selected projects"
        clip: true
        visible: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER"
        enabled: false

        onClicked: {
            DBManager.removeProjects(listView.checkedItems);
            listView.model = DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER" ? DBManager.getAllProjects()
                                        : DBManager.getUserProjects(Global.settings.lastLoggedLocalUser.username);
        }
    }

    BaseButton {
        id: _saveChangesButton

        anchors {
            left: _deleteProjectButton.right
            leftMargin: 10
        }

        z: 1
        expectedWidth: 30
        expectedHeight: 20
        baseColor: Style.bgColor
        borderColor: Style.mainTextColor
        textColor: Style.mainTextColor
        buttonText: "Save changes"
        font.family: Style.fontName
        tooltipText: "Save project changes"
        clip: true
        enabled: false
        visible: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER"

        onClicked: {
            var res = DBManager.changeProjectNameDesc(listView.model[listView.currentIndex], _projectName.text, _projectDescription.text);

            if (res === 0) {
                Global.notification.showSuccessMessage("Project name/description was changed successfully");
                listView.model = DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER" ? DBManager.getAllProjects()
                                            : DBManager.getUserProjects(Global.settings.lastLoggedLocalUser.username);
                console.log("Project name/desc changed");
                enabled = false;
                buttonText = "Save changes";
            } else if (res === 1) {
                Global.notification.showErrorMessage("Could not change project name/description!");
                console.error("Some DB error");
            } else {
                Global.notification.showWarningMessage("This project name already exists!");
                console.warn("Project name already used");
            }
        }
    }

    BaseButton {
        id: _createTaskButton

        anchors {
            right: parent.right
            rightMargin: 5
        }

        z: 1
        expectedWidth: 30
        expectedHeight: 20
        baseColor: Style.bgColor
        borderColor: Style.mainTextColor
        textColor: Style.mainTextColor
        buttonText: "Create task"
        font.family: Style.fontName
        tooltipText: "Create new task"
        clip: true
        visible: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER"

        onClicked: {
            _taskCreation.open();
        }
    }

    TaskDialog {
        id: _taskCreation
    }

    ScrollView {
        id: scrollView

        anchors {
            left: parent.left
            top: _createProjectButton.bottom
            topMargin: 10
        }

        clip: true

        height: parent.height
        width: 250

        ListView {
            id: listView

            anchors.fill: parent

            property var checkedItems: []

            spacing: 5
            model: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER" ? DBManager.getAllProjects()
                     : DBManager.getUserProjects(Global.settings.lastLoggedLocalUser.username)

            delegate: ItemDelegate {
                id: itemDelegate

                width: listView.width
                height: 50

                background: Rectangle {
                    color: itemDelegate.hovered ? Style.bgTileColor : Style.appTransparent
                    border.width: 1
                    border.color: Style.bgTileColor
                }

                contentItem: Item {
                    anchors.fill: parent

                    Text {
                        id: _itemText

                        anchors {
                            left: parent.left
                            leftMargin: 5
                            verticalCenter: parent.verticalCenter
                        }

                        text: listView.model[index]
                        color: Style.mainTextColor
                        verticalAlignment: Text.AlignVCenter
                        padding: 10
                    }

                    BaseCheckBox {
                        anchors {
                            right: parent.right
                            rightMargin: 25
                            verticalCenter: _itemText.verticalCenter
                        }

                        tooltipText: "Check this box if you want to mark the project for deletion"

                        onIsCheckedChanged: {
                            var checked = listView.checkedItems;

                            if(isChecked) {
                                checked.push(_itemText.text);
                            } else {
                                var index = listView.checkedItems.indexOf(_itemText.text);
                                if(index !== -1) {
                                    checked.splice(index, 1);
                                }
                            }

                            listView.checkedItems = checked;
                        }
                    }
                }

                onClicked: {
                    console.log("Opened project: " + listView.model[index]);
                    listView.currentIndex = index;
                }
            }

            onCheckedItemsChanged: {
                _deleteProjectButton.enabled = checkedItems.length > 0;
                _deleteProjectButton.buttonText = checkedItems.length > 0 ? "Delete project(s)*" : "Delete project(s)";
            }

            onCurrentIndexChanged:  {
                _projectName.text = model[currentIndex];
                _projectDescription.text = DBManager.getProjectDescription(_projectName.text);
                _stackLayout.currentIndex = currentIndex;
            }
        }
    }

    Rectangle {
        id: _projectNameBg

        width: parent.width - (_createProjectButton.width + _deleteProjectButton.width)
        height: 40

        anchors {
            topMargin: 10
            top: _deleteProjectButton.bottom
            right: parent.right
        }

        color: Style.bgColor
        border.color: Style.mainAppColor
        border.width: 1

        TextEdit {
            id: _projectName

            anchors.fill: parent
            readOnly: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) !== "MANAGER"
            color: Style.mainTextColor
            font.family: Style.fontName
            wrapMode: TextEdit.Wrap
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.bold: true
            padding: 10

            onEditingFinished: {
                _saveChangesButton.text = "Save changes*";
                _saveChangesButton.enabled = true;
            }
        }
    }

    Rectangle {
        id: _projectDescBg

        width: parent.width - (_createProjectButton.width + _deleteProjectButton.width)
        height: 80

        anchors {
            topMargin: 10
            top: _projectNameBg.bottom
            right: parent.right
        }

        color: Style.bgColor
        border.color: Style.mainAppColor
        border.width: 1

        ScrollView {

            anchors.fill: parent

            TextEdit {
                id: _projectDescription

                anchors.fill: parent
                readOnly: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) !== "MANAGER"
                color: Style.mainTextColor
                font.family: Style.fontName
                wrapMode: TextEdit.Wrap
                padding: 10

                onEditingFinished: {
                    _saveChangesButton.text = "Save changes*";
                    _saveChangesButton.enabled = true;
                }
            }
        }
    }

    StackLayout {
        id: _stackLayout

        width: parent.width - (_createProjectButton.width + _deleteProjectButton.width)
        height: 1200

        anchors {
            top: _projectDescBg.bottom
            topMargin: 10
            right: parent.right
        }

        currentIndex: listView.currentIndex

        Repeater {
            id: _taskStack

            model: listView.model

            ScrollView {
                Layout.alignment: Qt.AlignTop
                clip: true

                ListView {
                    id: _taskList

                    anchors.fill: parent

                    model: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER" ? DBManager.getAllTasks(_taskStack.model[_stackLayout.currentIndex])
                                                                                    : DBManager.getUserTasks(_taskStack.model[_stackLayout.currentIndex], Global.settings.lastLoggedLocalUser.username)
                    spacing: 10

                    delegate: ItemDelegate {
                        width: parent.width
                        height: 50

                        background: Rectangle {
                            color: Style.appTransparent
                        }

                        contentItem: BaseTask {
                            projectName: listView.model[_stackLayout.currentIndex]
                            taskName: modelData
                        }
                    }
                }
            }
        }
    }
}
