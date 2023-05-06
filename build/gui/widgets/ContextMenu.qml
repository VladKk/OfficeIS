import QtQuick
import QtQuick.Controls

import gui

Menu {
    delegate:  MenuItem {
        id: menuItem

        background: Item {
            anchors.fill: parent
            opacity: enabled ? 1 : 0.3

            Rectangle {
                x: 5
                y: menuItem.height - 1
                width: parent.width - x*2
                height: 1
                color: menuItem.highlighted ? Style.mainAppColor : Style.appTransparent
            }
        }

        contentItem: Text {
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            text: replaceText(menuItem.text)
            color: menuItem.highlighted ? Style.mainTextColor : Style.mainAppColor
            elide: Text.ElideRight
        }

        function replaceText(txt)
        {
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

    Action {
        text: qsTr("Cu&t")
        onTriggered: {
            if (Global.copyItem) {
                Global.copyItem.cut();
            }
        }
    }
    Action {
        text: qsTr("&Copy")
        onTriggered: {
            if (Global.copyItem) {
                Global.copyItem.copy();
            }
        }
    }
    Action {
        text: qsTr("&Paste")
        onTriggered: {
            if (Global.copyItem) {
                Global.copyItem.paste();
            }
        }
    }
}


