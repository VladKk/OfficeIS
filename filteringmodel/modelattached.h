#pragma once

#include <QHash>
#include <QObject>
#include <QPointer>

#include <qqml.h>
#include <array>

#include "config.h"

OFFICEIS_NS_BEGIN

struct BaseNode;
class FilteringModel;
class ModelAttached : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY_MOVE(ModelAttached)
    QML_ELEMENT
    QML_UNCREATABLE("ModelAttached is only available via attached properties")
    /// index holds item's index in FilteringModel taking into account filtered items, as it is perceived in a list
    Q_PROPERTY(int index READ index NOTIFY indexChanged)
    /// sourceIndex holds item's index in FilteringModel without taking into account filtered items (\sa isValid)
    Q_PROPERTY(int sourceIndex READ sourceIndex NOTIFY indexChanged)
    /// isValid property can be set to any element in the model to filter it out.
    Q_PROPERTY(bool isValid READ isValid WRITE setIsValid NOTIFY isValidChanged)
    /// isReferenced property is used to check whether standalone delegates are used by any list.
    /// This can be used for performance reasons such as disconnecting signals or unloading heavy styles
    Q_PROPERTY(bool isReferenced READ isReferenced NOTIFY isReferencedChanged)

public:
    explicit ModelAttached(FilteringModel *model, QObject *parent = nullptr);
    ~ModelAttached() override;

    static ModelAttached *get(FilteringModel *model, QObject *object);
    static void detachFrom(QObject *object);
    static void setReferenced(QObject *object, bool referenced);

    void init(FilteringModel *model, QObject *attachedTo);
    void dispose();
    int index() const;
    int count() const;
    int sourceIndex() const;
    bool isValid() const;
    void setIsValid(bool isValid);

    inline bool isInitialized() const { return bool(m_model) && bool(m_attachedTo); }

    static ModelAttached *qmlAttachedProperties(QObject *object);

    void resetUp(int i);
    QObject* attachedTo() const;
    bool isReferenced() const;
    void setIsReferenced(bool newIsReferenced);

signals:

    void indexChanged();
    void countChanged();
    void isValidChanged(bool isValid);
    void isReferencedChanged();

private:

    template<int C> friend struct Node;
    friend class FilteringModelPrivate;

    std::array<BaseNode *, 2> up = {nullptr, nullptr};
    FilteringModel *m_model = nullptr;
    QPointer<QObject> m_attachedTo;
    bool m_isReferenced = false;
    bool m_isDisposed = false;
    bool m_isValid = true;
};

OFFICEIS_NS_END

QML_DECLARE_TYPEINFO(OfficeIS::ModelAttached, QML_HAS_ATTACHED_PROPERTIES)
