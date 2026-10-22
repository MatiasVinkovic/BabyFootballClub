#pragma once

#include <QString>

// classe qui représente l'état atomique du joueur, son instance

namespace babyfoot::core {

struct Player {
    int id = 0;
    QString pseudo;
};

}