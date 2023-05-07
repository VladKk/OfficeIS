#pragma once

#include "modelattached.h"
#include "config.h"

OFFICEIS_NS_BEGIN

struct BaseNode {
    BaseNode(ModelAttached *a = nullptr)
        : att(a) {}

    mutable QPointer<ModelAttached> att;
};

template <int C>
struct Node : public BaseNode {
    Node() = default;

    ~Node() {
        if (att) {
            att->resetUp(C);
        }
    }

    Node(ModelAttached *att)
        : BaseNode(att) {
        if (att->up[C]) {
            att->up[C]->att = nullptr;
        }

        att->up[C] = this;
    }

    Node(const Node &other)
        : BaseNode() {
        if (other.att) {
            other.att->up[C] = this;
            att = other.att;
            other.att = nullptr;
        }
    }

    Node(Node &&other) noexcept
        : BaseNode() {
        if (other.att) {
            other.att->up[C] = this;
            att = std::move(other.att);
        }
    }

    Node &operator=(const Node &other) {
        if (other.att) {
            other.att->up[C] = this;
            att = other.att;
            other.att = nullptr;
        }

        return *this;
    }

    Node &operator=(Node &&other) noexcept {
        if (other.att) {
            other.att->up[C] = this;
            att = std::move(other.att);
        }

        return *this;
    }

    void init(ModelAttached *o) {
        att = o;

        if (att->up[C] && att->up[C]->att != o) {
            att->up[C]->att = nullptr;
        }

        att->up[C] = this;
    }
};

OFFICEIS_NS_END
