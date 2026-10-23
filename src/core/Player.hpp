#pragma once


#include <string>

// classe qui représente l'état atomique du joueur, son instance

namespace babyfoot::core {

struct Player {
    int id = 0;
     std::string pseudo;
};

}