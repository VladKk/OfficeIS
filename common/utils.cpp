#include <QFile>

#include "utils.h"

using namespace OFFICEIS_NS;

Utils::Utils(QObject *parent)
    : QObject(parent)
{}

QString Utils::readFileAsString(QString src)
{
    QFile file(src);
    file.open(QIODevice::ReadOnly);
    return QString(file.readAll());
}
