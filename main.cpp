#include <QApplication>
#include <QDirIterator>
#include <QIcon>
#include <QLoggingCategory>
#include <QProcessEnvironment>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSqlDatabase>

#include "config.h"

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

    // NOTE: to prevent the "qml:" category printing at every line from QML
    qSetMessagePattern("%{message}");
    // NOTE: to prevent the SSL & Kernel warnings
    QLoggingCategory::setFilterRules("qt.network.ssl.warning=false\n"
                                     "qt.widgets.kernel.warning=false");

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
    engine.rootContext()->setContextProperty("LOCAL_CRED", localCred);

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
