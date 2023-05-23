#include <QSqlRecord>

#include "equipmentmodel.h"

using namespace OFFICEIS_NS;

EquipmentTableModel::EquipmentTableModel(QObject *parent)
    : QSqlQueryModel(parent)
{
    refresh();
}

QVariant EquipmentTableModel::data(const QModelIndex &index, int role) const
{
    if (role < Qt::UserRole)
        return QSqlQueryModel::data(index, role);

    const QSqlRecord sqlRecord = record(index.row());
    return sqlRecord.value(role - Qt::UserRole);
}

QHash<int, QByteArray> EquipmentTableModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[UsernameRole] = "username";
    roles[InventoryNumberRole] = "inventory_number";
    roles[StatusRole] = "status";
    return roles;
}

void EquipmentTableModel::refresh()
{
    QSqlDatabase::database().transaction();
    QSqlQuery query;
    query.prepare("SELECT equipment.name, COALESCE(users.username, 'None') AS username, "
                  "equipment.inventory_number, equipment.status FROM equipment LEFT JOIN users ON "
                  "equipment.user_id = users.id;");

    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        QSqlDatabase::database().rollback();
        return;
    }

    setQuery(query);

    QSqlDatabase::database().commit();
}
