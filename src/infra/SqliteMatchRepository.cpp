#include "infra/SqliteMatchRepository.hpp"

#include <QDateTime>
#include <QDebug>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>

#include <utility>

namespace babyfoot::infra {

SqliteMatchRepository::SqliteMatchRepository(QString databasePath)
    : databasePath_{std::move(databasePath)} {}

void SqliteMatchRepository::init() {
    QSqlDatabase db;
    if (QSqlDatabase::contains()) {
        db = QSqlDatabase::database();
    } else {
        db = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"));
        db.setDatabaseName(databasePath_);
    }

    if (!db.isOpen() && !db.open()) {
        qFatal("Impossible d'ouvrir la base SQLite : %s",
               qPrintable(db.lastError().text()));
    }
}

std::vector<babyfoot::core::MatchHistoryEntry>
SqliteMatchRepository::history() {
    std::vector<babyfoot::core::MatchHistoryEntry> matches;

    QSqlQuery query;
    if (!query.exec(QStringLiteral(R"(
        SELECT m.id, m.format, m.competitive,
               m.team_a_score, m.team_b_score, m.played_at,
               COALESCE(group_concat(p.pseudo, ', '), '')
        FROM matches m
        LEFT JOIN match_players mp ON mp.match_id = m.id
        LEFT JOIN players p ON p.id = mp.player_id
        GROUP BY m.id
        ORDER BY m.played_at DESC, m.id DESC
    )"))) {
        qWarning() << "Lecture de l'historique des matchs impossible :"
                   << query.lastError().text();
        return matches;
    }

    while (query.next()) {
        const QString participants = query.value(6).toString();
        const QString storedDate = query.value(5).toString();
        const QDateTime date = QDateTime::fromString(storedDate, Qt::ISODate);
        matches.push_back({
            .id = query.value(0).toInt(),
            .format = query.value(1).toInt(),
            .competitive = query.value(2).toInt() != 0,
            .teamAScore = query.value(3).toInt(),
            .teamBScore = query.value(4).toInt(),
            .playedAt = date.isValid()
                            ? date.toLocalTime().toString(
                                  QStringLiteral("dd/MM/yyyy HH:mm"))
                            : storedDate,
            .participants = participants.isEmpty()
                                ? QStringList{}
                                : participants.split(QStringLiteral(", "))
        });
    }

    return matches;
}

babyfoot::core::MatchHistoryEntry SqliteMatchRepository::find(int matchId) {
    babyfoot::core::MatchHistoryEntry match;
    QSqlQuery matchQuery;
    matchQuery.prepare(QStringLiteral(R"(
        SELECT id, format, competitive, team_a_score, team_b_score, played_at
        FROM matches
        WHERE id = :id
    )"));
    matchQuery.bindValue(QStringLiteral(":id"), matchId);
    if (!matchQuery.exec() || !matchQuery.next()) {
        qWarning() << "Match introuvable :" << matchId
                   << matchQuery.lastError().text();
        return match;
    }

    match.id = matchQuery.value(0).toInt();
    match.format = matchQuery.value(1).toInt();
    match.competitive = matchQuery.value(2).toInt() != 0;
    match.teamAScore = matchQuery.value(3).toInt();
    match.teamBScore = matchQuery.value(4).toInt();
    const QString storedDate = matchQuery.value(5).toString();
    const QDateTime date = QDateTime::fromString(storedDate, Qt::ISODate);
    match.playedAt = date.isValid()
                         ? date.toLocalTime().toString(
                               QStringLiteral("dd/MM/yyyy HH:mm"))
                         : storedDate;

    QSqlQuery playersQuery;
    playersQuery.prepare(QStringLiteral(R"(
        SELECT p.pseudo, mp.team, mp.won
        FROM match_players mp
        JOIN players p ON p.id = mp.player_id
        WHERE mp.match_id = :match_id
        ORDER BY mp.team, p.pseudo
    )"));
    playersQuery.bindValue(QStringLiteral(":match_id"), matchId);
    if (!playersQuery.exec()) {
        qWarning() << "Participants du match impossibles à lire :"
                   << playersQuery.lastError().text();
        return match;
    }
    while (playersQuery.next()) {
        babyfoot::core::MatchParticipant participant;
        participant.pseudo = playersQuery.value(0).toString();
        participant.team = playersQuery.value(1).toInt();
        participant.won = playersQuery.value(2).toInt() != 0;
        match.participantDetails.push_back(participant);
        match.participants.push_back(participant.pseudo);
    }

    QSqlQuery eventsQuery;
    eventsQuery.prepare(QStringLiteral(R"(
        SELECT p.pseudo, e.event_type, e.position_code
        FROM match_events e
        JOIN players p ON p.id = e.player_id
        WHERE e.match_id = :match_id
        ORDER BY e.id
    )"));
    eventsQuery.bindValue(QStringLiteral(":match_id"), matchId);
    if (!eventsQuery.exec()) {
        qWarning() << "Événements du match impossibles à lire :"
                   << eventsQuery.lastError().text();
        return match;
    }
    while (eventsQuery.next()) {
        match.events.push_back({
            .pseudo = eventsQuery.value(0).toString(),
            .type = eventsQuery.value(1).toString(),
            .positionCode = eventsQuery.value(2).toInt()
        });
    }

    return match;
}

} // namespace babyfoot::infra
