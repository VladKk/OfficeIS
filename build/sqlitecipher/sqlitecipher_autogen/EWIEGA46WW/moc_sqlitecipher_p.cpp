/****************************************************************************
** Meta object code from reading C++ file 'sqlitecipher_p.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.2.4)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "../../../../sqlitecipher/sqlitecipher_p.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'sqlitecipher_p.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 68
#error "This file was generated using the moc from 6.2.4. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_SQLiteCipherDriver_t {
    const uint offsetsAndSize[10];
    char stringdata0[55];
};
#define QT_MOC_LITERAL(ofs, len) \
    uint(offsetof(qt_meta_stringdata_SQLiteCipherDriver_t, stringdata0) + ofs), len 
static const qt_meta_stringdata_SQLiteCipherDriver_t qt_meta_stringdata_SQLiteCipherDriver = {
    {
QT_MOC_LITERAL(0, 18), // "SQLiteCipherDriver"
QT_MOC_LITERAL(19, 18), // "handleNotification"
QT_MOC_LITERAL(38, 0), // ""
QT_MOC_LITERAL(39, 9), // "tableName"
QT_MOC_LITERAL(49, 5) // "rowid"

    },
    "SQLiteCipherDriver\0handleNotification\0"
    "\0tableName\0rowid"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_SQLiteCipherDriver[] = {

 // content:
      10,       // revision
       0,       // classname
       0,    0, // classinfo
       1,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: name, argc, parameters, tag, flags, initial metatype offsets
       1,    2,   20,    2, 0x08,    1 /* Private */,

 // slots: parameters
    QMetaType::Void, QMetaType::QString, QMetaType::LongLong,    3,    4,

       0        // eod
};

void SQLiteCipherDriver::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<SQLiteCipherDriver *>(_o);
        (void)_t;
        switch (_id) {
        case 0: _t->handleNotification((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<qint64>>(_a[2]))); break;
        default: ;
        }
    }
}

const QMetaObject SQLiteCipherDriver::staticMetaObject = { {
    QMetaObject::SuperData::link<QSqlDriver::staticMetaObject>(),
    qt_meta_stringdata_SQLiteCipherDriver.offsetsAndSize,
    qt_meta_data_SQLiteCipherDriver,
    qt_static_metacall,
    nullptr,
qt_incomplete_metaTypeArray<qt_meta_stringdata_SQLiteCipherDriver_t
, QtPrivate::TypeAndForceComplete<SQLiteCipherDriver, std::true_type>
, QtPrivate::TypeAndForceComplete<void, std::false_type>, QtPrivate::TypeAndForceComplete<const QString &, std::false_type>, QtPrivate::TypeAndForceComplete<qint64, std::false_type>


>,
    nullptr
} };


const QMetaObject *SQLiteCipherDriver::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *SQLiteCipherDriver::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_SQLiteCipherDriver.stringdata0))
        return static_cast<void*>(this);
    return QSqlDriver::qt_metacast(_clname);
}

int SQLiteCipherDriver::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QSqlDriver::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 1)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 1;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 1)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 1;
    }
    return _id;
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
