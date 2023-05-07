import QtQuick
import QtQuick.Controls

import gui
import filteringmodel

FilteringModel {
    id: root

    signal appElementSelected(var panelModelUrl)

    MenuTile {
        buttonName: "My documents"
        onClicked: {
            Global.notification.showMessage(qsTr( "Functionality not implemented yet" ), 10000);
        }
    }
    MenuTile {
        buttonName: "My projects"
        onClicked: {
            Global.notification.showMessage(qsTr( "Functionality not implemented yet" ), 10000);
        }
    }
    MenuTile {
        buttonName: "My calendar"
        onClicked: {
            Global.notification.showMessage(qsTr( "Functionality not implemented yet" ), 10000);
        }
    }
    MenuTile {
        buttonName: "My equipment"
        onClicked: {
            Global.notification.showMessage(qsTr( "Functionality not implemented yet" ), 10000);
        }
    }
    MenuTile {
        buttonName: "My team"
        onClicked: {
            Global.notification.showMessage(qsTr( "Functionality not implemented yet" ), 10000);
        }
    }
}
