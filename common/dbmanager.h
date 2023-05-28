#pragma once

#include <QJsonObject>
#include <QObject>
#include <QQmlEngine>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>

#include "config.h"
#include "utils.h"

OFFICEIS_NS_BEGIN

#define LOG_FAILED_QUERY(query) \
    qDebug() << __FILE__ << __LINE__ << "FAILED QUERY [" << (query).executedQuery() << "]" \
             << (query).lastError()

class DBManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
public:
    DBManager(QQmlEngine *qmlEngine, QJSEngine *jsEngine);
    ~DBManager();

    static DBManager *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);

    Q_INVOKABLE void connectDB(const QString &host,
                               const uint &port,
                               const QString &dbName,
                               const QString &user,
                               const QString &password);

    Q_INVOKABLE uint8_t registerNewUser(const QString &username, const QString &password);
    Q_INVOKABLE QJsonObject checkUserIsRemembered(const QString &username);
    Q_INVOKABLE void setRememberMe(const QString &username, const bool &isRemembered);
    Q_INVOKABLE bool userIsOnline(const QString &username);
    Q_INVOKABLE void setIsOnline(const QString &username, const bool &isOnline);
    Q_INVOKABLE uint8_t checkAccount(const QString &username, const QString &password);
    Q_INVOKABLE bool findUser(const QString &username);
    Q_INVOKABLE QStringList searchUsers(const QString &searchPattern);
    Q_INVOKABLE void resetPass(const QString &username, const QString &pass1, const QString &pass2);
    Q_INVOKABLE QStringList getUserProjects(const QString &username);
    Q_INVOKABLE QStringList getAllProjects();
    Q_INVOKABLE QString getProjectDescription(const QString &project);
    Q_INVOKABLE QString getUserRole(const QString &username);
    Q_INVOKABLE uint8_t createProject(const QString &name,
                                      const QString &description,
                                      const QStringList &userList);
    Q_INVOKABLE QString getTaskStatus(const QString &project, const QString &taskName);
    Q_INVOKABLE QDate getTaskDueDate(const QString &project, const QString &taskName);
    Q_INVOKABLE QStringList getAllTasks(const QString &project);
    Q_INVOKABLE QStringList getUserTasks(const QString &project, const QString &username);
    Q_INVOKABLE uint8_t changeProjectNameDesc(const QString &currentName,
                                              const QString &newName,
                                              const QString &newDesc);
    Q_INVOKABLE void removeProjects(const QStringList &projects);
    Q_INVOKABLE void updateTask(const QString &currentName,
                                const QString &project,
                                const QString &newName,
                                const QDate &newDate,
                                const QString &newStatus);
    Q_INVOKABLE uint8_t createTask(const QString &project,
                                   const QString &name,
                                   const QDate &due_date,
                                   const QString &user);
    Q_INVOKABLE uint8_t addEquipment(const QString &name, const QString &inventoryNumber);
    Q_INVOKABLE void deleteEquipmentRow(const QString &inventoryNumber);
    Q_INVOKABLE QStringList getTeamsByCurrentUser(const QString &user);
    Q_INVOKABLE QStringList getAllTeams();
    Q_INVOKABLE QStringList getUsersByTeam(const QString &team);
    Q_INVOKABLE bool createTeam(const QString &team, const QStringList &users);
    Q_INVOKABLE bool removeTeam(const QString &team);

private:
    void initDB();

    QQmlEngine *m_qmlEngine;
    QJSEngine *m_jsEngine;

    QSqlDatabase m_db;
    Utils m_utils;
};

OFFICEIS_NS_END
