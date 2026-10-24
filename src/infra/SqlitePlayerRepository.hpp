#pragma once

#include "core/PlayerService.hpp"
#include <QString>
namespace babyfoot::infra {

class SqlitePlayerRepository final : public babyfoot::core::IPlayerRepository {
public:
    explicit SqlitePlayerRepository(QString databasePath);

    void init() override;
    std::vector<babyfoot::core::Player> getAll() override; // vecteur des joueurs existants
    babyfoot::core::Player add(const QString& pseudo) override; // ajouter un joueur au vecteur

private:
    QString databasePath_;
};

}