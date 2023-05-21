import QtQuick
import QtQuick.Controls

import gui
import common

Item {
    id: root

    property date defaultDate
    property date minDate: new Date(1970, 0, 1) // 1st of January 1970
    property date maxDate: new Date(2060, 11, 31) // 31st of December 2060
    property alias readonly: dateInput.readOnly
    property alias text: dateInput.text

    TextField {
        id: dateInput
        width: parent.width
        anchors.centerIn: parent
        text: Qt.formatDate(defaultDate, "dd/MM/yyyy")
        validator: RegularExpressionValidator { regularExpression: /^(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[012])\/(19[0-9][0-9]|20[0-5][0-9]|2060)$/ }
        inputMethodHints: Qt.ImhDate

        placeholderTextColor: Style.mainAppColor
        color: Style.mainTextColor
        font.pointSize: 12
        verticalAlignment: Text.AlignVCenter
        font.family: Style.fontName
        selectionColor: Style.mainAppColor

        background: Rectangle {
            color: Style.appTransparent
            border.color: Style.mainAppColor
            border.width: 1

            MouseArea {
                id: _textFieldMouseArea
                anchors {
                    fill: parent
                    margins: -10
                }
                cursorShape: Qt.IBeamCursor
                hoverEnabled: true
            }
        }

        onAccepted: {
            var parts = text.split(".");
            var inputDate = new Date(parts[2], parts[1] - 1, parts[0]);
            if (inputDate < minDate || inputDate > maxDate) {
                text = Qt.formatDate(new Date(), "dd/MM/yyyy");
            }
        }
    }
}
