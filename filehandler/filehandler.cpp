#include <QDir>
#include <QFileInfo>
#include <QStandardPaths>

#include "filehandler.h"

using namespace OFFICEIS_NS;

FileHandler::FileHandler(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
    : m_qmlEngine(qmlEngine)
    , m_jsEngine(jsEngine)
{
    QString dirPath = QStandardPaths::standardLocations(QStandardPaths::AppDataLocation)[0]
                      + QDir::separator() + "docs";

    if (!QDir().exists(dirPath))
        QDir().mkdir(dirPath);
}

FileHandler *FileHandler::create(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    return new FileHandler(qmlEngine, jsEngine);
}

FileHandler::FileType FileHandler::detectFileType(const QString &filePath)
{
    QFileInfo fileInfo(filePath);
    QString fileExtension = fileInfo.suffix().toLower();

    if (fileExtension == "doc" || fileExtension == "docx" || fileExtension == "odt"
        || fileExtension == "pdf") {
        return FileType::DOCUMENT;
    } else if (fileExtension == "xls" || fileExtension == "xlsx" || fileExtension == "ods") {
        return FileType::SPREADSHEET;
    } else if (fileExtension == "ppt" || fileExtension == "pptx" || fileExtension == "odp") {
        return FileType::PRESENTATION;
    } else {
        return FileType::UNKNOWN;
    }
}

QStringList FileHandler::getFileList()
{
    QDir srcDir(QStandardPaths::standardLocations(QStandardPaths::AppDataLocation)[0]
                + QDir::separator() + "docs");

    return srcDir.entryList(QStringList() << "*", QDir::Files);
}
