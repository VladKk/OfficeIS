#include "filteringmodel.h"

#include <private/qobject_p.h>
#include <QQuickItem>
#include <qglobal.h>

#include "modelattached.h"
#include "node.h"
#include "config.h"

using namespace OFFICEIS_NS;

class OfficeIS::FilteringModelPrivate : public QObjectPrivate
{
    Q_DECLARE_PUBLIC(FilteringModel)

public:

    FilteringModelPrivate()
        : QObjectPrivate() {}

    static constexpr const int Source = 0;
    static constexpr const int Filtered = 1;

    struct Child {
        Child(const Child &other) = default;

        Child &operator=(const Child &other);

        explicit Child(QObject *child, int row)
            : object(child), row(row), m_ref(0) {}

        inline int nextRow() const {
            return row + 1;
        }

        void addRef() {
           ++m_ref;
        }

        bool deref() {
            return --m_ref == 0;
        }

        int ref() const {
            return m_ref;
        }

        inline QObject *getObject() const {
            return object;
        }

        QObject *object;
        int row;

    private:

        int m_ref;
    };

    // holds information about created objects
    struct ObjectInfo {
        int childIndex;// holds index of object of enclosing model in children array
        ModelAttached *attached;
    };

    mutable QList<Child> children;
    QHash<QObject *, ObjectInfo> objects;
    QVector<Node<Source>> sourceVector;
    QVector<Node<Filtered>> filteredVector;

    int lastRow() const;
    int appendChild(QObject *child);
    void handleIsValidChanged(ModelAttached *attached, bool isValid);

    int getSourceIndex(const ModelAttached *attached) const {
        if (attached && attached->up[Source]) {
            return static_cast<Node<Source> *>(attached->up[Source]) - sourceVector.constBegin();
        }

        return -1;
    }

    int getFilteredIndex(const ModelAttached *attached) const {
        if (attached && attached->up[Filtered]) {
            return static_cast<Node<Filtered> *>(attached->up[Filtered]) - filteredVector.constBegin();
        }

        return -1;
    }

    int mapToSource(int filteredIndex) const {
        if (filteredIndex < 0 || filteredIndex > filteredVector.size()) {
            return -1;
        }

        if (filteredIndex == filteredVector.size()) {
            return sourceVector.size();
        }

        return getSourceIndex(filteredVector[filteredIndex].att);
    }

    QList<Child>::iterator findChild(int index) const {
        if (index >= children.count()) {
            return children.end();
        }

        return children.begin() + index;
    }
};

FilteringModel::FilteringModel(QObject *parent)
    : QQmlInstanceModel(*(new FilteringModelPrivate), parent) {}

int FilteringModel::count() const {
    Q_D(const FilteringModel);

    return d->filteredVector.size();
}

bool FilteringModel::isValid() const {
    return true;
}

QObject *FilteringModel::object(int index, QQmlIncubator::IncubationMode /*incubationMode*/) {
    Q_D(FilteringModel);

    int sIndex = d->mapToSource(index);
    auto it = d->findChild(sIndex);

    if (it == d->children.end()) {
        return nullptr;
    }

    it->addRef();

    if (it->ref() == 1) {
        emit initItem(index, it->object);

        ModelAttached::setReferenced(it->object, true);

        emit staticChildReferenced(it->object, true);
        emit createdItem(index, it->object);
    }

    return it->object;
}

QQmlInstanceModel::ReleaseFlags FilteringModel::release(QObject *object, QQmlInstanceModel::ReusableFlag /*reusableFlag*/) {
    Q_D(FilteringModel);
    auto it = d->objects.find(object);

    if (it != d->objects.end()) {
        FilteringModelPrivate::Child &c = d->children[it.value().childIndex];

        if (c.deref()) {
            ModelAttached::setReferenced(object, false);

            emit staticChildReferenced(object, false);

            return QQmlInstanceModel::Destroyed; // pretending that item is destroyed

        }

        return QQmlInstanceModel::Referenced;
    }

    return QQmlInstanceModel::Referenced;
}

QVariant FilteringModel::variantValue(int index, const QString &role) {
    Q_D(FilteringModel);
    auto it = d->findChild(index);

    if (it == d->children.end()) {
        return QVariant();
    }

    return it->object->property(role.toUtf8().constData());
}

QQmlIncubator::Status FilteringModel::incubationStatus(int index) {
    Q_D(FilteringModel);
    auto it = d->findChild(index);

    if (it == d->children.end()) {
        return QQmlIncubator::Null;
    }

    return QQmlIncubator::Ready;
}

int FilteringModel::indexOf(QObject *object, QObject *) const {
    Q_D(const FilteringModel);
    auto inf = d->objects.value(object);

    if (inf.attached) {
        return inf.attached->index();
    }

    return -1;
}

QObject *FilteringModel::get(int index) const {
    Q_D(const FilteringModel);
    auto it = d->findChild(index);

    if (it == d->children.end()) {
        return nullptr;
    }

    return it->object;
}

int FilteringModel::sourceIndex_helper(const ModelAttached *attached) const {
    Q_D(const FilteringModel);

    return d->getSourceIndex(attached);
}

int FilteringModel::filteredIndex_helper(const ModelAttached *attached) const {
    Q_D(const FilteringModel);

    return d->getFilteredIndex(attached);
}

QQmlListProperty<QObject> FilteringModel::qmlChildren() {
    return QQmlListProperty<QObject>(this, 0, &FilteringModel::qmlChildrenAppend, &FilteringModel::qmlChildrenCount, &FilteringModel::qmlChildrenAt, &FilteringModel::qmlChildrenClear);
}

void FilteringModel::qmlChildrenAppend(QQmlListProperty<QObject> *list, QObject *object) {
    FilteringModel *o = qobject_cast<FilteringModel *>(list->object);
    FilteringModelPrivate *d = o->d_func();
    int countAdded = 0;
    countAdded = d->appendChild(object);

    if (countAdded > 0) {
        emit o->countChanged();
    }

    emit o->childrenChanged();
}

long long int FilteringModel::qmlChildrenCount(QQmlListProperty<QObject> *list) {
    FilteringModel *o = qobject_cast<FilteringModel *>(list->object);
    FilteringModelPrivate *d = o->d_func();

    return d->children.size();
}

QObject *FilteringModel::qmlChildrenAt(QQmlListProperty<QObject> *list, long long int index) {
    FilteringModel *o = qobject_cast<FilteringModel *>(list->object);
    FilteringModelPrivate *d = o->d_func();

    return d->children.at(index).getObject();
}

void FilteringModel::qmlChildrenClear(QQmlListProperty<QObject> *list) {
    FilteringModel *o = qobject_cast<FilteringModel *>(list->object);
    FilteringModelPrivate *d = o->d_func();
    d->children.clear();

    emit o->childrenChanged();
    emit o->countChanged();
}

void FilteringModel::handleIsValidChanged(ModelAttached *attached, bool isValid) {
    Q_D(FilteringModel);
    d->handleIsValidChanged(attached, isValid);
}

FilteringModelPrivate::Child &FilteringModelPrivate::Child::operator=(const FilteringModelPrivate::Child &other) {
    this->m_ref = other.m_ref;
    object = other.object;

    return *this;
}

int FilteringModelPrivate::lastRow() const {
    if (children.isEmpty()) {
        return 0;
    }

    return children.last().nextRow();
}

int FilteringModelPrivate::appendChild(QObject *child) {
    Q_Q(FilteringModel);
    int ret = 0;
    int idx = lastRow();
    int childIdx = children.size();
    children.append(Child(child, idx));
    ObjectInfo inf{childIdx, ModelAttached::get(const_cast<FilteringModel *>(q), child)};
    objects.insert(child, inf);
    sourceVector.append(Node<Source>(inf.attached));

    if (inf.attached->isValid()) {
        filteredVector.append(Node<Filtered>(inf.attached));
        ret = 1;
    }

    return ret;
}

void FilteringModelPrivate::handleIsValidChanged(ModelAttached *attached, bool isValid) {
    Q_Q(FilteringModel);
    QQmlChangeSet change;
    int fIdx;

    if (!isValid) {
        // remove from filtered
        fIdx = getFilteredIndex(attached);

        if (fIdx == -1) {
            return;// was not visible already? TODO: ???
        }

        attached->resetUp(Filtered);
        filteredVector.remove(fIdx);

        emit attached->indexChanged();
        // make change
        change.remove(fIdx, 1);
    } else {
        // find index in filtered vector
        auto it = sourceVector.begin() + getSourceIndex(attached);

        while (++it != sourceVector.end()) {
            if (it->att && it->att->isValid()) {
                break;
            }
        }

        if (it == sourceVector.end()) {
            fIdx = filteredVector.size();
        } else {
            fIdx = getFilteredIndex(it->att);
        }

        filteredVector.insert(fIdx, Node<Filtered>(attached));

        emit attached->indexChanged();

        change.insert(fIdx, 1);
    }

    for (int i = fIdx; i < filteredVector.size(); ++i) {
        emit filteredVector[i].att->indexChanged();
    }
    
    emit q->modelUpdated(change, false);
    emit q->countChanged();
}
