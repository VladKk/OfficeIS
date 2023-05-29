#include <QApplication>
#include <QDirIterator>
#include <QIcon>
#include <QLoggingCategory>
#include <QProcessEnvironment>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSqlDatabase>

#include "config.h"
#include "loggerbase.h"

int main(int argc, char **argv)
{
    QApplication::addLibraryPath(".");
    QApplication::addLibraryPath("plugins");
    QApplication::addLibraryPath("./install/plugins");
    QApplication app(argc, argv);
    Q_ASSERT(QSqlDatabase::isDriverAvailable("QPSQL"));
    app.setWindowIcon(QIcon(":/gui/images/appIcon.png"));
    app.setOrganizationName("Vladyslav Koliadenko");
    app.setOrganizationDomain("vkoliadenko");
    app.setApplicationName("OfficeIS");
    auto appArgs = app.arguments();

    // NOTE: set logger
    qInstallMessageHandler(qEnvironmentVariableIsEmpty("FORCE_LOG_STDOUT")
                               ? OfficeIS::LoggerBase::instance()->handleMsg
                               : 0);

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlEngine::exit, &app, &QCoreApplication::exit, Qt::QueuedConnection);
    QObject::connect(&engine, &QQmlEngine::quit, &app, &QCoreApplication::quit, Qt::QueuedConnection);

    engine.addImportPath(QStringLiteral(QML_IMPORT_PATH));
    engine.addImportPath(QStringLiteral("./"));
    engine.addImportPath("qrc:/");
    engine.addImportPath("./plugin");

#ifdef DEBUG
    engine.rootContext()->setContextProperty("DEBUG", true);
#else
    engine.rootContext()->setContextProperty("DEBUG", false);
#endif //DEBUG

    // Get user cred for env
    const QString localCred = QProcessEnvironment::systemEnvironment().value("LOCAL_CRED", "");
    const bool verboseModeEnabled = QProcessEnvironment::systemEnvironment()
                                        .value("JIRATOOL_ENABLE_VERBOSE_MODE", "1")
                                    == "1";
    const bool inputLoggingEnabled = QProcessEnvironment::systemEnvironment()
                                         .value("JIRATOOL_ENABLE_INPUT_LOGGING", "0")
                                     == "1";

    engine.rootContext()->setContextProperty("LOCAL_CRED", localCred);
    engine.rootContext()->setContextProperty("ENABLE_VERBOSE_MODE", verboseModeEnabled);
    engine.rootContext()->setContextProperty("ENABLE_INPUT_LOGGING", inputLoggingEnabled);

    const QUrl url(QStringLiteral("qrc:/gui/main.qml"));
    engine.load(url);

    if (std::find(appArgs.begin(), appArgs.end(), QStringLiteral("--debug_resources"))
        != appArgs.end()) {
        QDirIterator it(":", QDirIterator::Subdirectories);
        while (it.hasNext()) {
            qDebug() << it.next();
        }
    }
    return app.exec();
}
