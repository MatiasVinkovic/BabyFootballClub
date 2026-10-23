#pragma once

#include <QString>
#include <algorithm>

namespace babyfoot::core {

enum class Rank {
    Unranked,
    Bronze,
    Silver,
    Gold,
    Platine,
    Diamant,
    Champion,
    GrandChampion,
    SSL
};

enum class Tier { None, I, II, III };

struct PlayerRank {
    Rank rank = Rank::Unranked;
    Tier tier = Tier::None;
};

namespace rank_config {
    inline constexpr float kSslThreshold   = 1900.0f;
    inline constexpr int   kRankedRanks    = 7;   // Bronze -> GrandChampion
    inline constexpr int   kTiersPerRank   = 3;
    inline constexpr int   kTierCount      = kRankedRanks * kTiersPerRank; // 21
    inline constexpr float kTierWidth      = 80.0f;
    inline constexpr float kFirstThreshold = kSslThreshold - kTierCount * kTierWidth; // 220
}

// Convertit un MMR en rang. Pour un joueur sans match, voir Player::rank().
constexpr PlayerRank rankFromMMR(float mmr) {
    using namespace rank_config;

    if (mmr != mmr)            return { Rank::Bronze, Tier::I };  // NaN : valeur de secours
    if (mmr >= kSslThreshold)  return { Rank::SSL, Tier::None };
    if (mmr < kFirstThreshold) return { Rank::Bronze, Tier::I };

    int index = static_cast<int>((mmr - kFirstThreshold) / kTierWidth); // 0..20
    index = std::clamp(index, 0, kTierCount - 1); // protège des erreurs d'arrondi flottant

    return {
        static_cast<Rank>(1 + index / kTiersPerRank),
        static_cast<Tier>(1 + index % kTiersPerRank)
    };
}

// Vérifications à la compilation : si tu changes les constantes, ça casse tout de suite
static_assert(rankFromMMR(-50.f).rank   == Rank::Bronze);
static_assert(rankFromMMR(220.f).tier   == Tier::I);
static_assert(rankFromMMR(1000.f).rank  == Rank::Platine);
static_assert(rankFromMMR(1899.99f).rank == Rank::GrandChampion);
static_assert(rankFromMMR(1899.99f).tier == Tier::III);
static_assert(rankFromMMR(1900.f).rank  == Rank::SSL);
static_assert(rankFromMMR(5000.f).rank  == Rank::SSL);

inline QString toString(Rank r) {
    switch (r) {
        case Rank::Unranked:      return "Unranked";
        case Rank::Bronze:        return "Bronze";
        case Rank::Silver:        return "Silver";
        case Rank::Gold:          return "Gold";
        case Rank::Platine:       return "Platine";
        case Rank::Diamant:       return "Diamant";
        case Rank::Champion:      return "Champion";
        case Rank::GrandChampion: return "Grand Champion";
        case Rank::SSL:           return "SSL";
    }
    return "Unknown";
}

inline QString toString(Tier t) {
    switch (t) {
        case Tier::None: return "";
        case Tier::I:    return "I";
        case Tier::II:   return "II";
        case Tier::III:  return "III";
    }
    return "";
}

inline QString toString(const PlayerRank& pr) {
    return pr.tier == Tier::None ? toString(pr.rank)
                                 : toString(pr.rank) + " " + toString(pr.tier);
}

} // namespace babyfoot::core