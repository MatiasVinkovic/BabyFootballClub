#pragma once


#include <string>
using namespace std;
// classe qui représente l'état atomique d'une regle, c'est à dire son nom et son contenu

namespace babyfoot::core {

struct Regle {
    int id = 0;
    string titre;
    string contenu;
};

}