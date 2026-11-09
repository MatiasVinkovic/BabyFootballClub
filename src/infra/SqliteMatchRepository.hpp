#pragma once

#include "core/MatchService.hpp"

#include <QString>

namespace babyfoot::infra {

class SqliteMatchRepository final : public babyfoot::core::IMatchRepository {
public:
    explicit SqliteMatchRepository(QString databasePath);

    void init() override;
    std::vector<babyfoot::core::MatchHistoryEntry> history() override;
    babyfoot::core::MatchHistoryEntry find(int matchId) override;

private:
    QString databasePath_;
};

} // namespace babyfoot::infra
