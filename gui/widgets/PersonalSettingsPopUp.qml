import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Qt.labs.qmlmodels
import Qt5Compat.GraphicalEffects

import gui

Popup{
    id: _userPersSettingsPopUp
    anchors.centerIn: parent
    width: 500
    height: 400
    focus: true
    closePolicy: _userPersSettingsPopUp.CloseOnEscape | _userPersSettingsPopUp.CloseOnPressOutsideParent | _userPersSettingsPopUp.NoAutoClose

    property int currentIndex: 0
    property int radiusPopUp: 3

    RectangularGlow {
        id: _effect
        anchors.fill: parent
        anchors.margins: -15
        glowRadius: 7
        spread: 0.2
        color: Style.mainAppColor
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -15
        color: Style.bgColor
        radius: _userPersSettingsPopUp.radiusPopUp

        // Title setting buttons
        TabBar {
            id: _bar
            anchors.top: parent.top;
            width: parent.width; height: 40
            spacing: 2
            background: Rectangle {
                anchors.fill: parent
                color: Style.bgColor
                radius: _userPersSettingsPopUp.radiusPopUp
            }
            property var settingsButtonModel: ["General"] // TabNames

            Repeater {
                id: _tabButtons
                model: _bar.settingsButtonModel

                TabButton {
                    anchors.top: parent.top
                    height: _bar.height+1
                    width: Math.max(100, _bar.width / _bar.settingsButtonModel.length) - _bar.spacing + (_bar.spacing/_bar.count)

                    background: Rectangle {
                        radius: (_bar.currentIndex === index) ? _userPersSettingsPopUp.radiusPopUp : 0
                        color: (_bar.currentIndex === index) ? Style.bgColor : Style.mainAppColor
                    }
                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: (_bar.currentIndex === index) ? Style.mainTextColor : Style.bgColor
                    }
                    onClicked: {
                        console.log(_bar.currentIndex)
                        console.log(_bar.settingsButtonModel[_bar.currentIndex], ": PersonalSettingsTab is active")
                    }
                }
            }
        }

        //Ambient light :)
        Rectangle {
            id : decorator
            visible: _bar.count > 1;
            property real targetX: _bar.currentItem ? _bar.currentItem.x : 0
            anchors.top: _bar.top;
            width: _bar.currentItem ? _bar.currentItem.width : 0; height: 2;
            color: Style.appAmbientLightColor;
            radius: 5;

            NumberAnimation on x {
                duration: 200;
                to: decorator.targetX
                running: decorator.x !== decorator.targetX
            }
        }

        Rectangle {
            id: _general
            anchors.top: _bar.bottom; anchors.centerIn: parent;
            width: parent.width;
            height: parent.height - (_bar.height + _bottomRow.height + 25);
            color: Style.appTransparent;
            visible: _bar.settingsButtonModel[_bar.currentIndex] === "General"

            Column {
                anchors{
                    horizontalCenter: parent.horizontalCenter;
                    top: _general.top;
                    topMargin: 30
                }

                spacing: 10

                Row {
                    id: _schemeRow
                    spacing: 10

                    Label {
                        text: qsTr( "Color scheme:" )
                        color: Style.mainTextColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    BaseComboBox {
                        id: _schemeBox
                        model: ["Dark scheme", "Light scheme", "Test scheme"];

                        width: 150

                        onCurrentTextChanged: {
                            console.info("Picked Color:", _schemeBox.currentText);
                        }
                    }
                }
            }
        }

        RowLayout {
            id: _bottomRow
            anchors.top: _general.bottom
            width: parent.width
            spacing: 15

            BaseButton {
                id: _ApplyBtn
                Layout.preferredWidth: parent.width / 2.5
                Layout.alignment: Qt.AlignHCenter
                expectedHeight: 40; expectedWidth: 60

                buttonText: qsTr( "Apply" )
                baseColor: Style.mainAppColor; borderColor: Style.mainAppColor
                onClicked: {
                    // Scheme changes
                    if (_schemeBox.currentText === "Dark scheme"){
                        Style.currenTheme = Style.themes.darkTheme
                        Global.appSettings.progressAnimation = "qrc:/gui/images/progress_blocks-dark.gif"
                    }
                    if (_schemeBox.currentText === "Light scheme"){
                        Style.currenTheme = Style.themes.lightTheme
                        Global.appSettings.progressAnimation = "qrc:/gui/images/progress_blocks-light.gif"
                    }
                    if (_schemeBox.currentText === "Test scheme"){
                        Style.currenTheme = Style.themes.testTheme
                        Global.appSettings.progressAnimation = "qrc:/gui/images/progress_blocks-dark.gif"
                    }
                        Global.appSettings.lastUsedColourScheme = _schemeBox.currentText //store current color scheme into setting

                    console.info("_schemeBox.currentIndex",_schemeBox.currentIndex)
                    console.info("_schemeBox.currentText",_schemeBox.currentText)
                    _userPersSettingsPopUp.close();
                }
            }

            BaseButton {
                id: _CancelBtn
                Layout.preferredWidth: parent.width / 2.5
                Layout.alignment: Qt.AlignHCenter
                expectedHeight: 40; expectedWidth: 60

                buttonText: qsTr( "Cancel" )
                baseColor: Style.appTransparent; borderColor: Style.mainAppColor
                onClicked: {
                    _userPersSettingsPopUp.close();
                }
            }
        }
    }

    Component.onCompleted: {
        var scheme = Global.appSettings.lastUsedColourScheme;

        if (scheme === "Dark scheme") {
            _schemeBox.currentIndex = _schemeBox.model.indexOf(scheme);
            Style.currenTheme = Style.themes.darkTheme
        } else if (scheme === "Light scheme"){
            _schemeBox.currentIndex = _schemeBox.model.indexOf(scheme);
            Style.currenTheme = Style.themes.lightTheme
        } else if (scheme === "Test scheme"){
            _schemeBox.currentIndex = _schemeBox.model.indexOf(scheme);
            Style.currenTheme = Style.themes.testTheme
        }
    }
}
