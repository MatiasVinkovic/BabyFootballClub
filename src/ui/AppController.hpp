#pragma once

#include <QObject>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>

#include "core/PlayerService.hpp"
#include "core/RegleService.hpp"

namespace babyfoot::ui {

class AppController final : public QObject {
    Q_OBJECT
    Q_PROPERTY(QStringList players READ players NOTIFY playersChanged)
    Q_PROPERTY(int counter READ counter NOTIFY counterChanged)
    Q_PROPERTY(QVariantMap selectedPlayer READ selectedPlayer NOTIFY selectedPlayerChanged)
    Q_PROPERTY(QVariantList regles READ regles NOTIFY reglesChanged) // Uniformisé sur regles

public:
    explicit AppController(babyfoot::core::PlayerService& playerService,
                           babyfoot::core::RegleService& regleService,
                           QObject* parent = nullptr);

    QStringList players() const;
    QVariantList regles() const; // Retourne bien un QVariantList

    int counter() const { return counter_; }
    QVariantMap selectedPlayer() const { return selectedPlayer_; }

    Q_INVOKABLE void addPlayer(const QString& pseudo);
    Q_INVOKABLE void selectPlayer(const QString& pseudo);
    Q_INVOKABLE void incrementCounter();
    Q_INVOKABLE void addRegle(const QString& nom, const QString& contenu); // addRegle

signals:
    void playersChanged();
    void counterChanged();
    void selectedPlayerChanged();
    void reglesChanged();

private:
    void refreshPlayers();
    void refreshRegles();

    babyfoot::core::PlayerService& playerService_;
    babyfoot::core::RegleService& regleService_;

    QStringList players_;
    QVariantMap selectedPlayer_;
    QVariantList regles_; // Stockage interne de la liste des règles
    int counter_ = 0;
};

}