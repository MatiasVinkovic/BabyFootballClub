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

    service_.addPlayer(pseudo.trimmed());
    refreshPlayers();
}

void AppController::selectPlayer(const QString& pseudo) {
    for (const auto& player : service_.players()) {
        if (player.pseudo != pseudo) {
            continue;
        }

        selectedPlayer_ = {
            {QStringLiteral("pseudo"), player.pseudo},
            {QStringLiteral("mmr"), player.MMR},
            {QStringLiteral("rank"), babyfoot::core::toString(player.rank())},
            {QStringLiteral("goals"), player.buts_marques},
            {QStringLiteral("ownGoals"), player.csc},
            {QStringLiteral("usefulGoals"), player.butsUtiles()},
            {QStringLiteral("wins"), player.victoires},
            {QStringLiteral("losses"), player.defaites},
            {QStringLiteral("matchesPlayed"), player.matchsJoues()}
        };
        emit selectedPlayerChanged();
        return;
    }
}

void AppController::incrementCounter() {
    ++counter_;
    emit counterChanged();
}

void AppController::refreshPlayers() {
    players_.clear();

    for (const auto& player : service_.players()) {
        players_.append(player.pseudo);
    }

    emit playersChanged();
}

}