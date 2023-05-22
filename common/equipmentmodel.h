#pragma once

#include <QDebug>
#include <QQmlEngine>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlQueryModel>

#include "config.h"
#include "dbmanager.h"

OFFICEIS_NS_BEGIN

class EquipmentTableModel : public QSqlQueryModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    enum Roles { NameRole = Qt::UserRole, UsernameRole, InventoryNumberRole, StatusRole };
    Q_ENUM(Roles)

    EquipmentTableModel(QObject *parent = nullptr);

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    QHash<int, QByteArray> roleNames() const override;

    void refresh();
};
OFFICEIS_NS_END
