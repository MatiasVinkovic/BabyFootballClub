#pragma once

#include "core/PlayerService.hpp"
#include <QString>
namespace babyfoot::infra {

class SqlitePlayerRepository final : public babyfoot::core::IPlayerRepository {
public:
    explicit SqlitePlayerRepository(QString databasePath);

    void init() override;
    std::vector<babyfoot::core::Player> getAll(babyfoot::core::GameMode mode) override;
    babyfoot::core::Player add(const QString& pseudo) override; // ajouter un joueur au vecteur
    bool recordMatch(const babyfoot::core::MatchRecord& match) override;
    std::vector<int> getEventCounts(int playerId, babyfoot::core::GameMode mode,
                                    const QString& eventType) override;

private:
    QString databasePath_;
};

}