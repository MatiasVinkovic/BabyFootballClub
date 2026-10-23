#include <iostream>
#include <string>
#include <vector>
using namespace std;
#include "core/Player.hpp"
#include "core/Regle.hpp"

int main() {
    vector<babyfoot::core::Regle> regles;

    regles.push_back({"Regle1", "blabla"});
    regles.push_back({"Regle2", "blabla numero 2"});

    for (const auto& regle : regles) {
        cout << regle.nom << "\n" << regle.contenu << '\n';
    }

    return 0;
}