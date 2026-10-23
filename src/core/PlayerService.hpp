#pragma once

#include <string>
#include <vector>

#include "core/Player.hpp"

namespace babyfoot::core {

class IPlayerRepository {
public:
    virtual ~IPlayerRepository() = default;

    virtual void init() = 0;
    virtual std::vector<Player> getAll() = 0;
    virtual Player add(const std::string& pseudo) = 0;
};

class PlayerService {
public:
    explicit PlayerService(IPlayerRepository& repository)
        : repository_{repository} {}

    void initialize() {
        repository_.init();
    }

    std::vector<Player> players()  {
        return repository_.getAll();
    }

    Player addPlayer(const std::string& pseudo) {
        return repository_.add(pseudo);
    }

private:
    IPlayerRepository& repository_;
};

}