#pragma once

#include <QString>
#include <vector>

#include "core/Player.hpp"

// classe qui fait la partie gestion des joueurs

namespace babyfoot::core {

// interface (full virtual)
class IPlayerRepository {
public:
    virtual ~IPlayerRepository() = default;

    virtual void init() = 0; // obligé à réaliser une implémentation complète
    virtual std::vector<Player> getAll() = 0; // liste des joueurs existant
    virtual Player add(const QString& pseudo) = 0; // ajouter un joueur dans la liste
};

class PlayerService {
public:
    explicit PlayerService(IPlayerRepository& repository)
        : repository_{repository} {}

    void initialize() {
        repository_.init();
    }

    std::vector<Player> players() const {
        return const_cast<IPlayerRepository&>(repository_).getAll();
    }

    Player addPlayer(const QString& pseudo) {
        return repository_.add(pseudo);
    }

private:
    IPlayerRepository& repository_;
};

}