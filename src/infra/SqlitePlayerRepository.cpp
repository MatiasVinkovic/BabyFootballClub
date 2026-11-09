#include "infra/SqlitePlayerRepository.hpp"

#include <QDateTime>
#include <QDebug>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QVariant>

#include <map>
#include <utility>

namespace babyfoot::infra {

namespace {

bool execQuery(QSqlQuery& query, const QString& sql) {
    if (query.exec(sql)) {
        return true;
    }

    qWarning() << "Requête SQLite impossible :" << query.lastError().text();
    return false;
}

bool hasColumn(const QString& table, const QString& column) {
    QSqlQuery query;
    query.prepare(QStringLiteral("PRAGMA table_info(%1)").arg(table));
    if (!query.exec()) {
        qWarning() << "Lecture du schéma SQLite impossible :"
                   << query.lastError().text();
        return false;
    }

    while (query.next()) {
        if (query.value(1).toString() == column) {
            return true;
        }
    }
    return false;
}

bool migrateMatchEventsToPositionCode(QSqlQuery& query) {
    if (!hasColumn(QStringLiteral("match_events"), QStringLiteral("position")) &&
        !hasColumn(QStringLiteral("match_events"), QStringLiteral("rod_index")) &&
        !hasColumn(QStringLiteral("match_events"), QStringLiteral("figure_index"))) {
        return true;
    }

    return execQuery(query, R"(
        CREATE TABLE match_events_clean (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            match_id INTEGER NOT NULL,
            player_id INTEGER NOT NULL,
            event_type TEXT NOT NULL,
            position_code INTEGER NOT NULL DEFAULT 1,
            FOREIGN KEY (match_id) REFERENCES matches(id),
            FOREIGN KEY (player_id) REFERENCES players(id),
            CHECK (event_type IN ('goal', 'own_goal', 'gamelle')),
            CHECK (position_code BETWEEN 1 AND 11)
        )
    )") &&
        execQuery(query, R"(
            INSERT INTO match_events_clean
                (id, match_id, player_id, event_type, position_code)
            SELECT id, match_id, player_id, event_type, position_code
            FROM match_events
        )") &&
        execQuery(query, QStringLiteral("DROP TABLE match_events")) &&
        execQuery(query, QStringLiteral(
            "ALTER TABLE match_events_clean RENAME TO match_events"
        ));
}

} // namespace

SqlitePlayerRepository::SqlitePlayerRepository(QString databasePath)
    : databasePath_{std::move(databasePath)} {}

void SqlitePlayerRepository::init() {
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

    QSqlQuery query{db};
    if (!execQuery(query, R"(
        CREATE TABLE IF NOT EXISTS players (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pseudo TEXT NOT NULL UNIQUE,
            mmr_1v1 INTEGER NOT NULL DEFAULT 1000,
            mmr_2v2 INTEGER NOT NULL DEFAULT 1000
        )
    )") ||
        !execQuery(query, R"(
        CREATE TABLE IF NOT EXISTS matches (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            format INTEGER NOT NULL,
            competitive INTEGER NOT NULL,
            team_a_score INTEGER NOT NULL,
            team_b_score INTEGER NOT NULL,
            played_at TEXT NOT NULL,
            CHECK (format IN (1, 2)),
            CHECK (competitive IN (0, 1))
        )
    )") ||
        !execQuery(query, R"(
        CREATE TABLE IF NOT EXISTS match_players (
            match_id INTEGER NOT NULL,
            player_id INTEGER NOT NULL,
            team INTEGER NOT NULL,
            won INTEGER NOT NULL,
            PRIMARY KEY (match_id, player_id),
            FOREIGN KEY (match_id) REFERENCES matches(id),
            FOREIGN KEY (player_id) REFERENCES players(id),
            CHECK (team IN (1, 2)),
            CHECK (won IN (0, 1))
        )
    )") ||
        !execQuery(query, R"(
        CREATE TABLE IF NOT EXISTS match_events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            match_id INTEGER NOT NULL,
            player_id INTEGER NOT NULL,
            event_type TEXT NOT NULL,
            position_code INTEGER NOT NULL,
            FOREIGN KEY (match_id) REFERENCES matches(id),
            FOREIGN KEY (player_id) REFERENCES players(id),
            CHECK (event_type IN ('goal', 'own_goal', 'gamelle')),
            CHECK (position_code BETWEEN 1 AND 11)
        )
    )") ||
        !execQuery(query, R"(
        CREATE INDEX IF NOT EXISTS idx_match_events_player_match
        ON match_events(player_id, match_id)
    )") ||
        !execQuery(query, R"(
        CREATE INDEX IF NOT EXISTS idx_match_events_match_type
        ON match_events(match_id, event_type)
    )") ||
        !execQuery(query, R"(
        CREATE INDEX IF NOT EXISTS idx_match_events_player_position
        ON match_events(player_id, event_type, position_code)
    )") ||
        !execQuery(query, R"(
        CREATE INDEX IF NOT EXISTS idx_matches_mode
        ON matches(format, competitive)
    )") ||
        !execQuery(query, R"(
        CREATE INDEX IF NOT EXISTS idx_match_players_player_match
        ON match_players(player_id, match_id)
    )")) {
        qFatal("Impossible de créer le schéma historique SQLite.");
    }

    if (!hasColumn(QStringLiteral("match_events"),
                   QStringLiteral("position_code")) &&
        !execQuery(query, QStringLiteral(
            "ALTER TABLE match_events ADD COLUMN position_code "
            "INTEGER NOT NULL DEFAULT 1"
        ))) {
        qFatal("Impossible de migrer les positions des joueurs plastiques.");
    }
    if (!migrateMatchEventsToPositionCode(query)) {
        qFatal("Impossible de supprimer les anciennes colonnes de position.");
    }
    if (!execQuery(query, R"(
        CREATE INDEX IF NOT EXISTS idx_match_events_player_match
        ON match_events(player_id, match_id)
    )") ||
        !execQuery(query, R"(
        CREATE INDEX IF NOT EXISTS idx_match_events_match_type
        ON match_events(match_id, event_type)
    )") ||
        !execQuery(query, R"(
        CREATE INDEX IF NOT EXISTS idx_match_events_player_position
        ON match_events(player_id, event_type, position_code)
    )")) {
        qFatal("Impossible de recréer les index des événements.");
    }

    if (!hasColumn(QStringLiteral("players"), QStringLiteral("mmr_1v1")) &&
        !execQuery(query, QStringLiteral(
            "ALTER TABLE players ADD COLUMN mmr_1v1 INTEGER NOT NULL DEFAULT 1000"
        ))) {
        qFatal("Impossible d'ajouter le MMR 1v1.");
    }
    if (!hasColumn(QStringLiteral("players"), QStringLiteral("mmr_2v2")) &&
        !execQuery(query, QStringLiteral(
            "ALTER TABLE players ADD COLUMN mmr_2v2 INTEGER NOT NULL DEFAULT 1000"
        ))) {
        qFatal("Impossible d'ajouter le MMR 2v2.");
    }
}

std::vector<babyfoot::core::Player>
SqlitePlayerRepository::getAll(babyfoot::core::GameMode mode) {
    std::vector<babyfoot::core::Player> players;

    QSqlQuery query;
    query.prepare(QStringLiteral(R"(
        SELECT
            p.id,
            p.pseudo,
            p.mmr_1v1,
            p.mmr_2v2,
            COALESCE((
                SELECT COUNT(*)
                FROM match_events e
                JOIN matches m ON m.id = e.match_id
                WHERE e.player_id = p.id
                  AND e.event_type = 'goal'
                  AND m.format = :format
                  AND m.competitive = :competitive
            ), 0) AS goals,
            COALESCE((
                SELECT COUNT(*)
                FROM match_events e
                JOIN matches m ON m.id = e.match_id
                WHERE e.player_id = p.id
                  AND e.event_type = 'own_goal'
                  AND m.format = :format
                  AND m.competitive = :competitive
            ), 0) AS own_goals,
            COALESCE((
                SELECT COUNT(*)
                FROM match_events e
                JOIN matches m ON m.id = e.match_id
                WHERE e.player_id = p.id
                  AND e.event_type = 'gamelle'
                  AND m.format = :format
                  AND m.competitive = :competitive
            ), 0) AS gamelles,
            COALESCE((
                SELECT COUNT(*)
                FROM match_players mp
                JOIN matches m ON m.id = mp.match_id
                WHERE mp.player_id = p.id
                  AND mp.won = 1
                  AND m.format = :format
                  AND m.competitive = :competitive
            ), 0) AS wins,
            COALESCE((
                SELECT COUNT(*)
                FROM match_players mp
                JOIN matches m ON m.id = mp.match_id
                WHERE mp.player_id = p.id
                  AND mp.won = 0
                  AND m.format = :format
                  AND m.competitive = :competitive
            ), 0) AS losses
        FROM players p
        ORDER BY p.pseudo
    )"));
    query.bindValue(QStringLiteral(":format"), mode.format);
    query.bindValue(QStringLiteral(":competitive"), mode.competitive ? 1 : 0);

    if (!query.exec()) {
        qWarning() << "Lecture des statistiques impossible :"
                   << query.lastError().text();
        return players;
    }

    while (query.next()) {
        babyfoot::core::Player player;
        player.id = query.value(0).toInt();
        player.pseudo = query.value(1).toString();
        player.mmr_1v1 = query.value(2).toInt();
        player.mmr_2v2 = query.value(3).toInt();
        player.stats.competitive = mode.competitive;
        player.stats.mmr = mode.format == 1 ? player.mmr_1v1 : player.mmr_2v2;
        player.stats.buts_marques = query.value(4).toInt();
        player.stats.csc = query.value(5).toInt();
        player.stats.gamelles = query.value(6).toInt();
        player.stats.victoires = query.value(7).toInt();
        player.stats.defaites = query.value(8).toInt();
        players.push_back(std::move(player));
    }

    return players;
}

babyfoot::core::Player SqlitePlayerRepository::add(const QString& pseudo) {
    QSqlQuery query;
    query.prepare(QStringLiteral(
        "INSERT INTO players (pseudo) VALUES (:pseudo)"
    ));
    query.bindValue(QStringLiteral(":pseudo"), pseudo);

    if (!query.exec()) {
        qWarning() << "Insertion impossible :" << query.lastError().text();
        return {};
    }

    return {
        .id = query.lastInsertId().toInt(),
        .pseudo = pseudo
    };
}

bool SqlitePlayerRepository::recordMatch(
    const babyfoot::core::MatchRecord& match) {
    QSqlDatabase db = QSqlDatabase::database();
    if (!db.transaction()) {
        qWarning() << "Impossible de démarrer la transaction du match :"
                   << db.lastError().text();
        return false;
    }

    QSqlQuery query{db};
    query.prepare(QStringLiteral(R"(
        INSERT INTO matches
            (format, competitive, team_a_score, team_b_score, played_at)
        VALUES (:format, :competitive, :team_a_score, :team_b_score, :played_at)
    )"));
    query.bindValue(QStringLiteral(":format"), match.mode.format);
    query.bindValue(QStringLiteral(":competitive"), match.mode.competitive ? 1 : 0);
    query.bindValue(QStringLiteral(":team_a_score"), match.teamAScore);
    query.bindValue(QStringLiteral(":team_b_score"), match.teamBScore);
    query.bindValue(QStringLiteral(":played_at"), QDateTime::currentDateTimeUtc());
    if (!query.exec()) {
        qWarning() << "Enregistrement du match impossible :"
                   << query.lastError().text();
        db.rollback();
        return false;
    }
    const int matchId = query.lastInsertId().toInt();

    std::map<QString, int> playerIds;
    query.prepare(QStringLiteral("SELECT id, pseudo FROM players"));
    if (!query.exec()) {
        qWarning() << "Lecture des players impossible :" << query.lastError().text();
        db.rollback();
        return false;
    }
    while (query.next()) {
        playerIds.emplace(query.value(1).toString(), query.value(0).toInt());
    }

    for (const auto& participant : match.participants) {
        const auto playerIt = playerIds.find(participant.pseudo);
        if (playerIt == playerIds.end() ||
            (participant.team != 1 && participant.team != 2)) {
            qWarning() << "Participant invalide :" << participant.pseudo;
            db.rollback();
            return false;
        }

        query.prepare(QStringLiteral(R"(
            INSERT INTO match_players (match_id, player_id, team, won)
            VALUES (:match_id, :player_id, :team, :won)
        )"));
        query.bindValue(QStringLiteral(":match_id"), matchId);
        query.bindValue(QStringLiteral(":player_id"), playerIt->second);
        query.bindValue(QStringLiteral(":team"), participant.team);
        query.bindValue(QStringLiteral(":won"), participant.won ? 1 : 0);
        if (!query.exec()) {
            qWarning() << "Participant non enregistré :" << query.lastError().text();
            db.rollback();
            return false;
        }
    }

    for (const auto& event : match.events) {
        const auto playerIt = playerIds.find(event.pseudo);
        if (playerIt == playerIds.end() ||
            (event.type != QStringLiteral("goal") &&
             event.type != QStringLiteral("own_goal") &&
             event.type != QStringLiteral("gamelle"))) {
            qWarning() << "Événement invalide pour :" << event.pseudo;
            db.rollback();
            return false;
        }

        query.prepare(QStringLiteral(R"(
            INSERT INTO match_events
                (match_id, player_id, event_type, position_code)
            VALUES
                (:match_id, :player_id, :event_type, :position_code)
        )"));
        query.bindValue(QStringLiteral(":match_id"), matchId);
        query.bindValue(QStringLiteral(":player_id"), playerIt->second);
        query.bindValue(QStringLiteral(":event_type"), event.type);
        query.bindValue(QStringLiteral(":position_code"), event.positionCode);
        if (!query.exec()) {
            qWarning() << "Événement non enregistré :" << query.lastError().text();
            db.rollback();
            return false;
        }
    }

    if (!db.commit()) {
        qWarning() << "Validation du match impossible :" << db.lastError().text();
        db.rollback();
        return false;
    }
    return true;
}

std::vector<int> SqlitePlayerRepository::getEventCounts(
    int playerId, babyfoot::core::GameMode mode, const QString& eventType) {
    std::vector<int> counts(12, 0);
    QSqlQuery query;
    query.prepare(QStringLiteral(R"(
        SELECT e.position_code, COUNT(*)
        FROM match_events e
        JOIN matches m ON m.id = e.match_id
        WHERE e.player_id = :player_id
          AND e.event_type = :event_type
          AND m.format = :format
          AND m.competitive = :competitive
        GROUP BY e.position_code
    )"));
    query.bindValue(QStringLiteral(":player_id"), playerId);
    query.bindValue(QStringLiteral(":event_type"), eventType);
    query.bindValue(QStringLiteral(":format"), mode.format);
    query.bindValue(QStringLiteral(":competitive"), mode.competitive ? 1 : 0);
    if (!query.exec()) {
        qWarning() << "Lecture des détails de statistiques impossible :"
                   << query.lastError().text();
        return counts;
    }
    while (query.next()) {
        const int position = query.value(0).toInt();
        if (position >= 1 && position <= 11) {
            counts[position] = query.value(1).toInt();
        }
    }
    return counts;
}

} // namespace babyfoot::infra
