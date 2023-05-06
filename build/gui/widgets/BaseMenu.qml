import QtQuick
import QtQuick.Controls

import gui

Menu {
    delegate:  MenuItem {
        id: menuItem

        background: Item {
            implicitWidth: 200
            implicitHeight: 30
            anchors.fill: parent
            opacity: enabled ? 1 : 0.3

            Rectangle {
                x: menuItem.indicator.width + 5
                y: menuItem.height - 1
                width: parent.width
                height: 1
                color: menuItem.highlighted ? Style.mainAppColor : Style.appTransparent
            }
        }

        contentItem: Text {
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            leftPadding: menuItem.indicator.width + 5
            text: replaceText(menuItem.text)
            color: menuItem.highlighted ? Style.mainTextColor : Style.mainAppColor
            elide: Text.ElideRight
        }

        function replaceText(txt) {
            var index = txt.indexOf("&");
            if(index >= 0)
                txt = txt.replace(txt.substr(index, 2), ("<u>" + txt.substr(index + 1, 1) +"</u>"));
            return txt;
        }
    }

    background: Rectangle {
        implicitWidth: 200
        gradient: Gradient {
            GradientStop { position: 0.3; color: Style.bgColor }
            GradientStop { position: 1.0; color: "#191611" }
        }
        border.color: Style.bgColor
    }
}
