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

public slots:
    void updateName(int row, const QString &newName);
    void updateUsername(int row, const QString &newUsername);
    void updateInventoryNumber(int row, const QString &newInventoryNumber);
    void updateStatus(int row, const QString &newStatus);

public:
    enum Roles { NameRole = Qt::UserRole, UsernameRole, InventoryNumberRole, StatusRole };
    Q_ENUM(Roles)

    EquipmentTableModel(QObject *parent = nullptr);

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void refresh();
    Q_INVOKABLE QVariantMap get(int row);
    Q_INVOKABLE int rowCount() const;
    Q_INVOKABLE bool updateRow(int row,
                               const QString &name,
                               const QString &username,
                               const QString &inventory_number,
                               const QString &status);
};
OFFICEIS_NS_END
