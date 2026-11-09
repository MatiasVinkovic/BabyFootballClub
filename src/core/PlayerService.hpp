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
    virtual std::vector<Player> getAll(GameMode mode) = 0;
    virtual Player add(const QString& pseudo) = 0; // ajouter un joueur dans la liste
    virtual bool recordMatch(const MatchRecord& match) = 0;
    virtual std::vector<int> getEventCounts(int playerId, GameMode mode,
                                             const QString& eventType) = 0;
};

class PlayerService {
    public:
        explicit PlayerService(IPlayerRepository& repository)
            : repository_{repository} {}

        void initialize() {
            repository_.init();
        }

        std::vector<Player> players(GameMode mode = {}) const {
            return const_cast<IPlayerRepository&>(repository_).getAll(mode);
        }

        Player addPlayer(const QString& pseudo) {
            return repository_.add(pseudo);
        }

        bool recordMatch(const MatchRecord& match) {
            return repository_.recordMatch(match);
        }

        std::vector<int> eventCounts(int playerId, GameMode mode,
                                     const QString& eventType) {
            return repository_.getEventCounts(playerId, mode, eventType);
        }

    private:
        IPlayerRepository& repository_;


        
    };

}