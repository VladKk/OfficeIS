import QtQuick
import QtQuick.Controls

import filteringmodel
import gui

Item {
    id: root

    readonly property alias currentPageName: internal.currentPageName
    property var pagePopup: _popup

    //ignore mistake touches
    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: false
    }

    function setupLeftPaneModel(leftPaneModelUrl) {
        root.visible = true;

        leftPane.model = internal.createPaneModel(leftPaneModelUrl);
        leftPane.model.get(0).clicked(); //open first task on appllication page
    }

    function loadPage(pageUrl, args) {
        if (args) {
            internal.args = args.args;
        }
        internal.source = pageUrl;
    }

    //Page background
    Rectangle {
        anchors.fill: parent
        width: parent.width
        height: parent.height
        color: Style.bgColor
    }

    //LeftPane background
    Rectangle {
        id: leftPaneBackground
        anchors.fill: leftPane
        color: Style.bgColor
    }

    //Components PopUp
    Item {
        id: popupHolder
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: leftPane.right
            right: parent.right
        }

        Popup {
            id: _popup
            anchors.centerIn: parent
            dim: false

            enter: Transition {
                NumberAnimation { property: "opacity"; from: 0.7; to: 1.0 }
            }

            property var contentLoader: _contentLoader
            Loader {
                id: _contentLoader
                onLoaded: {
                }
            }
        }
    }

    // Define a highlight with customized movement between items.
    Component {
        id: highlight

        //Highlight - leftside line
        Rectangle{
            y: leftPane.model.currentItem ? (leftPane.model.currentItem.y + 10) : 0
            z: leftPane.z + 1
            x: -4
            color: Style.mainTextColor
            opacity: 0.8
            width: 4
            height: leftPane.model.currentItem ? (leftPane.model.currentItem.height - (leftPane.model.currentItem.height / 5)) : 0

            //Highlight moving animation
            Behavior on y { SpringAnimation { spring: 1; damping: 0.17 } }
        }
    }

    //Left panel
    ListView {
        id: leftPane

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }

        spacing: 3

        width: 125
        z: leftPaneBackground.z + 1

        focus: true
        highlight: highlight
        highlightFollowsCurrentItem: false

        //Shown only if pane elements not fits window height
        ScrollIndicator.vertical: BaseScrollIndicator {}

        boundsBehavior: Flickable.StopAtBounds
    }

    Connections {
        target: leftPane.model ? leftPane.model : null
        ignoreUnknownSignals: true
        function onTaskTypeSelected(taskPageUrl) {
            root.loadPage(taskPageUrl);
        }
        function onShowPageRq(taskPageUrl, args) {
            root.loadPage(taskPageUrl, args);
        }
    }

    QtObject {
        id: internal

        property var cachedPages: []
        property string source: ""
        property var args: ({})
        property string oldSource: ""
        property string currentPageName: (oldSource && cachedPages[oldSource]) ? leftPane.model.pageName : ""

        function createPaneModel(modelUrl) {
            var component = Qt.createComponent(modelUrl);
            var model = component.createObject(root, {});
            component.destroy();

            return model;
        }

        //Page cacher
        onSourceChanged: {
            if(oldSource !== "") {
                var oldPage = cachedPages[oldSource];
                oldPage.visible = false;
                oldPage.enabled = false;
                if (typeof oldPage.isCached !== 'undefined' && !oldPage.isCached) {
                    oldPage.destroy();
                    delete cachedPages[oldSource];
                }
            }

            if(source in cachedPages) {
                console.log(source + " page reused from cache");
                var cachedPage = cachedPages[source];
                if (typeof cachedPage.args !== "undefined") {
                    cachedPage.args = internal.args;
                }
                cachedPage.enabled = true;
                cachedPage.visible = true;
            } else {
                console.log(source + " page never exists before, creating it");
                var component = Qt.createComponent(source);
                if( component.status !== Component.Ready ) {
                    if( component.status === Component.Error )
                        console.debug("Error: " + component.errorString() );
                    return;
                }
                var newPage = component.createObject(root, Boolean(internal.args) ? {args: internal.args} : {});
                component.destroy();
                cachedPages[source] = newPage;
            }
            oldSource = source;
        }
    }
}
