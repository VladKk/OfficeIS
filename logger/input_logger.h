#include <QApplication>
#include <QKeyEvent>
#include <QQmlEngine>
#include <QJSEngine>

#include "config.h"

OFFICEIS_NS_BEGIN

class InputLogger : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool enableLogging READ loggingEnabled WRITE enableLogging)

public:

    InputLogger(QQmlEngine *qmlEngine, QJSEngine *jsEngine);

    static InputLogger *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);

    bool loggingEnabled() const;
    void enableLogging(bool enabled);

protected:

    bool eventFilter(QObject *obj, QEvent *event) override;

private:

    bool m_enableLogging;

    QQmlEngine *m_qmlEngine;
    QJSEngine *m_jsEngine;
};

OFFICEIS_NS_END
