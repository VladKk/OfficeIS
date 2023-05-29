#pragma once

#include <QStandardPaths>
#include <QDir>
#include <QQmlEngine>
#include <QJSEngine>
#include <QDesktopServices>
#include <QLoggingCategory>

#include "loggerbase.h"
#include "config.h"

OFFICEIS_NS_BEGIN

class Logger : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QString logFilePath READ logFilePath CONSTANT)

public:
    Logger(QQmlEngine *qmlEngine, QJSEngine *jsEngine);
    static Logger *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);

    QString logFilePath() const;

    Q_INVOKABLE void openLogInBrowser();
    Q_INVOKABLE void setVerboseMode(bool isSet);
    Q_INVOKABLE void setFormattedMode(bool isSet);

private:
    LoggerBase *m_loggerBase;
    QQmlEngine *m_qmlEngine;
    QJSEngine *m_jsEngine;
};

OFFICEIS_NS_END
