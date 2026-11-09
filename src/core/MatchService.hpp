#pragma once

#include "core/Match.hpp"

namespace babyfoot::core {

class IMatchRepository {
public:
    virtual ~IMatchRepository() = default;
    virtual void init() = 0;
    virtual std::vector<MatchHistoryEntry> history() = 0;
    virtual MatchHistoryEntry find(int matchId) = 0;
};

class MatchService {
public:
    explicit MatchService(IMatchRepository& repository)
        : repository_{repository} {}

    void initialize() {
        repository_.init();
    }

    std::vector<MatchHistoryEntry> history() {
        return repository_.history();
    }

    MatchHistoryEntry match(int matchId) {
        return repository_.find(matchId);
    }

private:
    IMatchRepository& repository_;
};

} // namespace babyfoot::core
