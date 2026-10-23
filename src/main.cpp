#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

#include "core/PlayerService.hpp"
#include "infra/SqlitePlayerRepository.hpp"
#include "ui/AppController.hpp"

int main(int argc, char** argv) {
    QGuiApplication app{argc, argv};

    QQuickStyle::setStyle(QStringLiteral("Basic"));

    const QString databasePath =
        QGuiApplication::applicationDirPath() + "/babyfoot.db";

    babyfoot::infra::SqlitePlayerRepository repository{
        databasePath.toStdString()
    };

    babyfoot::core::PlayerService playerService{repository};
    playerService.initialize();

    if (playerService.players().empty()) {
        playerService.addPlayer("Alice");
        playerService.addPlayer("Bob");
    }

    babyfoot::ui::AppController controller{playerService};

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