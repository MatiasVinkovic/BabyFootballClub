#include <QGuiApplication>
#include <QDebug>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSqlError>
#include <QSqlQuery>
#include <QQuickStyle>

#include "core/PlayerService.hpp"
#include "core/RegleService.hpp"
#include "infra/SqlitePlayerRepository.hpp"
#include "infra/SqliteRegleRepository.hpp"
#include "infra/SqliteMatchRepository.hpp"

#include "ui/AppController.hpp"

int main(int argc, char** argv) {
    QGuiApplication app{argc, argv};

    QQuickStyle::setStyle(QStringLiteral("Basic"));

    const QString databasePath =
        QGuiApplication::applicationDirPath() + "/babyfoot.db";

    // objet repository, sur le meme database path
    babyfoot::infra::SqlitePlayerRepository repository{databasePath};
    babyfoot::infra::SqliteRegleRepository repository_regle{databasePath};
    babyfoot::infra::SqliteMatchRepository repository_match{databasePath};

    //objets de gestion métiers des regles, et des joueurs
    babyfoot::core::PlayerService playerService{repository};
    babyfoot::core::RegleService regleService{repository_regle};
    babyfoot::core::MatchService matchService{repository_match};

    playerService.initialize();
    regleService.initialize();
    matchService.initialize();

    struct TestPlayer {
        const char* pseudo;
        int mmr;
    };
    constexpr TestPlayer testPlayers[]{
        {"Test Bronze", 100},
        {"Test Argent", 400},
        {"Test Or", 600},
        {"Test Platine", 1000},
        {"Test Diamant", 1500},
        {"Test Guepard Supreme", 2000}
    };

    QSqlQuery seedPlayerQuery;
    seedPlayerQuery.prepare(QStringLiteral(
        "INSERT OR IGNORE INTO players (pseudo, mmr_ranked) "
        "VALUES (:pseudo, :mmr)"
    ));
    for (const auto& testPlayer : testPlayers) {
        seedPlayerQuery.bindValue(QStringLiteral(":pseudo"),
                                  QString::fromLatin1(testPlayer.pseudo));
        seedPlayerQuery.bindValue(QStringLiteral(":mmr"), testPlayer.mmr);
        if (!seedPlayerQuery.exec()) {
            qWarning() << "Insertion du joueur de test impossible :"
                       << seedPlayerQuery.lastError().text();
        }
    }


    // faire le pont entre le UI(qml) et le cpp derrière
    babyfoot::ui::AppController controller{
        playerService, regleService, matchService
    };

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(
        QStringLiteral("appController"), &controller
    );

    const QUrl url{QStringLiteral("qrc:/qt/qml/Babyfoot/src/ui/Main.qml")};

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(1); },
        Qt::QueuedConnection
    );

    engine.load(url);

    return app.exec();
}