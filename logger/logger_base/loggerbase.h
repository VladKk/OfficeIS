#pragma once

#include <QObject>
#include <QFile>

#include "config.h"

OFFICEIS_NS_BEGIN

class LoggerBase : public QObject
{
    Q_OBJECT

public:

    static LoggerBase *instance(QObject *parent = nullptr);
    static void handleMsg(QtMsgType type, const QMessageLogContext &context, const QString &msg);

    QString logFilePath() const;

    void openLogFile();
    void closeLogFile();

private:
    LoggerBase(QObject *parent = nullptr);
    ~LoggerBase();
    void __handleMsg(QtMsgType type, const QMessageLogContext &context, const QString &msg);

    QFile m_logFile;
    static LoggerBase *s_instance;
};

OFFICEIS_NS_END
