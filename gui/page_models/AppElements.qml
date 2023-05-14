import QtQuick
import QtQuick.Controls

import gui
import filteringmodel

FilteringModel {
    id: root

    MenuTile {
        buttonName: "My documents"
        onClicked: {
            Global.mainStackView.replacePage("qrc:/gui/pages/MyDocs.qml");
        }
    }
    MenuTile {
        buttonName: "My projects"
        onClicked: {
            Global.mainStackView.replacePage("qrc:/gui/pages/MyProjects.qml");
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
