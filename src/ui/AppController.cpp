#include "ui/AppController.hpp"

namespace babyfoot::ui {

AppController::AppController(babyfoot::core::PlayerService& service,
                             QObject* parent)
    : QObject{parent}, service_{service} {
    refreshPlayers();
}

QStringList AppController::players() const {
    return players_;
}

void AppController::addPlayer(const QString& pseudo) {
    if (pseudo.trimmed().isEmpty()) {
        return;
    }

    service_.addPlayer(pseudo.trimmed().toStdString());
    refreshPlayers();
}

void AppController::incrementCounter() {
    ++counter_;
    emit counterChanged();
}

void AppController::refreshPlayers() {
    players_.clear();

    for (const auto& player : service_.players()) {
        players_.append(
            QString::fromStdString(player.pseudo)
        );
    }

    emit playersChanged();
}

}