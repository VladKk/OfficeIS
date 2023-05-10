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
    enum FileType { UNKNOWN, DOCUMENT, SPREADSHEET, PRESENTATION };
    Q_ENUM(FileType)

    FileHandler(QQmlEngine *qmlEngine, QJSEngine *jsEngine);

    static FileHandler *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);

    FileType detectFileType(const QString &filePath);
    Q_INVOKABLE QStringList getFileList();

private:
    QQmlEngine *m_qmlEngine;
    QJSEngine *m_jsEngine;
};

OFFICEIS_NS_END
