#pragma once

#include "modelattached.h"
#include "config.h"
#include <private/qqmldelegatemodel_p.h>

OFFICEIS_NS_BEGIN

class FilteringModelPrivate;
class FilteringModel : public QQmlInstanceModel
{
    Q_OBJECT
    QML_ELEMENT
    Q_DECLARE_PRIVATE(FilteringModel)
    Q_PROPERTY(QQmlListProperty<QObject> children READ qmlChildren NOTIFY childrenChanged)
    Q_CLASSINFO("DefaultProperty", "children")
    Q_DISABLE_COPY_MOVE(FilteringModel)

public:

    FilteringModel(QObject *parent = nullptr);
    ~FilteringModel() override = default;

    Q_INVOKABLE QObject *get(int index) const;

    // QQmlInstanceModel interface
    int count() const override;
    bool isValid() const override;
    QObject *object(int index, QQmlIncubator::IncubationMode incubationMode) override;
    ReleaseFlags release(QObject *object, ReusableFlag reusableFlag) override;
    QVariant variantValue(int, const QString &) override;
    void setWatchedRoles(const QList<QByteArray> &/*roles*/) override {}
    QQmlIncubator::Status incubationStatus(int index) override;
    int indexOf(QObject *object, QObject *) const override;

signals:

    void childrenChanged();
    void staticChildReferenced(QObject *child, bool referenced);

private:

    friend class ModelAttached;

    int filteredIndex_helper(const ModelAttached *attached) const;
    int sourceIndex_helper(const ModelAttached *attached) const;
    QQmlListProperty<QObject> qmlChildren();

    static void qmlChildrenAppend(QQmlListProperty<QObject> *list, QObject *object);
    static long long int qmlChildrenCount(QQmlListProperty<QObject> *list);
    static QObject *qmlChildrenAt(QQmlListProperty<QObject> *list, long long int index);
    static void qmlChildrenClear(QQmlListProperty<QObject> *list);

    void handleIsValidChanged(ModelAttached *attached, bool isValid);
};

OFFICEIS_NS_END
