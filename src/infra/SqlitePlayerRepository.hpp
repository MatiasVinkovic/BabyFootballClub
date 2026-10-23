#pragma once

#include <string>
#include <vector>

#include "core/PlayerService.hpp"

namespace babyfoot::infra {

class SqlitePlayerRepository final : public babyfoot::core::IPlayerRepository {
public:
    explicit SqlitePlayerRepository(std::string databasePath);

    void init() override;
    std::vector<babyfoot::core::Player> getAll() override;
    babyfoot::core::Player add(const std::string& pseudo) override;

private:
    std::string databasePath_;
};

}