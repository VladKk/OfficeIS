#include "dbmanager.h"

using namespace OFFICEIS_NS;

DBManager::DBManager(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
    : m_qmlEngine(qmlEngine)
    , m_jsEngine(jsEngine)
    , m_db(QSqlDatabase::addDatabase("QPSQL"))
{}

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
    QSqlQuery query;
    if (!query.exec(m_utils.readFileAsString(":/common/sql/Users.sql"))) {
        LOG_FAILED_QUERY(query);
        return;
    }
}

uint8_t DBManager::registerNewUser(const QString &username, const QString &password)
{
    QSqlQuery query;
    query.prepare("SELECT password FROM users WHERE username=?;");
    query.addBindValue(username);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        return EXIT_FAILURE;
    }

    if (query.next()) {
        qWarning() << "User is already exists";
        return 2;
    }

    query.prepare("INSERT INTO users VALUES (?, ?);");
    query.addBindValue(username);
    query.addBindValue(password);

    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}

QJsonObject DBManager::checkUserIsRemembered(const QString &username)
{
    QJsonObject userData;
    userData["username"] = "";
    userData["isRemembered"] = false;

    QSqlQuery query;
    query.prepare("SELECT is_remembered FROM users WHERE username=?;");
    query.addBindValue(username);
    if (!query.exec())
        LOG_FAILED_QUERY(query);

    if (query.next()) {
        userData["isRemembered"] = query.value(0).toBool();

        if (userData["isRemembered"].toBool()) {
            query.prepare("SELECT password FROM users WHERE username=?;");
            query.addBindValue(username);
            if (!query.exec())
                LOG_FAILED_QUERY(query);

            if (query.next())
                userData["password"] = query.value(0).toString();
        }
    }

    return userData;
}

void DBManager::setRememberMe(const QString &username, const bool &isRemembered)
{
    QSqlQuery query;
    query.prepare("UPDATE users SET is_remembered=? WHERE username=?;");
    query.addBindValue(isRemembered);
    query.addBindValue(username);
    if (!query.exec())
        LOG_FAILED_QUERY(query);
}

bool DBManager::userIsOnline(const QString &username)
{
    QSqlQuery query;
    query.prepare("SELECT is_online FROM users WHERE username=?;");
    query.addBindValue(username);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        return false;
    }

    if (query.next()) {
        return query.value(0).toBool();
    }

    return false;
}

void DBManager::setIsOnline(const QString &username, const bool &isOnline)
{
    QSqlQuery query;
    query.prepare("UPDATE users SET is_online=? WHERE username=?;");
    query.addBindValue(isOnline);
    query.addBindValue(username);
    if (!query.exec())
        LOG_FAILED_QUERY(query);
}

uint8_t DBManager::checkAccount(const QString &username, const QString &password)
{
    QSqlQuery query;
    query.prepare("SELECT password FROM users WHERE username=? LIMIT 1;");
    query.addBindValue(username);
    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        return 3;
    }

    if (query.next())
        return query.value(0).toString() != password ? 2 : EXIT_SUCCESS;
    else
        return EXIT_FAILURE;
}
