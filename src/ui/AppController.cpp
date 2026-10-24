#include "ui/AppController.hpp"

namespace babyfoot::ui {

AppController::AppController(babyfoot::core::PlayerService& playerService,
                             babyfoot::core::RegleService& regleService,
                             QObject* parent)
    : QObject{parent},
      playerService_{playerService},
      regleService_{regleService} {
    refreshPlayers();
    refreshRegles();
}

QStringList AppController::players() const {
    return players_;
}

QVariantList AppController::regles() const {
    return regles_;
}

void AppController::addPlayer(const QString& pseudo) {
    if (pseudo.trimmed().isEmpty()) {
        return;
    }

    // playerService_.addPlayer attend déjà un QString !
    playerService_.addPlayer(pseudo.trimmed());
    refreshPlayers();
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
    for (const auto& player : playerService_.players()) {
        // player.pseudo est déjà un QString !
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
    for (const auto& player : playerService_.players()) {
        // player.pseudo est déjà un QString, pas besoin de covnersion donc
        players_.append(player.pseudo);
    }
    emit playersChanged();
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