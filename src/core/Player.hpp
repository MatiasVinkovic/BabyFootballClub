#pragma once

#include <QString>
#include "Rank.h"

namespace babyfoot::core {

struct Player {
    int id = 0;
    QString pseudo;
    float MMR = 1000;

    int buts_marques = 0;
    int csc = 0;
    int victoires = 0;
    int defaites = 0;

    int matchsJoues() const { return victoires + defaites; }

    int butsUtiles() const { return buts_marques - csc; }

    PlayerRank rank() const {
        if (victoires + defaites == 0)
            return { Rank::Unranked, Tier::None };
        return rankFromMMR(MMR);
    }
};

} // namespace babyfoot::core