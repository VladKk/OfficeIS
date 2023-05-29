#include <QSqlDriver>

#include "dbmanager.h"

using namespace OFFICEIS_NS;

DBManager::DBManager(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
    : m_qmlEngine(qmlEngine)
    , m_jsEngine(jsEngine)
    , m_db(QSqlDatabase::addDatabase("QPSQL"))
{
    Q_ASSERT(m_db.driver()->hasFeature(QSqlDriver::Transactions));
}

DBManager::~DBManager()
{
    m_db.close();
}

DBManager *DBManager::create(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    return new DBManager(qmlEngine, jsEngine);
}

void DBManager::connectDB(const QString &host,
                          const uint &port,
                          const QString &dbName,
                          const QString &userName,
                          const QString &password)
{
    m_db.setHostName(host);
    m_db.setPort(port);
    m_db.setDatabaseName(dbName);
    m_db.setUserName(userName);
    m_db.setPassword(password);

    if (!m_db.open())
        qFatal(QString("Failed to connect to DB: %1")
                   .arg(m_db.lastError().text())
                   .toStdString()
                   .c_str());
    else
        qInfo() << "Successfully connected to DB";

    initDB();
}

void DBManager::initDB()
{
    m_db.transaction();
    QSqlQuery query(m_db);
    if (!query.exec(m_utils.readFileAsString(":/common/sql/Users.sql"))) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return;
    }
    if (!query.exec(m_utils.readFileAsString(":/common/sql/Projects.sql"))) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return;
    }
    if (!query.exec(m_utils.readFileAsString(":/common/sql/Tasks.sql"))) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return;
    }
    if (!query.exec(m_utils.readFileAsString(":/common/sql/Equipment.sql"))) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return;
    }
    if (!query.exec(m_utils.readFileAsString(":/common/sql/UserData.sql"))) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return;
    }
    m_db.commit();
}

uint8_t DBManager::registerNewUser(const QString &username, const QString &password)
{
    m_db.transaction();
    QSqlQuery query(m_db);
    query.prepare("SELECT password FROM users WHERE username=?;");
    query.addBindValue(username);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return EXIT_FAILURE;
    }

    if (query.next()) {
        qWarning() << "User is already exists";
        m_db.commit();
        return 2;
    }

    query.prepare("INSERT INTO users (username, password) VALUES (?, ?);");
    query.addBindValue(username);
    query.addBindValue(password);

    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return EXIT_FAILURE;
    }

    m_db.commit();

    return EXIT_SUCCESS;
}

QJsonObject DBManager::checkUserIsRemembered(const QString &username)
{
    m_db.transaction();
    QJsonObject userData;
    userData["username"] = "";
    userData["isRemembered"] = false;

    QSqlQuery query(m_db);
    query.prepare("SELECT is_remembered FROM users WHERE username=?;");
    query.addBindValue(username);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return userData;
    }

    if (query.next()) {
        userData["isRemembered"] = query.value(0).toBool();

        if (userData["isRemembered"].toBool()) {
            query.prepare("SELECT password FROM users WHERE username=?;");
            query.addBindValue(username);
            if (!query.exec()) {
                LOG_FAILED_QUERY(query);
                m_db.rollback();
                return userData;
            }

            if (query.next())
                userData["password"] = query.value(0).toString();
        }
    }

    m_db.commit();

    return userData;
}

void DBManager::setRememberMe(const QString &username, const bool &isRemembered)
{
    m_db.transaction();
    QSqlQuery query(m_db);
    query.prepare("UPDATE users SET is_remembered=? WHERE username=?;");
    query.addBindValue(isRemembered);
    query.addBindValue(username);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return;
    }
    m_db.commit();
}

bool DBManager::userIsOnline(const QString &username)
{
    m_db.transaction();
    QSqlQuery query(m_db);
    query.prepare("SELECT is_online FROM users WHERE username=?;");
    query.addBindValue(username);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return false;
    }

    if (query.next()) {
        m_db.commit();
        return query.value(0).toBool();
    }

    m_db.commit();
    return false;
}

void DBManager::setIsOnline(const QString &username, const bool &isOnline)
{
    m_db.transaction();
    QSqlQuery query(m_db);
    query.prepare("UPDATE users SET is_online=? WHERE username=?;");
    query.addBindValue(isOnline);
    query.addBindValue(username);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return;
    }

    m_db.commit();
}

uint8_t DBManager::checkAccount(const QString &username, const QString &password)
{
    m_db.transaction();
    QSqlQuery query(m_db);
    query.prepare("SELECT password FROM users WHERE username=? LIMIT 1;");
    query.addBindValue(username);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return 3;
    }

    if (query.next()) {
        m_db.commit();
        return query.value(0).toString() != password ? 2 : EXIT_SUCCESS;
    } else {
        m_db.commit();
        return EXIT_FAILURE;
    }
}

bool DBManager::findUser(const QString &username)
{
    m_db.transaction();
    QSqlQuery query(m_db);
    query.prepare("SELECT password FROM users WHERE username=?;");
    query.addBindValue(username);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return false;
    }

    m_db.commit();
    return query.next();
}

QStringList DBManager::searchUsers(const QString &searchPattern)
{
    m_db.transaction();
    QStringList res;
    QSqlQuery query(m_db);
    query.prepare("SELECT username FROM users WHERE username ILIKE ?;");
    query.addBindValue(QString("%%1%").arg(searchPattern));
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return res;
    }

    while (query.next()) {
        res << query.value(0).toString();
    }
    m_db.commit();
    return res;
}

void DBManager::resetPass(const QString &username, const QString &pass1, const QString &pass2)
{
    if (pass1 != pass2)
        return;

    m_db.transaction();
    QSqlQuery query(m_db);
    query.prepare("UPDATE users SET password=? WHERE username=?;");
    query.addBindValue(pass1);
    query.addBindValue(username);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return;
    }

    m_db.commit();
}

QStringList DBManager::getUserProjects(const QString &username)
{
    m_db.transaction();
    QStringList res;
    QSqlQuery query(m_db);
    query.prepare(
        "SELECT projects.name FROM users JOIN user_projects ON users.id=user_projects.user_id JOIN "
        "projects ON projects.id=user_projects.project_id WHERE users.username=?;");
    query.addBindValue(username);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return res;
    }

    while (query.next()) {
        res << query.value(0).toString();
    }

    m_db.commit();
    return res;
}

QStringList DBManager::getAllProjects()
{
    m_db.transaction();
    QStringList res;
    QSqlQuery query(m_db);
    query.prepare("SELECT name FROM projects;");
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return res;
    }

    while (query.next()) {
        res << query.value(0).toString();
    }

    m_db.commit();
    return res;
}

QString DBManager::getProjectDescription(const QString &project)
{
    m_db.transaction();
    QSqlQuery query(m_db);
    query.prepare("SELECT description FROM projects WHERE name=?;");
    query.addBindValue(project);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return "";
    }

    if (query.next()) {
        m_db.commit();
        return query.value(0).toString();
    }

    m_db.commit();
    return "";
}

QString DBManager::getUserRole(const QString &username)
{
    m_db.transaction();
    QString res;
    QSqlQuery query(m_db);
    query.prepare("SELECT role FROM users WHERE username=?;");
    query.addBindValue(username);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return res;
    }

    if (query.next()) {
        res = query.value(0).toString();
    }

    m_db.commit();

    return res;
}

uint8_t DBManager::createProject(const QString &name,
                                 const QString &description,
                                 const QStringList &userList)
{
    if (getAllProjects().contains(name, Qt::CaseInsensitive)) {
        qWarning() << QString("Project %1 already exists!").arg(name);
        return 2;
    }

    m_db.transaction();
    QSqlQuery query(m_db);
    query.prepare("INSERT INTO projects (name, description) VALUES (?, ?) RETURNING id;");
    query.addBindValue(name);
    query.addBindValue(description);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return EXIT_FAILURE;
    } else {
        if (query.next()) {
            uint projectId = query.value(0).toUInt();

            QStringList quotedUsernames;
            for (const QString &username : userList) {
                quotedUsernames << ("'" + username + "'");
            }

            QString usersList = quotedUsernames.join(',');
            QString sql
                = QString(
                      "INSERT INTO user_projects (user_id, project_id) SELECT id, %1 FROM users "
                      "WHERE username IN (%2);")
                      .arg(projectId)
                      .arg(usersList);

            if (!query.exec(sql)) {
                LOG_FAILED_QUERY(query);
                m_db.rollback();
                return EXIT_FAILURE;
            }
        }
    }

    m_db.commit();
    return EXIT_SUCCESS;
}

QString DBManager::getTaskStatus(const QString &project, const QString &taskName)
{
    m_db.transaction();
    QSqlQuery query(m_db);
    query.prepare("SELECT tasks.status FROM tasks INNER "
                  "JOIN projects ON tasks.parent_project_id=projects.id WHERE "
                  "projects.name=? AND tasks.name=?;");
    query.addBindValue(project);
    query.addBindValue(taskName);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return "TO DO";
    }

    if (query.next()) {
        m_db.commit();
        return query.value(0).toString();
    }

    m_db.commit();
    return "TO DO";
}

QDate DBManager::getTaskDueDate(const QString &project, const QString &taskName)
{
    m_db.transaction();
    QSqlQuery query(m_db);
    query.prepare("SELECT tasks.due_date FROM tasks INNER "
                  "JOIN projects ON tasks.parent_project_id=projects.id WHERE "
                  "projects.name=? AND tasks.name=?;");
    query.addBindValue(project);
    query.addBindValue(taskName);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return QDate().currentDate();
    }

    if (query.next()) {
        m_db.commit();
        return query.value(0).toDate();
    }

    m_db.commit();
    return QDate().currentDate();
}

QStringList DBManager::getAllTasks(const QString &project)
{
    m_db.transaction();
    QStringList res;
    QSqlQuery query(m_db);
    query.prepare("SELECT tasks.name FROM tasks INNER JOIN projects ON "
                  "tasks.parent_project_id=projects.id WHERE projects.name=?;");
    query.addBindValue(project);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return res;
    }

    while (query.next()) {
        res << query.value(0).toString();
    }

    m_db.commit();
    return res;
}

QStringList DBManager::getUserTasks(const QString &project, const QString &username)
{
    m_db.transaction();
    QStringList res;
    QSqlQuery query(m_db);
    query.prepare(
        "SELECT tasks.name FROM tasks JOIN projects ON tasks.parent_project_id=projects.id JOIN "
        "users ON tasks.user_id=users.id WHERE users.username=? AND projects.name=?;");
    query.addBindValue(username);
    query.addBindValue(project);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return res;
    }

    while (query.next()) {
        res << query.value(0).toString();
    }

    m_db.commit();
    return res;
}

uint8_t DBManager::changeProjectNameDesc(const QString &currentName,
                                         const QString &newName,
                                         const QString &newDesc)
{
    m_db.transaction();
    QSqlQuery query(m_db);
    query.prepare("SELECT name FROM projects WHERE name=?;");
    query.addBindValue(newName);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return EXIT_FAILURE;
    }

    if (query.next()) {
        m_db.commit();
        return 2;
    }

    query.prepare("UPDATE projects SET name=?, description=? WHERE name=?;");
    query.addBindValue(newName);
    query.addBindValue(newDesc);
    query.addBindValue(currentName);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return EXIT_FAILURE;
    } else {
        m_db.commit();
        return EXIT_SUCCESS;
    }

    m_db.commit();
    return EXIT_SUCCESS;
}

void DBManager::removeProjects(const QStringList &projects)
{
    m_db.transaction();
    QSqlQuery query(m_db);

    QStringList quotedProjects;
    for (const QString &project : projects)
        quotedProjects << ("'" + project + "'");

    QString projectsList = quotedProjects.join(',');
    QString sql = QString("DELETE FROM tasks WHERE parent_project_id IN "
                          "(SELECT id FROM projects WHERE name IN (%1));")
                      .arg(projectsList);

    if (!query.exec(sql)) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return;
    }

    sql = QString("DELETE FROM user_projects WHERE project_id IN "
                  "(SELECT id FROM projects WHERE name IN (%1));")
              .arg(projectsList);
    if (!query.exec(sql)) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return;
    }

    sql = QString("DELETE FROM projects WHERE name IN (%1);").arg(projectsList);
    if (!query.exec(sql)) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return;
    }

    m_db.commit();
}

void DBManager::updateTask(const QString &currentName,
                           const QString &project,
                           const QString &newName,
                           const QDate &newDate,
                           const QString &newStatus)
{
    m_db.transaction();
    QSqlQuery query(m_db);
    query.prepare("UPDATE tasks SET name=?, status=?, due_date=? WHERE name=? AND "
                  "parent_project_id=(SELECT id FROM projects WHERE name=?);");
    query.addBindValue(newName);
    query.addBindValue(newStatus.toUpper());
    query.addBindValue(newDate.toString("yyyy-MM-dd"));
    query.addBindValue(currentName);
    query.addBindValue(project);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return;
    }

    m_db.commit();
}

uint8_t DBManager::createTask(const QString &project,
                              const QString &name,
                              const QDate &due_date,
                              const QString &user)
{
    m_db.transaction();
    QSqlQuery query(m_db);
    query.prepare("SELECT tasks.name FROM tasks INNER JOIN users ON tasks.user_id=users.id INNER "
                  "JOIN projects ON tasks.parent_project_id=projects.id WHERE users.username=? AND "
                  "projects.name=? AND tasks.name=?;");
    query.addBindValue(user);
    query.addBindValue(project);
    query.addBindValue(name);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return EXIT_FAILURE;
    }

    if (query.next()) {
        m_db.commit();
        return 2;
    }

    qDebug() << due_date;

    query.prepare(
        "INSERT INTO tasks (name, user_id, parent_project_id, due_date) VALUES (?, (SELECT id FROM "
        "users WHERE username=?), (SELECT id FROM projects WHERE name=?), ?);");
    query.addBindValue(name);
    query.addBindValue(user);
    query.addBindValue(project);
    query.addBindValue(due_date.toString("yyyy-MM-dd"));
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return EXIT_FAILURE;
    }

    m_db.commit();
    return EXIT_SUCCESS;
}

uint8_t DBManager::addEquipment(const QString &name, const QString &inventoryNumber)
{
    m_db.transaction();
    QSqlQuery query(m_db);
    query.prepare("SELECT name FROM equipment WHERE inventory_number=?;");
    query.addBindValue(inventoryNumber);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return EXIT_FAILURE;
    }

    if (query.next()) {
        m_db.commit();
        return 2;
    }

    query.prepare("INSERT INTO equipment (name, inventory_number) VALUES (?, ?);");
    query.addBindValue(name);
    query.addBindValue(inventoryNumber);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return EXIT_FAILURE;
    }

    m_db.commit();

    return EXIT_SUCCESS;
}

void DBManager::deleteEquipmentRow(const QString &inventoryNumber)
{
    m_db.transaction();
    QSqlQuery query(m_db);
    query.prepare("DELETE FROM equipment WHERE inventory_number=?;");
    query.addBindValue(inventoryNumber);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return;
    }

    m_db.commit();
    return;
}

QStringList DBManager::getTeamsByCurrentUser(const QString &user)
{
    m_db.transaction();
    QSqlQuery query(m_db);
    QStringList res;
    query.prepare(
        "SELECT teams.name FROM teams INNER JOIN user_teams ON teams.id=user_teams.team_id INNER "
        "JOIN users ON user_teams.user_id=users.id WHERE users.username=?;");
    query.addBindValue(user);

    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return res;
    }

    m_db.commit();

    while (query.next())
        res << query.value(0).toString();

    return res;
}

QStringList DBManager::getAllTeams()
{
    m_db.transaction();
    QSqlQuery query(m_db);
    QStringList res;
    query.prepare("SELECT name FROM teams;");

    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return res;
    }

    m_db.commit();

    while (query.next())
        res << query.value(0).toString();

    return res;
}

QStringList DBManager::getUsersByTeam(const QString &team)
{
    m_db.transaction();
    QSqlQuery query(m_db);
    QStringList res;
    query.prepare(
        "SELECT users.username FROM users INNER JOIN user_teams ON users.id=user_teams.user_id "
        "INNER JOIN teams ON user_teams.team_id=teams.id WHERE teams.name=?;");
    query.addBindValue(team);

    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return res;
    }

    m_db.commit();

    while (query.next())
        res << query.value(0).toString();

    return res;
}

bool DBManager::createTeam(const QString &team, const QStringList &users)
{
    m_db.transaction();
    QSqlQuery query(m_db);

    QStringList quotedUsers;
    for (const QString &user : users)
        quotedUsers << ("'" + user + "'");

    QString usersList = quotedUsers.join(',');
    QString sql = QString("CALL create_team_with_users('%1', ARRAY[%2]);").arg(team).arg(usersList);

    if (!query.exec(sql)) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return false;
    }

    m_db.commit();

    return true;
}

bool DBManager::removeTeam(const QString &team)
{
    m_db.transaction();
    QSqlQuery query(m_db);

    QString formattedTeam = team;
    formattedTeam = formattedTeam.toLower();
    formattedTeam[0] = formattedTeam[0].toUpper();

    query.prepare("SELECT delete_team(?);");
    query.addBindValue(formattedTeam);

    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return false;
    }

    if (query.next()) {
        m_db.commit();

        return query.value(0).toBool();
    }

    m_db.commit();

    return false;
}

QJsonObject DBManager::getUserData(const QString &username)
{
    m_db.transaction();
    QSqlQuery query(m_db);
    query.prepare("SELECT user_details.email, user_details.phone, user_details.salary, "
                  "(SELECT users.username FROM users WHERE users.id = user_details.manager_id) AS "
                  "manager_name, "
                  "user_details.vacation_days, user_details.start_date, user_details.end_date "
                  "FROM user_details "
                  "JOIN users ON user_details.user_id = users.id "
                  "WHERE users.username = ?;");
    query.addBindValue(username);

    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return QJsonObject();
    }

    QJsonObject result;
    if (query.next()) {
        result.insert("email", QJsonValue::fromVariant(query.value("email")));
        result.insert("phone", QJsonValue::fromVariant(query.value("phone")));
        result.insert("salary", QJsonValue::fromVariant(query.value("salary")));
        result.insert("manager_name", QJsonValue::fromVariant(query.value("manager_name")));
        result.insert("vacation_days", QJsonValue::fromVariant(query.value("vacation_days")));
        result.insert("start_date", QJsonValue::fromVariant(query.value("start_date")));
        result.insert("end_date", QJsonValue::fromVariant(query.value("end_date")));
    }

    m_db.commit();

    return result;
}

bool DBManager::updateUserData(const QString &username,
                               const QString &email,
                               const QString &phone,
                               const double &salary,
                               const QString &manager,
                               const int &vacation,
                               const QDate &startDate,
                               const QDate &endDate)
{
    m_db.transaction();
    QSqlQuery query(m_db);
    int user_id = -1, manager_id = -1;
    query.prepare("SELECT id FROM users WHERE username = :username;");
    query.bindValue(":username", username);
    if (!query.exec() || !query.next()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return false;
    }
    user_id = query.value(0).toInt();

    if (!manager.isEmpty()) {
        query.prepare("SELECT id FROM users WHERE username = :manager;");
        query.bindValue(":manager", manager);
        if (!query.exec() || !query.next()) {
            LOG_FAILED_QUERY(query);
            m_db.rollback();
            return false;
        }
        manager_id = query.value(0).toInt();
    }

    query.prepare(R"(
    UPDATE user_details
    SET
        email = :email,
        phone = :phone,
        salary = :salary,
        manager_id = :managerId,
        vacation_days = :vacation,
        start_date = :startDate,
        end_date = :endDate
    WHERE user_id = :userId;
    )");
    query.bindValue(":email", email);
    query.bindValue(":phone", phone);
    query.bindValue(":salary", salary);
    query.bindValue(":managerId", manager_id == -1 ? QVariant(QVariant::Int) : manager_id);
    query.bindValue(":vacation", vacation);
    query.bindValue(":startDate", startDate.toString("yyyy-MM-dd"));
    query.bindValue(":endDate",
                    endDate.isValid() ? endDate.toString("yyyy-MM-dd") : QVariant(QVariant::String));
    query.bindValue(":userId", user_id);

    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        m_db.rollback();
        return false;
    }

    m_db.commit();

    return true;
}
