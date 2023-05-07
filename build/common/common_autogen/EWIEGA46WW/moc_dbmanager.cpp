/****************************************************************************
** Meta object code from reading C++ file 'dbmanager.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.2.4)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "../../../../common/dbmanager.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'dbmanager.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 68
#error "This file was generated using the moc from 6.2.4. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_OfficeIS__DBManager_t {
    const uint offsetsAndSize[52];
    char stringdata0[258];
};
#define QT_MOC_LITERAL(ofs, len) \
    uint(offsetof(qt_meta_stringdata_OfficeIS__DBManager_t, stringdata0) + ofs), len 
static const qt_meta_stringdata_OfficeIS__DBManager_t qt_meta_stringdata_OfficeIS__DBManager = {
    {
QT_MOC_LITERAL(0, 19), // "OfficeIS::DBManager"
QT_MOC_LITERAL(20, 11), // "QML.Element"
QT_MOC_LITERAL(32, 4), // "auto"
QT_MOC_LITERAL(37, 13), // "QML.Singleton"
QT_MOC_LITERAL(51, 4), // "true"
QT_MOC_LITERAL(56, 9), // "connectDB"
QT_MOC_LITERAL(66, 0), // ""
QT_MOC_LITERAL(67, 4), // "host"
QT_MOC_LITERAL(72, 4), // "port"
QT_MOC_LITERAL(77, 6), // "dbName"
QT_MOC_LITERAL(84, 4), // "user"
QT_MOC_LITERAL(89, 8), // "password"
QT_MOC_LITERAL(98, 15), // "registerNewUser"
QT_MOC_LITERAL(114, 7), // "uint8_t"
QT_MOC_LITERAL(122, 8), // "username"
QT_MOC_LITERAL(131, 21), // "checkUserIsRemembered"
QT_MOC_LITERAL(153, 13), // "setRememberMe"
QT_MOC_LITERAL(167, 12), // "isRemembered"
QT_MOC_LITERAL(180, 12), // "userIsOnline"
QT_MOC_LITERAL(193, 11), // "setIsOnline"
QT_MOC_LITERAL(205, 8), // "isOnline"
QT_MOC_LITERAL(214, 12), // "checkAccount"
QT_MOC_LITERAL(227, 8), // "findUser"
QT_MOC_LITERAL(236, 9), // "resetPass"
QT_MOC_LITERAL(246, 5), // "pass1"
QT_MOC_LITERAL(252, 5) // "pass2"

    },
    "OfficeIS::DBManager\0QML.Element\0auto\0"
    "QML.Singleton\0true\0connectDB\0\0host\0"
    "port\0dbName\0user\0password\0registerNewUser\0"
    "uint8_t\0username\0checkUserIsRemembered\0"
    "setRememberMe\0isRemembered\0userIsOnline\0"
    "setIsOnline\0isOnline\0checkAccount\0"
    "findUser\0resetPass\0pass1\0pass2"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_OfficeIS__DBManager[] = {

 // content:
      10,       // revision
       0,       // classname
       2,   14, // classinfo
       9,   18, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // classinfo: key, value
       1,    2,
       3,    4,

 // methods: name, argc, parameters, tag, flags, initial metatype offsets
       5,    5,   72,    6, 0x02,    1 /* Public */,
      12,    2,   83,    6, 0x02,    7 /* Public */,
      15,    1,   88,    6, 0x02,   10 /* Public */,
      16,    2,   91,    6, 0x02,   12 /* Public */,
      18,    1,   96,    6, 0x02,   15 /* Public */,
      19,    2,   99,    6, 0x02,   17 /* Public */,
      21,    2,  104,    6, 0x02,   20 /* Public */,
      22,    1,  109,    6, 0x02,   23 /* Public */,
      23,    3,  112,    6, 0x02,   25 /* Public */,

 // methods: parameters
    QMetaType::Void, QMetaType::QString, QMetaType::UInt, QMetaType::QString, QMetaType::QString, QMetaType::QString,    7,    8,    9,   10,   11,
    0x80000000 | 13, QMetaType::QString, QMetaType::QString,   14,   11,
    QMetaType::QJsonObject, QMetaType::QString,   14,
    QMetaType::Void, QMetaType::QString, QMetaType::Bool,   14,   17,
    QMetaType::Bool, QMetaType::QString,   14,
    QMetaType::Void, QMetaType::QString, QMetaType::Bool,   14,   20,
    0x80000000 | 13, QMetaType::QString, QMetaType::QString,   14,   11,
    QMetaType::Bool, QMetaType::QString,   14,
    QMetaType::Void, QMetaType::QString, QMetaType::QString, QMetaType::QString,   14,   24,   25,

       0        // eod
};

void OfficeIS::DBManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<DBManager *>(_o);
        (void)_t;
        switch (_id) {
        case 0: _t->connectDB((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<uint>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[4])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[5]))); break;
        case 1: { uint8_t _r = _t->registerNewUser((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])));
            if (_a[0]) *reinterpret_cast< uint8_t*>(_a[0]) = std::move(_r); }  break;
        case 2: { QJsonObject _r = _t->checkUserIsRemembered((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QJsonObject*>(_a[0]) = std::move(_r); }  break;
        case 3: _t->setRememberMe((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<bool>>(_a[2]))); break;
        case 4: { bool _r = _t->userIsOnline((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 5: _t->setIsOnline((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<bool>>(_a[2]))); break;
        case 6: { uint8_t _r = _t->checkAccount((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])));
            if (_a[0]) *reinterpret_cast< uint8_t*>(_a[0]) = std::move(_r); }  break;
        case 7: { bool _r = _t->findUser((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 8: _t->resetPass((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[3]))); break;
        default: ;
        }
    }
}

const QMetaObject OfficeIS::DBManager::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_OfficeIS__DBManager.offsetsAndSize,
    qt_meta_data_OfficeIS__DBManager,
    qt_static_metacall,
    nullptr,
qt_metaTypeArray<
DBManager

, void, const QString &, const uint &, const QString &, const QString &, const QString &, uint8_t, const QString &, const QString &, QJsonObject, const QString &, void, const QString &, const bool &, bool, const QString &, void, const QString &, const bool &, uint8_t, const QString &, const QString &, bool, const QString &, void, const QString &, const QString &, const QString &

>,
    nullptr
} };


const QMetaObject *OfficeIS::DBManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *OfficeIS::DBManager::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_OfficeIS__DBManager.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int OfficeIS::DBManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 9)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 9;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 9)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 9;
    }
    return _id;
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
