#pragma once

#include <algorithm>
#include <cmath>
#include <optional>
#include <vector>

namespace babyfoot::core {

struct MmrConfig {
    double k = 32.0;
    double d = 400.0;
    double scale = 3.0;            // amplification globale
    double minTeamGain = 6.0;      // plancher du gain total des gagnants (match de 5 points)
    double beta = 0.6;             // 0 = niveau d'équipe, 1 = niveau individuel
    double marginDamping = 2.2;
    double referenceScore = 5.0;   // l'écart de buts est ramené à un match en 5 points
    int minMmr = 0;
};

struct MmrParticipant {
    int playerId = 0;
    int team = 0;                  // 1 ou 2
    int mmr = 1000;
};

struct MmrMatch {
    std::vector<MmrParticipant> participants;
    int winningTeam = 0;           // 1 ou 2
    int scoreA = 0;
    int scoreB = 0;
    int winningScore = 5;          // 3 ou 5 en compétitif
};

struct MmrChange {
    int playerId = 0;
    int delta = 0;
    int newMmr = 0;
};

class MMRService {
public:
    explicit MMRService(MmrConfig config = {}) : config_{config} {}

    double expected(double ratingA, double ratingB) const {
        return 1.0 / (1.0 + std::pow(10.0, (ratingB - ratingA) / config_.d));
    }

    // Un match court rapporte moins qu'un match long.
    double lengthFactor(int winningScore) const {
        if (winningScore >= 5) return 1.0;
        if (winningScore >= 3) return 0.6;
        return 0.4;
    }

    double marginMultiplier(int margin, int winningScore, double advantage) const {
        const double normalized = margin * config_.referenceScore / winningScore;
        const double adv = std::max(0.0, advantage);
        return std::log(normalized + 1.0)
             * (config_.marginDamping / (0.001 * adv + config_.marginDamping));
    }

    // Retourne nullopt si le match est incohérent.
    std::optional<std::vector<MmrChange>> computeChanges(const MmrMatch& match) const {
        const int winner = match.winningTeam;
        if (winner != 1 && winner != 2) return std::nullopt;

        const int winnerScore = winner == 1 ? match.scoreA : match.scoreB;
        const int loserScore  = winner == 1 ? match.scoreB : match.scoreA;
        if (match.winningScore <= 0 || winnerScore != match.winningScore ||
            loserScore < 0 || loserScore >= match.winningScore) {
            return std::nullopt;
        }

        double sum[3] = {0.0, 0.0, 0.0};
        int count[3] = {0, 0, 0};
        for (const auto& p : match.participants) {
            if (p.team != 1 && p.team != 2) return std::nullopt;
            sum[p.team] += p.mmr;
            ++count[p.team];
        }
        if (count[1] == 0 || count[2] == 0) return std::nullopt;

        const double avg[3] = {0.0, sum[1] / count[1], sum[2] / count[2]};
        const int loser = winner == 1 ? 2 : 1;

        const double length = lengthFactor(match.winningScore);
        const double multiplier =
            marginMultiplier(winnerScore - loserScore, match.winningScore,
                             avg[winner] - avg[loser]) * length;

        std::vector<double> deltas;
        deltas.reserve(match.participants.size());
        double winnersTotal = 0.0;

        for (const auto& p : match.participants) {
            const double own = avg[p.team];
            const double opp = avg[p.team == 1 ? 2 : 1];
            const bool won = p.team == winner;

            const double effective = config_.beta * expected(p.mmr, opp)
                                   + (1.0 - config_.beta) * expected(own, opp);
            const double delta = config_.k * multiplier
                               * ((won ? 1.0 : 0.0) - effective) * config_.scale;
            deltas.push_back(delta);
            if (won) winnersTotal += delta;
        }

        // Plancher appliqué UNIQUEMENT aux gagnants (voir remarque plus bas).
        const double floorGain = config_.minTeamGain * length;
        if (winnersTotal > 0.0 && winnersTotal < floorGain) {
            const double correction = floorGain / winnersTotal;
            for (std::size_t i = 0; i < deltas.size(); ++i) {
                if (match.participants[i].team == winner) deltas[i] *= correction;
            }
        }

        std::vector<MmrChange> changes;
        changes.reserve(deltas.size());
        for (std::size_t i = 0; i < deltas.size(); ++i) {
            const auto& p = match.participants[i];
            const int updated = std::max(config_.minMmr,
                static_cast<int>(std::lround(p.mmr + deltas[i])));
            changes.push_back({.playerId = p.playerId,
                               .delta = updated - p.mmr,
                               .newMmr = updated});
        }
        return changes;
    }

private:
    MmrConfig config_;
};

} // namespace babyfoot::core