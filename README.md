# BabyFootballClub
Un pour tous tous pour un baby

comment compiler le projet en fonction de la plateforme : 

# 1. Configurer
cmake -B build -S .

# 2. Compiler
cmake --build build

# 3. Lancer
# Sur Linux / Mac :
./build/babyfoot-app

# Sur Windows (PowerShell) :
.\build\babyfoot-app.exe

Comment la pipeline est orchestrée

    Filtrage par branche (branches) :

        feature/** et PRs : déclenchent uniquement le job build-and-test sur Linux (très rapide, évite de consommer inutilement ton quota de minutes GitHub Actions).

        main et release/** : déclenchent la matrice complète (Linux, macOS, Windows) après validation des tests.

    Filtrage par message de commit (if: !contains(...)) :

        Si tu fais un commit de documentation ou de cosmétique, ajoute [skip ci] dans ton message de commit : la pipeline ignorera le push sans rien consommer.

    Annulation des builds obsolètes (concurrency) :

        Si tu pousses 3 commits d'affilée en 2 minutes, GitHub Actions annule automatiquement les runs précédents pour ne tester que le dernier.

    Générateur Ninja :

        Spécifier -G Ninja accélère significativement les temps de compilation par rapport aux Makefiles standards dans les conteneurs CI.