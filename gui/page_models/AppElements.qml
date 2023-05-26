import QtQuick
import QtQuick.Controls

import gui
import filteringmodel
import common

FilteringModel {
    id: root

    MenuTile {
        buttonName: "My documents"
        onClicked: {
            Global.mainStackView.replacePage("qrc:/gui/pages/MyDocs.qml");
        }
    }
    MenuTile {
        buttonName: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER" ? "All projects" : "My projects"
        onClicked: {
            Global.mainStackView.replacePage("qrc:/gui/pages/MyProjects.qml");
        }
    }
    MenuTile {
        buttonName: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER" ? "All equipment" : "My equipment"
        onClicked: {
            Global.mainStackView.replacePage("qrc:/gui/pages/MyEquipment.qml");
        }
    }
    MenuTile {
        buttonName: DBManager.getUserRole(Global.settings.lastLoggedLocalUser.username) === "MANAGER" ? "All teams" : "My team"
        onClicked: {
            Global.mainStackView.replacePage("qrc:/gui/pages/MyTeam.qml");
        }
    }
}
