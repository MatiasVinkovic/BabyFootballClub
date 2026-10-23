#pragma once

#include <QObject>
#include <QStringList>
#include <QVariantMap>

#include "core/PlayerService.hpp"

namespace babyfoot::ui {

class AppController final : public QObject {
    Q_OBJECT
    Q_PROPERTY(QStringList players READ players NOTIFY playersChanged)
    Q_PROPERTY(int counter READ counter NOTIFY counterChanged)
    Q_PROPERTY(QVariantMap selectedPlayer READ selectedPlayer NOTIFY selectedPlayerChanged)

public:
    explicit AppController(babyfoot::core::PlayerService& service,
                           QObject* parent = nullptr);

    QStringList players() const;
    int counter() const { return counter_; }
    QVariantMap selectedPlayer() const { return selectedPlayer_; }

    Q_INVOKABLE void addPlayer(const QString& pseudo);
    Q_INVOKABLE void selectPlayer(const QString& pseudo);
    Q_INVOKABLE void incrementCounter();

signals:
    void playersChanged();
    void counterChanged();
    void selectedPlayerChanged();

private:
    void refreshPlayers();

    babyfoot::core::PlayerService& service_;
    QStringList players_;
    QVariantMap selectedPlayer_;
    int counter_ = 0;
};

}