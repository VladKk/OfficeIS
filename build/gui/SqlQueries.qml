import QtQuick
import QtQuick.LocalStorage as SysLocalStorage

import common as Common

Item {
    id: root

    property var __appDB: null

    Component.onCompleted: {
        __appDB = __appDataBase()
    }

    //Create and initialize the application data/settings DB
    function __appDataBase() {
        var db = SysLocalStorage.LocalStorage.openDatabaseSync("AppConfig", "1.0", "AppConfig", 10000000);
        db.transaction(function(tx) {
            //create tables
            tx.executeSql('CREATE TABLE IF NOT EXISTS `ConfigAppPreferences` ( `Preference` TEXT, `Value` TEXT, PRIMARY KEY(`Preference`) )');

            //fill in tables
            tx.executeSql(Common.Utils.readFileAsString(":/gui/sql/ConfigAppPreferences.sql"));
        })
        return db
    }

    //============================================================================================
    //App settings
    // Get user colorsScheme
    function getSchemePreference(callback) {
        root.__appDB.transaction(function(tx) {
            var results = tx.executeSql('SELECT Value FROM ConfigAppPreferences WHERE Preference=\"ColorScheme\"');
            if (results.rows.lenght !== 0) {
                callback(results.rows[0].Value);
            }
        });
    }

    // Update user colorsScheme
    function updateSchemePreference(colorsScheme) {
        root.__appDB.transaction(function(tx) {
            tx.executeSql('UPDATE ConfigAppPreferences SET Value=? WHERE Preference=\"ColorScheme\";', colorsScheme);
        });
    }
}
