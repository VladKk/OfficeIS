#include "logger.h"

using namespace OFFICEIS_NS;

Logger::Logger(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
    : m_qmlEngine(qmlEngine)
    , m_jsEngine(jsEngine)
    , m_loggerBase(LoggerBase::instance())
{}

QString Logger::logFilePath() const
{
    return m_loggerBase->logFilePath();
}

Logger *Logger::create(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    return new Logger(qmlEngine, jsEngine);
}

void Logger::openLogInBrowser()
{
    m_loggerBase->openLogFile();

    QDesktopServices::openUrl(QUrl("file:" + logFilePath()));

    m_loggerBase->closeLogFile();
}

void Logger::setVerboseMode(bool isSet)
{
    if(!isSet) {
        QLoggingCategory::setFilterRules(QStringLiteral("*.debug=false\n*.info=false\nqt.network.ssl.warning=false\nqt.widgets.kernel.warning=false"));
    } else {
        QLoggingCategory::setFilterRules(QStringLiteral("*=true\nqt*=false\nqt.network.ssl.warning=false\nqt.widgets.kernel.warning=false"));
    }
}

void Logger::setFormattedMode(bool isSet)
{
    qInstallMessageHandler(qEnvironmentVariableIsEmpty("FORCE_LOG_STDOUT") && isSet ? m_loggerBase->handleMsg : 0);
}
