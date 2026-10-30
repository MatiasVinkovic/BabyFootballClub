#pragma once

#include <QObject>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>

#include "core/PlayerService.hpp"
#include "core/RegleService.hpp"
#include "core/MatchService.hpp"

namespace babyfoot::ui {

class AppController final : public QObject {
    Q_OBJECT
    Q_PROPERTY(QStringList players READ players NOTIFY playersChanged)
    Q_PROPERTY(int counter READ counter NOTIFY counterChanged)
    Q_PROPERTY(QVariantMap selectedPlayer READ selectedPlayer NOTIFY selectedPlayerChanged)
    Q_PROPERTY(QVariantList regles READ regles NOTIFY reglesChanged) // Uniformisé sur regles
    Q_PROPERTY(QVariantList matchHistory READ matchHistory NOTIFY matchHistoryChanged)
    Q_PROPERTY(int statsFormat READ statsFormat NOTIFY statsModeChanged)
    Q_PROPERTY(bool statsCompetitive READ statsCompetitive NOTIFY statsModeChanged)

public:
    explicit AppController(babyfoot::core::PlayerService& playerService,
                           babyfoot::core::RegleService& regleService,
                           babyfoot::core::MatchService& matchService,
                           QObject* parent = nullptr);

    QStringList players() const;
    QVariantList regles() const; // Retourne bien un QVariantList
    QVariantList matchHistory() const { return matchHistory_; }

    int counter() const { return counter_; }
    QVariantMap selectedPlayer() const { return selectedPlayer_; }
    int statsFormat() const { return statsMode_.format; }
    bool statsCompetitive() const { return statsMode_.competitive; }

    Q_INVOKABLE void addPlayer(const QString& pseudo);
    Q_INVOKABLE void selectPlayer(const QString& pseudo);
    Q_INVOKABLE void incrementCounter();
    Q_INVOKABLE void addRegle(const QString& nom, const QString& contenu); // addRegle
    Q_INVOKABLE void setStatsMode(int format, bool competitive);
    Q_INVOKABLE bool recordMatch(int format, bool competitive,
                                 const QVariantMap& matchData);
    Q_INVOKABLE QVariantList positionEventCounts(const QString& pseudo,
                                                  const QString& eventType);
    Q_INVOKABLE QVariantMap matchDetails(int matchId);

signals:
    void playersChanged();
    void counterChanged();
    void selectedPlayerChanged();
    void reglesChanged();
    void statsModeChanged();
    void matchHistoryChanged();

private:
    void refreshPlayers();
    void refreshRegles();
    void refreshMatchHistory();

    babyfoot::core::PlayerService& playerService_;
    babyfoot::core::RegleService& regleService_;
    babyfoot::core::MatchService& matchService_;

    QStringList players_;
    QVariantMap selectedPlayer_;
    QVariantList regles_; // Stockage interne de la liste des règles
    QVariantList matchHistory_;
    int counter_ = 0;
    babyfoot::core::GameMode statsMode_;
};

}