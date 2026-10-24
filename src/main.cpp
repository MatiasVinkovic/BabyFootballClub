#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

#include "core/PlayerService.hpp"
#include "core/RegleService.hpp"
#include "infra/SqlitePlayerRepository.hpp"
#include "infra/SqliteRegleRepository.hpp"

#include "ui/AppController.hpp"

int main(int argc, char** argv) {
    QGuiApplication app{argc, argv};

    QQuickStyle::setStyle(QStringLiteral("Basic"));

    const QString databasePath =
        QGuiApplication::applicationDirPath() + "/babyfoot.db";

    // objet repository, sur le meme database path
    babyfoot::infra::SqlitePlayerRepository repository{databasePath};
    babyfoot::infra::SqliteRegleRepository repository_regle{databasePath};

    //objets de gestion métiers des regles, et des joueurs
    babyfoot::core::PlayerService playerService{repository};
    babyfoot::core::RegleService regleService{repository_regle};

    playerService.initialize();
    regleService.initialize();

    // ajouter par défaut des joueurs
    if (playerService.players().empty()) {
        playerService.addPlayer(QStringLiteral("La gâchette"));
        playerService.addPlayer(QStringLiteral("Le Striker"));
        playerService.addPlayer(QStringLiteral("Le Guépard"));
        playerService.addPlayer(QStringLiteral("Le Maçon"));
        playerService.addPlayer(QStringLiteral("La Mouche"));
    }

    // faire le pont entre le UI(qml) et le cpp derrière
    babyfoot::ui::AppController controller{playerService, regleService};

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