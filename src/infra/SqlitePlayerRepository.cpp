#include "infra/SqlitePlayerRepository.hpp"

#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QVariant>
#include <QDebug>
#include <cstdio>
#include <string>
#include <QString>


using namespace std;

namespace babyfoot::infra {

    

SqlitePlayerRepository::SqlitePlayerRepository(QString databasePath)
    : databasePath_{move(databasePath)} {}

// initialisation de la base de donnée SQLite
void SqlitePlayerRepository::init() {
    auto db = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"));
    db.setDatabaseName(databasePath_);

    if (!db.open()) {
        qFatal("Impossible d'ouvrir la base SQLite : %s",
               qPrintable(db.lastError().text()));
    }

    QSqlQuery query{db};

    query.exec(R"(
        CREATE TABLE IF NOT EXISTS players (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pseudo TEXT NOT NULL UNIQUE
        )
    )");
}

// récupérer un vecteur de tous les joueurs
vector<babyfoot::core::Player> SqlitePlayerRepository::getAll() {
    vector<babyfoot::core::Player> players; //vecteur de retour

    QSqlQuery query{
        QStringLiteral("SELECT id, pseudo FROM players ORDER BY pseudo")
    };

    while (query.next()) {
        players.push_back({
            .id = query.value(0).toInt(),
            .pseudo = query.value(1).toString()
        });
    }

    return players;
}

// ajouter un joueur au vecteur existant
babyfoot::core::Player SqlitePlayerRepository::add(const QString& pseudo) {
    if (pseudo == QString::fromStdString("Matias")) {
        qDebug() << "hello matias"; 
    }

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

}