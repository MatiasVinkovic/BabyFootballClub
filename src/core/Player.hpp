#pragma once

#include <QString>
#include <vector>
#include "Rank.h"

namespace babyfoot::core {

struct GameMode {
    int format = 1;
    bool competitive = false;
};

struct PlayerStats {
    bool competitive = false;
    int buts_marques = 0;
    int csc = 0;
    int gamelles = 0;
    int victoires = 0;
    int defaites = 0;
    int mmr = 100;

    int matchsJoues() const { return victoires + defaites; }
    int butsUtiles() const { return buts_marques - csc; }
};

struct MatchParticipant {
    QString pseudo;
    int team = 0;
    PlayerStats stats;
    bool won = false;
};

struct MatchEvent {
    QString pseudo;
    QString type;
    int positionCode = 0;
};

struct MatchRecord {
    GameMode mode;
    int winningScore = 5;      // <-- nouveau
    int teamAScore = 0;
    int teamBScore = 0;
    std::vector<MatchParticipant> participants;
    std::vector<MatchEvent> events;
};

struct Player {
    int id = 0;
    QString pseudo;
    int mmr_casual = 1000;
    int mmr_ranked = 1000;
    PlayerStats stats;

    PlayerRank rank() const {
        return rankFromMMR(stats.mmr);
    }
};

} // namespace babyfoot::core