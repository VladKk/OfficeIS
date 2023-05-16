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
