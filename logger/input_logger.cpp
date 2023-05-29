#include "input_logger.h"

using namespace OFFICEIS_NS;

InputLogger::InputLogger(QQmlEngine *qmlEngine, QJSEngine *jsEngine) {
    qApp->installEventFilter(this);
}

InputLogger *InputLogger::create(QQmlEngine *qmlEngine, QJSEngine *jsEngine) {
    return new InputLogger(qmlEngine, jsEngine);
}

bool InputLogger::loggingEnabled() const {
    return m_enableLogging;
}

void InputLogger::enableLogging(bool enabled) {
    m_enableLogging = enabled;
}

bool InputLogger::eventFilter(QObject *obj, QEvent *event) {
    if (m_enableLogging) {
        if (event->type() == QEvent::MouseButtonPress) {
            QMouseEvent *mouseEvent = static_cast<QMouseEvent*>(event);
            qDebug() << "Mouse press on object " << obj << " with button " << mouseEvent->button(); 
        } else if (event->type() == QEvent::KeyPress) {
            QKeyEvent *keyEvent = static_cast<QKeyEvent*>(event);
            qDebug() << "Key press on object " << obj << " with key " << keyEvent->text();
        }
    }

    return QObject::eventFilter(obj, event);
}
