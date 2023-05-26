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

    setQuery(std::move(query));

    QSqlDatabase::database().commit();
}

QVariantMap EquipmentTableModel::get(int row)
{
    QVariantMap map;

    foreach (int i, roleNames().keys()) {
        map[roleNames().value(i)] = data(index(row, 0), i);
    }

    return map;
}

int EquipmentTableModel::rowCount() const
{
    return QSqlQueryModel::rowCount();
}

bool EquipmentTableModel::updateRow(int row,
                                    const QString &name,
                                    const QString &username,
                                    const QString &inventory_number,
                                    const QString &status)
{
    const auto record = get(row);
    const auto currentInvNum = record["inventory_number"].toString();
    if (currentInvNum != inventory_number) {
        qWarning() << "Inventory numbers do not match. Expected " << currentInvNum << " but got "
                   << inventory_number;
        return false;
    }

    QSqlDatabase::database().transaction();
    QSqlQuery query;

    query.prepare("SELECT name FROM equipment WHERE inventory_number=?;");
    query.addBindValue(inventory_number);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        QSqlDatabase::database().rollback();
        return false;
    }

    if (query.next()) {
        QSqlDatabase::database().commit();
        return false;
    }

    if (status != "IN_USE") {
        query.prepare("UPDATE equipment SET name=?, user_id=NULL, status=?, inventory_number=?;");
        query.addBindValue(name);
        query.addBindValue(status);
        query.addBindValue(inventory_number);
    } else {
        if (username == "None") {
            QSqlDatabase::database().commit();
            return false;
        }

        query.prepare("UPDATE equipment SET name=?, user_id=(SELECT id FROM users WHERE "
                      "username=?), status=?, inventory_number=?;");
        query.addBindValue(name);
        query.addBindValue(username);
        query.addBindValue(status);
        query.addBindValue(inventory_number);
    }

    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        QSqlDatabase::database().rollback();
        return false;
    }

    QSqlDatabase::database().commit();
    refresh();
    return true;
}

void EquipmentTableModel::updateName(int row, const QString &newName)
{
    const QString inventoryNumber = record(row).value("inventory_number").toString();
    QSqlDatabase::database().transaction();
    QSqlQuery query;
    query.prepare("UPDATE equipment SET name=? WHERE inventory_number=?;");
    query.addBindValue(newName);
    query.addBindValue(inventoryNumber);

    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        QSqlDatabase::database().rollback();
        return;
    }

    QSqlDatabase::database().commit();
    refresh();
}

void EquipmentTableModel::updateUsername(int row, const QString &newUsername)
{
    const QString inventoryNumber = record(row).value("inventory_number").toString();

    QSqlDatabase::database().transaction();
    QSqlQuery query;

    if (newUsername == "None") {
        query.prepare("UPDATE equipment SET user_id=NULL, status = 'AVAILABLE' WHERE "
                      "inventory_number=?;");
        query.addBindValue(inventoryNumber);
    } else {
        query.prepare("UPDATE equipment SET user_id=(SELECT id FROM users WHERE username="
                      "?), status = 'IN_USE' WHERE inventory_number=?;");
        query.addBindValue(newUsername);
        query.addBindValue(inventoryNumber);
    }

    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        QSqlDatabase::database().rollback();
        return;
    }

    QSqlDatabase::database().commit();
    refresh();
}

void EquipmentTableModel::updateInventoryNumber(int row, const QString &newInventoryNumber)
{
    const QString inventoryNumber = record(row).value("inventory_number").toString();
    QSqlDatabase::database().transaction();
    QSqlQuery query;
    query.prepare("UPDATE equipment SET inventory_number=? WHERE "
                  "inventory_number=?;");
    query.addBindValue(newInventoryNumber);
    query.addBindValue(inventoryNumber);

    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        QSqlDatabase::database().rollback();
        return;
    }

    QSqlDatabase::database().commit();
    refresh();
}

void EquipmentTableModel::updateStatus(int row, const QString &newStatus)
{
    const QString inventoryNumber = record(row).value("inventory_number").toString();
    QSqlDatabase::database().transaction();
    QSqlQuery query;
    query.prepare("UPDATE equipment SET status=? WHERE inventory_number=?;");
    query.addBindValue(newStatus);
    query.addBindValue(inventoryNumber);

    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        QSqlDatabase::database().rollback();
        return;
    }

    if (newStatus != "IN_USE") {
        query.prepare("UPDATE equipment SET user_id=NULL WHERE inventory_number=?;");
        query.addBindValue(inventoryNumber);

        if (!query.exec()) {
            LOG_FAILED_QUERY(query);
            QSqlDatabase::database().rollback();
            return;
        }
    }

    QSqlDatabase::database().commit();
    refresh();
}
