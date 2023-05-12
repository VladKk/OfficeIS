#pragma once

#include <QQmlEngine>

#include "config.h"

OFFICEIS_NS_BEGIN

class Utils : public QObject
{
    Q_OBJECT
public:
    Utils(QObject *parent = nullptr);

    QString readFileAsString(const QString &src);
};

OFFICEIS_NS_END
