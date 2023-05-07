#include "modelattached.h"
#include "filteringmodel.h"
#include "config.h"

using namespace OFFICEIS_NS;

struct AttachedStorage {
    QHash<QObject *, QPointer<ModelAttached>> attachedProperties;
    QStack<QPointer<ModelAttached>> recycle;
};

Q_GLOBAL_STATIC(AttachedStorage, storage)

ModelAttached::ModelAttached(FilteringModel *model, QObject *parent)
    : QObject(model), m_model(model), m_attachedTo(parent) {}

ModelAttached::~ModelAttached() {
    if (m_isDisposed) {
        storage->recycle.removeAll(this);
    } else {
        storage->attachedProperties.remove(this);
    }
}

ModelAttached *ModelAttached::get(FilteringModel *model, QObject *object) {
    if (!object) {
        if (storage->recycle.isEmpty()) {
            return new ModelAttached(model, object);
        } else {
            ModelAttached *att = storage->recycle.pop();
            if (!att) {
                return get(model, object);
            }

            att->up[0] = nullptr;
            att->up[1] = nullptr;
            att->init(model, object);

            return att;
        }
    }

    const auto &it = storage->attachedProperties.constFind(object);
    ModelAttached *att = nullptr;

    if (it == storage->attachedProperties.constEnd()) {
        // unknown attachment -> pop one from recycling or create a new
        if (storage->recycle.isEmpty()) {
            att = new ModelAttached(model, object);

            if (!model && object) {
                // probably invalid attachment or early instantiation of attached properties object
                att->setParent(object);
            }
        } else {
            att = storage->recycle.pop();

            if (!att) {
                return get(model, object);
            }

            att->up[0] = nullptr;
            att->up[1] = nullptr;
            att->init(model, object);
        }

        storage->attachedProperties.insert(object, att); // remember in cache
    } else {
        // known attachment
        att = it.value();

        if (Q_UNLIKELY(!att)) {
            qInfo() << "Cached attached null, object deleted, retrying";
            storage->attachedProperties.erase(it);

            return get(model, object);
        }

        if (!att->m_model && model) {
            // set model for a cached attachment
            att->m_model = model;
            att->setParent(model);
        }
    }

    return att;
}

void ModelAttached::detachFrom(QObject *object) {
    auto it = storage->attachedProperties.find(object);

    if (it != storage->attachedProperties.end()) {
        it.value()->m_attachedTo.clear();
        it.value()->setIsReferenced(false);
        storage->attachedProperties.erase(it);
    }
}

void ModelAttached::setReferenced(QObject *object, bool referenced) {
    auto it = storage->attachedProperties.find(object);

    if (it != storage->attachedProperties.end()) {
        it.value()->setIsReferenced(referenced);
    }
}

void ModelAttached::init(FilteringModel *model, QObject *attachedTo) {
    m_isDisposed = false;
    m_attachedTo = attachedTo;
    m_model = model;
    setObjectName(QString(staticMetaObject.className()) + QStringLiteral("→") + QString(attachedTo ? attachedTo->metaObject()->className() : QStringLiteral("null")));
}

/**
 * @brief ModelAttached::dispose clears and moves attached object to recycling stack
 */
void ModelAttached::dispose() {
    if (m_isDisposed) {
        return;
    }

    if (m_attachedTo) {
        storage->attachedProperties.remove(m_attachedTo);
        m_attachedTo.clear();
    }

    up[0] = nullptr;
    up[1] = nullptr;
    m_isDisposed = true;
    m_model = nullptr;
    storage->recycle.push(this);
}

int ModelAttached::index() const {
    return m_model ? m_model->filteredIndex_helper(this) : -1;
}

int ModelAttached::sourceIndex() const {
    return m_model ? m_model->sourceIndex_helper(this) : -1;
}

bool ModelAttached::isValid() const {
    return m_isValid;
}

void ModelAttached::setIsValid(bool isValid) {
    if (m_isValid != isValid) {
        m_isValid = isValid;
        emit isValidChanged(m_isValid);

        if (m_model) {
            m_model->handleIsValidChanged(this, isValid);
        }
    }
}

ModelAttached *ModelAttached::qmlAttachedProperties(QObject *object) {
    return ModelAttached::get(nullptr, object);
}

void ModelAttached::resetUp(int i) {
    up[i] = nullptr;
    if (!up[0] && !up[1]) {
        dispose();
    }
}

QObject *ModelAttached::attachedTo() const {
    return m_attachedTo.data();
}

bool ModelAttached::isReferenced() const {
    return m_isReferenced;
}

void ModelAttached::setIsReferenced(bool newIsReferenced) {
    if (m_isReferenced == newIsReferenced)
        return;
        
    m_isReferenced = newIsReferenced;
    emit isReferencedChanged();
}
