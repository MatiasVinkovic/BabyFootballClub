#pragma once

#include <QString>

namespace babyfoot::core {

enum class Rank {
    Bronze, 
    Argent,
    Or,
    Platine,
    Diamant,
    GuepardSupreme,
};

enum class Tier { None, I, II, III };

struct PlayerRank {
    Rank rank = Rank::Bronze;
    Tier tier = Tier::III;
};

constexpr PlayerRank rankFromMMR(float mmr) {
    // Sécurité si le mmr est un NaN
    if (mmr != mmr) return { Rank::Bronze, Tier::III }; 

    // Les paliers n'étant plus linéaires, une simple descente conditionnelle 
    // est la solution la plus lisible, performante et 100% constexpr.
    if (mmr >= 2000.0f) return { Rank::GuepardSupreme, Tier::None };

    if (mmr >= 1500.0f) return { Rank::Diamant, Tier::I };
    if (mmr >= 1300.0f) return { Rank::Diamant, Tier::II };
    if (mmr >= 1200.0f) return { Rank::Diamant, Tier::III };

    if (mmr >= 1000.0f) return { Rank::Platine, Tier::I };
    if (mmr >= 850.0f) return { Rank::Platine, Tier::II };
    if (mmr >= 800.0f) return { Rank::Platine, Tier::III };

    if (mmr >= 600.0f) return { Rank::Or, Tier::I };
    if (mmr >= 550.0f) return { Rank::Or, Tier::II };
    if (mmr >= 500.0f) return { Rank::Or, Tier::III };

    if (mmr >= 400.0f) return { Rank::Argent, Tier::I };
    if (mmr >= 350.0f) return { Rank::Argent, Tier::II }; // Correction de la coquille (4 -> II)
    if (mmr >= 300.0f) return { Rank::Argent, Tier::III }; // Correction de la coquille (5 -> III)

    if (mmr >= 200.0f) return { Rank::Bronze, Tier::I };
    if (mmr >= 150.0f) return { Rank::Bronze, Tier::II };

    // Tout ce qui est en dessous de 150 (dont le palier à 100)
    return { Rank::Bronze, Tier::III }; 
}

inline QString toString(Rank r) {
    switch (r) {
        case Rank::Bronze:         return "Bronze";
        case Rank::Argent:         return "Argent";
        case Rank::Or:             return "Or";
        case Rank::Platine:        return "Platine";
        case Rank::Diamant:        return "Diamant";
        case Rank::GuepardSupreme: return "Guépard Suprême";
    }
    return "Inconnu";
}

inline QString rankIconUrl(Rank r) {
    switch (r) {
        case Rank::Bronze:         return "qrc:/qt/qml/Babyfoot/icons/bronze.png";
        case Rank::Argent:         return "qrc:/qt/qml/Babyfoot/icons/argent.png";
        case Rank::Or:             return "qrc:/qt/qml/Babyfoot/icons/or.png";
        case Rank::Platine:        return "qrc:/qt/qml/Babyfoot/icons/platine.png";
        case Rank::Diamant:        return "qrc:/qt/qml/Babyfoot/icons/diamant.png";
        case Rank::GuepardSupreme: return "qrc:/qt/qml/Babyfoot/icons/guepard_supreme.png";
    }
    return {};
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