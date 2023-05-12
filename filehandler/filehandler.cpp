#include <QDir>
#include <QFileInfo>
#include <QStandardPaths>

#include "filehandler.h"
#include "xlsxdocument.h"

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
        || fileExtension == "pdf" || fileExtension == "txt") {
        return FileType::DOCUMENT;
    } else if (fileExtension == "xls" || fileExtension == "xlsx" || fileExtension == "ods") {
        return FileType::SPREADSHEET;
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

QString FileHandler::getFilePath(const QString &fileName)
{
    return QStandardPaths::standardLocations(QStandardPaths::AppDataLocation)[0] + QDir::separator()
           + "docs" + QDir::separator() + fileName;
}

QString FileHandler::openFile(const QString &fileName)
{
    switch (detectFileType(getFilePath(fileName))) {
    case DOCUMENT: {
        QFile file(getFilePath(fileName));
        file.open(QIODevice::ReadOnly);
        QString res = QString(file.readAll());
        file.close();
        return res;
    }
    case SPREADSHEET: {
        QXlsx::Document xlsx(getFilePath(fileName));
        QString res;

        for (int row = 1; row <= xlsx.dimension().lastRow(); ++row) {
            for (int column = 1; column <= xlsx.dimension().lastColumn(); ++column) {
                QXlsx::Cell *cell = xlsx.cellAt(row, column);

                if (cell) {
                    res.append(cell->value().toString() + "\t");
                }
            }

            res.append("\n");
        }

        return res;
    }
    default:
        return "";
    }
}

QStringList FileHandler::getFileNames(const QList<QUrl> &filePaths)
{
    QStringList fileNames;
    QFileInfo fileInfo;

    for (const QUrl &filePath : filePaths) {
        fileInfo.setFile(filePath.toString());
        fileNames << fileInfo.fileName();
    }

    return fileNames;
}
