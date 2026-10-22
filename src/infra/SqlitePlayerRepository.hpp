#pragma once

#include "core/PlayerService.hpp"

namespace babyfoot::infra {

class SqlitePlayerRepository final : public babyfoot::core::IPlayerRepository {
public:
    explicit SqlitePlayerRepository(QString databasePath);

    void init() override;
    std::vector<babyfoot::core::Player> getAll() override;
    babyfoot::core::Player add(const QString& pseudo) override;

private:
    QString databasePath_;
};

}