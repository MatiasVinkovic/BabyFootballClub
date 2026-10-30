#pragma once

#include <QString>
#include <QStringList>

#include "core/Player.hpp"

#include <vector>

namespace babyfoot::core {

struct MatchHistoryEntry {
    int id = 0;
    int format = 1;
    bool competitive = false;
    int teamAScore = 0;
    int teamBScore = 0;
    QString playedAt;
    QStringList participants;
    std::vector<MatchParticipant> participantDetails;
    std::vector<MatchEvent> events;
};

} // namespace babyfoot::core
