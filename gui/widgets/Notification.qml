import QtQuick
import QtQuick.Controls

import gui

Popup {
    id: popup

    enum Priority {
        Common = 1,
        Success = 2,
        Warning = 3,
        Error = 4,
        Highest = 5 // Use it to show the most urgent messages
    }

    property alias priority: popup.z
    property alias popMessage: message.text
    property alias timeout: popupClose.interval
    property alias notificationHeight: popup.background.implicitHeight

    background: Rectangle {
        readonly property int initImplicitHeight: 60

        implicitWidth: rootWindow.width - rootWindow.bw * 2
        implicitHeight: initImplicitHeight
        radius: 2
    }

    focus: true
    opacity: 0.75
    closePolicy: Popup.CloseOnPressOutside

    Text {
        id: message
        anchors.centerIn: parent
        font.pointSize: 12
        color: Style.getContrastingColor(popup.background.color)

        onContentHeightChanged:  {
            if (this.contentHeight >= popup.background.initImplicitHeight) {
                popup.background.implicitHeight = popup.background.initImplicitHeight * 2;
            }
            else {
                popup.background.implicitHeight = popup.background.initImplicitHeight;
            }
        }
    }

    onOpened: popupClose.start()
    onClosed: {
        popup.priority = Notification.Priority.Common;
    }

    Timer {
        id: popupClose
        interval: 3000
        onTriggered: popup.close()
        function start() {
            if (interval > 0) {
                popupClose.restart();
            }
        }
    }

    function showErrorMessage(msg, timer, callback, priority = Notification.Priority.Error) {
        _popupSetup(msg, timer, callback, priority);
        popup.background.color = Style.appErrColor;
        popup.open();
    }

    function showWarningMessage(msg, timer, callback, priority = Notification.Priority.Warning) {
        _popupSetup(msg, timer, callback, priority);
        popup.background.color = Style.appWarnColor;
        popup.open();
    }

    function showSuccessMessage(msg, timer, callback, priority = Notification.Priority.Success) {
        _popupSetup(msg, timer, callback, priority);
        popup.background.color = Style.appSuccessColor;
        popup.open();
    }

    function showMessage(msg, timer, callback, priority = Notification.Priority.Common) {
        _popupSetup(msg, timer, callback, priority);
        popup.background.color = Style.appNeutralColor;
        popup.open();
    }

    function _popupSetup(msg, timer, callback, priority) {
        if (popup.priority <= priority) {
            popup.priority = priority;
            popup.popMessage = msg;
        }
        _connectOnce(callback, popup.closed);
    }

    function _connectOnce(callback, triggerSignal) {
        let func = () => {
            if (callback && callback instanceof Function) {
                callback(this, arguments);
            }
            if (popup) {
                triggerSignal.disconnect(func);
            }
        }
        triggerSignal.connect(func);
    }
}
