pragma Singleton

import QtQuick
import Qt.labs.settings

Item {
    id: root

    property var mainStackView: null
    property var notification: null
    property var copyItem: null
    property var personalSettingsPopUp: null
    property alias appSettings: _appSettings
    property alias settings: _settings
    property alias appData: _appData

    Settings {
        id: _settings

        category: "User data"

        property var lastLoggedLocalUser
    }

    Settings {
        id: _appSettings

        category: "General"

        property string lastUsedColourScheme
        property string progressAnimation

        property bool verboseModeActive: ENABLE_VERBOSE_MODE
        property bool inputLoggingEnabled: ENABLE_INPUT_LOGGING
    }

    QtObject {
        id: _appData
        property int windowWidth: 1024
        property int windowHeight: 850
    }
}
