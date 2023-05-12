#pragma once

#include <QObject>
#include <QQmlEngine>

#include "config.h"

OFFICEIS_NS_BEGIN

class FileHandler : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    enum FileType { UNKNOWN, DOCUMENT, SPREADSHEET };
    Q_ENUM(FileType)

    FileHandler(QQmlEngine *qmlEngine, QJSEngine *jsEngine);

    static FileHandler *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);

    FileType detectFileType(const QString &filePath);
    Q_INVOKABLE QStringList getFileList();
    Q_INVOKABLE QString getFilePath(const QString &fileName);
    Q_INVOKABLE QString openFile(const QString &fileName);
    Q_INVOKABLE QStringList getFileNames(const QList<QUrl> &filePaths);

private:
    QQmlEngine *m_qmlEngine;
    QJSEngine *m_jsEngine;
};

OFFICEIS_NS_END
