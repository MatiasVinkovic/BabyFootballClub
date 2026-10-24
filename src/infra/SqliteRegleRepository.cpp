#include "infra/SqliteRegleRepository.hpp"

#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QVariant>
#include <QDebug>
#include <QString>

namespace babyfoot::infra {

// Le constructeur qui manquait
SqliteRegleRepository::SqliteRegleRepository(QString databasePath)
    : databasePath_{std::move(databasePath)} {}

void SqliteRegleRepository::init() {
    auto db = QSqlDatabase::database();

    if (!db.isOpen() && !db.open()) {
        qFatal("Impossible d'ouvrir la base SQLite : %s",
               qPrintable(db.lastError().text()));
    }

    QSqlQuery query{db};
    query.exec(R"(
        CREATE TABLE IF NOT EXISTS rules(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            titre TEXT NOT NULL UNIQUE, 
            contenu TEXT NOT NULL
        )
    )");
}

babyfoot::core::Regle SqliteRegleRepository::add(const std::string& titre, const std::string& contenu) {
    QSqlQuery query;
    query.prepare(QStringLiteral("INSERT INTO rules (titre, contenu) VALUES (:titre, :contenu)"));
    query.bindValue(QStringLiteral(":titre"), QString::fromStdString(titre));
    query.bindValue(QStringLiteral(":contenu"), QString::fromStdString(contenu));

    if (!query.exec()) {
        qWarning() << "Insertion de regle impossible :" << query.lastError().text();
        return {};
    }

    return {
        .id = query.lastInsertId().toInt(),
        .titre = titre,
        .contenu = contenu
    };
}

std::vector<babyfoot::core::Regle> SqliteRegleRepository::getAll() {
    std::vector<babyfoot::core::Regle> rules;

    QSqlQuery query{
        QStringLiteral("SELECT id, titre, contenu FROM rules ORDER BY id")
    };

    while (query.next()) {
        rules.push_back({
            .id = query.value(0).toInt(),
            .titre = query.value(1).toString().toStdString(),
            .contenu = query.value(2).toString().toStdString()
        });
    }

    return rules;
}

}