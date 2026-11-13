#include "ui/AppController.hpp"

#include <QDebug>
#include <map>
#include <algorithm>
#include <utility>

#include "core/Rank.h"

namespace babyfoot::ui {

AppController::AppController(babyfoot::core::PlayerService& playerService,
                             babyfoot::core::RegleService& regleService,
                             babyfoot::core::MatchService& matchService,
                             QObject* parent)
    : QObject{parent},
      playerService_{playerService},
      regleService_{regleService},
      matchService_{matchService} {
    refreshPlayers();
        refreshLeaderboard();
        refreshTopPlayers();
    refreshRegles();
    refreshMatchHistory();
}

QStringList AppController::players() const {
    return players_;
}

QVariantList AppController::regles() const {
    return regles_;
}

QVariantMap AppController::matchDetails(int matchId) {
    const auto match = matchService_.match(matchId);
    if (match.id == 0) {
        return {};
    }

    QVariantMap details{
        {QStringLiteral("id"), match.id},
        {QStringLiteral("format"), match.format},
        {QStringLiteral("competitive"), match.competitive},
        {QStringLiteral("teamAScore"), match.teamAScore},
        {QStringLiteral("teamBScore"), match.teamBScore},
        {QStringLiteral("playedAt"), match.playedAt}
    };

    QVariantList participants;
    for (const auto& participant : match.participantDetails) {
        participants.push_back(QVariantMap{
            {QStringLiteral("pseudo"), participant.pseudo},
            {QStringLiteral("team"), participant.team},
            {QStringLiteral("won"), participant.won}
        });
    }
    details.insert(QStringLiteral("participants"), participants);

    QVariantList events;
    for (const auto& event : match.events) {
        QString label = event.type;
        if (event.type == QStringLiteral("goal")) {
            label = QStringLiteral("But");
        } else if (event.type == QStringLiteral("own_goal")) {
            label = QStringLiteral("CSC");
        } else if (event.type == QStringLiteral("gamelle")) {
            label = QStringLiteral("Gamelle");
        }
        events.push_back(QVariantMap{
            {QStringLiteral("pseudo"), event.pseudo},
            {QStringLiteral("type"), label},
            {QStringLiteral("positionCode"), event.positionCode}
        });
    }
    details.insert(QStringLiteral("events"), events);
    return details;
}

void AppController::refreshMatchHistory() {
    QVariantList history;
    for (const auto& match : matchService_.history()) {
        QVariantMap entry;
        entry.insert(QStringLiteral("id"), match.id);
        entry.insert(QStringLiteral("format"), match.format);
        entry.insert(QStringLiteral("competitive"), match.competitive);
        entry.insert(QStringLiteral("score"), QStringLiteral("%1 - %2")
                                                   .arg(match.teamAScore)
                                                   .arg(match.teamBScore));
        entry.insert(QStringLiteral("playedAt"), match.playedAt);
        entry.insert(QStringLiteral("participants"),
                     match.participants.join(QStringLiteral(", ")));
        history.push_back(entry);
    }
    matchHistory_ = std::move(history);
    emit matchHistoryChanged();
}

void AppController::addPlayer(const QString& pseudo) {
    if (pseudo.trimmed().isEmpty()) {
        return;
    }

    // playerService_.addPlayer attend déjà un QString !
    playerService_.addPlayer(pseudo.trimmed());
    refreshPlayers();
    refreshLeaderboard();
    refreshTopPlayers();
}

void AppController::addRegle(const QString& nom, const QString& contenu) {
    if (nom.trimmed().isEmpty() || contenu.trimmed().isEmpty()) {
        return;
    }

    // regleService attend des std::string
    regleService_.addRegle(nom.trimmed().toStdString(),
                           contenu.trimmed().toStdString());
    refreshRegles();
}

void AppController::selectPlayer(const QString& pseudo) {
    for (const auto& player : playerService_.players(statsMode_)) {
        // player.pseudo est déjà un QString !
        if (player.pseudo != pseudo) {
            continue;
        }

        selectedPlayer_ = {
            {QStringLiteral("pseudo"), player.pseudo},
            {QStringLiteral("mmr"), player.stats.mmr},
            {QStringLiteral("rank"), babyfoot::core::toString(player.rank())},
            {QStringLiteral("goals"), player.stats.buts_marques},
            {QStringLiteral("ownGoals"), player.stats.csc},
            {QStringLiteral("usefulGoals"), player.stats.butsUtiles()},
            {QStringLiteral("gamelles"), player.stats.gamelles},
            {QStringLiteral("wins"), player.stats.victoires},
            {QStringLiteral("losses"), player.stats.defaites},
            {QStringLiteral("matchesPlayed"), player.stats.matchsJoues()},
            {QStringLiteral("format"), statsMode_.format},
            {QStringLiteral("competitive"), statsMode_.competitive}
        };
        emit selectedPlayerChanged();
        return;
    }
}

void AppController::incrementCounter() {
    ++counter_;
    emit counterChanged();
}

void AppController::setStatsMode(int format, bool competitive) {
    if (format != 1 && format != 2) {
        qWarning() << "Format de statistiques invalide :" << format;
        return;
    }

    if (statsMode_.format == format &&
        statsMode_.competitive == competitive) {
        return;
    }

    statsMode_ = {.format = format, .competitive = competitive};
    const QString pseudo = selectedPlayer_.value(QStringLiteral("pseudo")).toString();
    if (!pseudo.isEmpty()) {
        selectPlayer(pseudo);
    }
    emit statsModeChanged();
}

void AppController::setLeaderboardMode(bool ranked) {
    if (leaderboardRanked_ == ranked) {
        return;
    }
    leaderboardRanked_ = ranked;
    refreshLeaderboard();
}

QVariantList AppController::recordMatch(int format, bool competitive,
                                        const QVariantMap& matchData) {
    if (format != 1 && format != 2) {
    qWarning() << "Format de match invalide :" << format;
    return {};            // avant : return false;
}

    const babyfoot::core::GameMode mode{format, competitive};
    babyfoot::core::MatchRecord match;
    match.mode = mode;

    match.teamAScore = matchData.value(QStringLiteral("teamAScore")).toInt();
    match.teamBScore = matchData.value(QStringLiteral("teamBScore")).toInt();

    match.winningScore = matchData.value(QStringLiteral("winningScore"), 5).toInt();
    if (match.winningScore < 1 || match.winningScore > 10 ||
        (competitive && match.winningScore != 3 && match.winningScore != 5)) {
        qWarning() << "Nombre de points gagnants invalide :" << match.winningScore;
        return {};            // avant : return false;
    }

    const QVariantList participants = matchData.value(
        QStringLiteral("participants")).toList();
    for (const QVariant& result : participants) {
        const QVariantMap values = result.toMap();
        const QString pseudo = values.value(QStringLiteral("pseudo")).toString();
        if (pseudo.isEmpty()) {
            qWarning() << "Résultat de match sans joueur.";
            return {};
        }

        babyfoot::core::MatchParticipant participant;
        participant.pseudo = pseudo;
        participant.team = values.value(QStringLiteral("team")).toInt();
        participant.won = values.value(QStringLiteral("win")).toInt() != 0;
        participant.stats.buts_marques = values.value(QStringLiteral("goals")).toInt();
        participant.stats.csc = values.value(QStringLiteral("ownGoals")).toInt();
        participant.stats.gamelles = values.value(QStringLiteral("gamelles")).toInt();
        match.participants.push_back(participant);
    }

    const QVariantList events = matchData.value(QStringLiteral("events")).toList();
    for (const QVariant& eventValue : events) {
        const QVariantMap eventMap = eventValue.toMap();
        babyfoot::core::MatchEvent event;
        event.pseudo = eventMap.value(QStringLiteral("pseudo")).toString();
        event.type = eventMap.value(QStringLiteral("type")).toString();
        event.positionCode = eventMap.value(QStringLiteral("positionCode")).toInt();
        if (event.positionCode < 1 || event.positionCode > 11) {
            qWarning() << "Code de position invalide pour :" << event.pseudo;
            return {};
        }
        match.events.push_back(event);
    }

    // CODE POUR ANIMATION DE FIN DE MATCH
    std::map<int, QString> pseudoById;
    for (const auto& player : playerService_.players(mode)) {
        pseudoById[player.id] = player.pseudo;
    }

    const auto changes = playerService_.recordMatch(match);
    if (!changes) {
        return {};
    }

    QVariantList results;
    for (const auto& change : *changes) {
        const QString pseudo = pseudoById[change.playerId];

        int team = 0;
        bool won = false;
        for (const auto& participant : match.participants) {
            if (participant.pseudo == pseudo) {
                team = participant.team;
                won = participant.won;
                break;
            }
        }

        const int oldMmr = change.newMmr - change.delta;
        QString oldRank;
        QString newRank;
        if (competitive) {
            oldRank = babyfoot::core::toString(babyfoot::core::rankFromMMR(oldMmr));
            newRank = babyfoot::core::toString(babyfoot::core::rankFromMMR(change.newMmr));
        }

        results.push_back(QVariantMap{
            {QStringLiteral("pseudo"), pseudo},
            {QStringLiteral("team"), team},
            {QStringLiteral("won"), won},
            {QStringLiteral("oldMmr"), oldMmr},
            {QStringLiteral("newMmr"), change.newMmr},
            {QStringLiteral("delta"), change.delta},
            {QStringLiteral("oldRank"), oldRank},
            {QStringLiteral("newRank"), newRank}
        });
    }

    refreshAfterMatch();
    return results;
}

QVariantList AppController::positionEventCounts(const QString& pseudo,
                                                const QString& eventType) {
    if (pseudo.trimmed().isEmpty()) {
        return {};
    }

    const auto players = playerService_.players(statsMode_);
    for (const auto& player : players) {
        if (player.pseudo != pseudo) {
            continue;
        }

        QVariantList result;
        for (const int count : playerService_.eventCounts(
                 player.id, statsMode_, eventType)) {
            result.append(count);
        }
        return result;
    }
    qWarning() << "Player introuvable pour les détails :" << pseudo;
    return {};
}

void AppController::refreshPlayers() {
    players_.clear();
    for (const auto& player : playerService_.players(statsMode_)) {
        // player.pseudo est déjà un QString, pas besoin de covnersion donc
        players_.append(player.pseudo);
    }
    emit playersChanged();
    refreshLeaderboard();
    refreshTopPlayers();
}

void AppController::refreshLeaderboard() {
    auto players = playerService_.players({.format = 1, .competitive = leaderboardRanked_});
    std::sort(players.begin(), players.end(), [this](const auto& left, const auto& right) {
        const int leftMmr = leaderboardRanked_ ? left.mmr_ranked : left.mmr_casual;
        const int rightMmr = leaderboardRanked_ ? right.mmr_ranked : right.mmr_casual;
        return leftMmr == rightMmr ? left.pseudo < right.pseudo : leftMmr > rightMmr;
    });

    leaderboard_.clear();
    int position = 1;
    for (const auto& player : players) {
        const int mmr = leaderboardRanked_ ? player.mmr_ranked : player.mmr_casual;
        leaderboard_.push_back(QVariantMap{
            {QStringLiteral("position"), position++},
            {QStringLiteral("pseudo"), player.pseudo},
            {QStringLiteral("mmr"), mmr}
        });
    }
    emit leaderboardChanged();
}

void AppController::refreshTopPlayers() {
    QMap<QString, int> winsByPlayer;
    for (const int format : {1, 2}) {
        for (const bool competitive : {false, true}) {
            for (const auto& player : playerService_.players({format, competitive})) {
                winsByPlayer[player.pseudo] += player.stats.victoires;
            }
        }
    }

    QList<QPair<QString, int>> players;
    for (auto it = winsByPlayer.cbegin(); it != winsByPlayer.cend(); ++it) {
        players.append(qMakePair(it.key(), it.value()));
    }
    std::sort(players.begin(), players.end(), [](const auto& left, const auto& right) {
        return left.second == right.second ? left.first < right.first
                                           : left.second > right.second;
    });

    topPlayers_.clear();
    const int count = std::min(5, static_cast<int>(players.size()));
    for (int i = 0; i < count; ++i) {
        topPlayers_.push_back(QVariantMap{
            {QStringLiteral("pseudo"), players[i].first},
            {QStringLiteral("wins"), players[i].second}
        });
    }
    emit topPlayersChanged();
}

void AppController::refreshAfterMatch() {
    refreshPlayers();
    refreshLeaderboard();
    refreshTopPlayers();
    refreshMatchHistory();

    const QString selectedPseudo = selectedPlayer_.value(QStringLiteral("pseudo")).toString();
    if (!selectedPseudo.isEmpty()) {
        selectPlayer(selectedPseudo);
    }
}




void AppController::refreshRegles() {
    regles_.clear();
    for (const auto& regle : regleService_.regles()) {
        QVariantMap map;
        // Dans Regle, le champ s'appelle .titre (et non .nom)
        map.insert(QStringLiteral("nom"), QString::fromStdString(regle.titre));
        map.insert(QStringLiteral("contenu"), QString::fromStdString(regle.contenu));
        regles_.append(map);
    }
    emit reglesChanged();
}

}