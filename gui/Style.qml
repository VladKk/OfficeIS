pragma Singleton

import QtQuick
import QtQml

Item{
    QtObject {
        id: themes
        readonly property var darkTheme: ["#46494C", "#C5C3C6", "#6F7072", "#F9FAFF"]

        readonly property var lightTheme: ["#F9FAFF", "#84848C", "#ECECF4", "#2A2A2E"]

        readonly property var testTheme: ["#17171F", "#BFC0C5", "#BFC0C5", "#921233"]
    }

    property var currenTheme: themes.darkTheme
    property alias themes: themes

    readonly property string bgColor: currenTheme[0]
    readonly property string mainAppColor: currenTheme[1]
    readonly property string bgTileColor: currenTheme[2]
    readonly property string mainTextColor: currenTheme[3]

    readonly property color appTransparent: "transparent"
    readonly property color appErrColor: "#e0251f"          //red
    readonly property color appWarnColor: "#fee11b"         //yellow
    readonly property color appSuccessColor: "#b3ffb3"      //green
    readonly property color appNeutralColor: "#dddddd"      //gray
    readonly property color appAmbientLightColor: "lightblue"
    readonly property color appSteelBlueColor: "steelblue"
    readonly property color appLightGrey: "lightgrey"

    readonly property color appControlGreen: "#00ca4e"
    readonly property color appControlYellow: "#ffbd44"
    readonly property color appControlRed: "#ff605c"

    readonly property string fontName: "fontawesome"

    property var fontAwesome: FontLoader {
        source: "qrc:/gui/fonts/fontawesome-webfont.ttf"
    }

    function getContrastingColor(backgroundColor) {
        var luma = 0.2126 * backgroundColor.r + 0.7152 * backgroundColor.g + 0.0722 * backgroundColor.b;
        return luma > 0.5 ? "black" : "white";
    }
}
