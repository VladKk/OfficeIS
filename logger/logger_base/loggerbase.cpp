#include <QDebug>
#include <QStandardPaths>
#include <QDir>

#include "loggerbase.h"

using namespace OFFICEIS_NS;

LoggerBase *LoggerBase::s_instance = nullptr;

LoggerBase::LoggerBase(QObject *parent)
    : QObject(parent) {
    m_logFile.setFileName(QStandardPaths::standardLocations(QStandardPaths::AppDataLocation)[0]
                          + QDir::separator() + "officeis " + QDate::currentDate().toString()
                          + ".log");

    openLogFile();
}

LoggerBase::~LoggerBase() {
    closeLogFile();
}

LoggerBase *LoggerBase::instance(QObject *parent) {
    if (!s_instance)
        s_instance = new LoggerBase(parent);

    return s_instance;
}

void LoggerBase::handleMsg(QtMsgType type, const QMessageLogContext &context, const QString &msg) {
    if (s_instance)
        s_instance->__handleMsg(type, context, msg);
}

void LoggerBase::__handleMsg(QtMsgType type, const QMessageLogContext &context, const QString &msg) {
    QByteArray localMsg = msg.toLocal8Bit();
    QString file = context.file ? context.file : "unknown";
    QFileInfo fileInfo(file);
    file = file.contains("qrc:") || file == "unknown" ? file : fileInfo.absoluteFilePath().prepend("file:");

    QString logLine = QString("\t[%1] [%3:%4] %2\r\n").arg(QDateTime::currentDateTime().toString("yyyy-MM-dd h:mm:ss.zzz")).arg(localMsg.constData()).arg(file).arg(context.line);

    switch(type) {
    case QtDebugMsg: logLine.prepend("[Debug]"); break;
    case QtInfoMsg: logLine.prepend("[Info]"); break;
    case QtWarningMsg: logLine.prepend("[Warn]"); break;
    case QtCriticalMsg: logLine.prepend("[Crit]"); break;
    case QtFatalMsg: logLine.prepend("[Fatal]"); break;
    default: logLine.prepend("[Unknown]");
    }

    fprintf(stderr, "%s", logLine.toStdString().c_str());

    m_logFile.write(logLine.toUtf8());
    m_logFile.flush();
}

QString LoggerBase::logFilePath() const {
    return m_logFile.fileName();
}

void LoggerBase::openLogFile() {
    if (!m_logFile.open(QIODevice::ReadWrite | QIODevice::Append)) {
        qCritical() << "Could not open log file!";
    }
}

void LoggerBase::closeLogFile() {
    if (m_logFile.isOpen()) {
        m_logFile.close();
    }
}
