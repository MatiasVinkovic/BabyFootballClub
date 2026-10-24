# Architecture de l'interface utilisateur

**BabyFootballClub · QML et Qt 6**

Cette documentation décrit l'organisation de l'interface, son intégration avec CMake et les échanges entre les composants QML et le moteur C++.

## 1. Vue d'ensemble

L'interface utilise le système de modules QML de Qt 6 avec `qt_add_qml_module`.

Ses principes sont les suivants :

- **Ressources QML intégrées** : les fichiers déclarés dans le module `Babyfoot` sont compilés dans les ressources de l'exécutable et accessibles sous `qrc:/qt/qml/Babyfoot/`.
- **Architecture modulaire** : `Main.qml` orchestre la fenêtre et la navigation sans concentrer la logique métier. Chaque panneau est un composant indépendant.
- **Responsabilités séparées** : les propriétés transmettent l'état vers les composants enfants et les signaux font remonter les événements vers leurs parents.

## 2. Organisation des fichiers

```text
src/ui/
├── Main.qml                # Fenêtre racine et routage des pages
├── Sidebar.qml             # Navigation latérale et page sélectionnée
├── HomeView.qml            # Page d'accueil, match et joueurs
├── MatchPanel.qml          # Match en cours, score et bouton de but
├── PlayerPanel.qml         # Ajout et liste des joueurs
└── PlayerDetailsDialog.qml # Statistiques détaillées d'un joueur
```

## 3. Rôle des composants

| Composant | Type racine | Responsabilité |
| --- | --- | --- |
| `Main.qml` | `ApplicationWindow` | Gère la fenêtre, le décor, la navigation et le `StackLayout`. Héberge aussi `PlayerDetailsDialog`. |
| `Sidebar.qml` | `Rectangle` | Affiche les entrées de navigation et expose `currentIndex`. |
| `HomeView.qml` | `RowLayout` | Assemble le panneau de match et la liste des joueurs. |
| `MatchPanel.qml` | `Rectangle` | Affiche le score, son animation et l'action d'incrémentation. |
| `PlayerPanel.qml` | `Rectangle` | Gère l'ajout des joueurs, leur affichage dans un `ListView` et le signal `playerClicked(name)`. |
| `PlayerDetailsDialog.qml` | `Dialog` | Affiche le MMR, le rang, les victoires, les défaites et le détail des buts. |

## 4. Communication entre les composants

### 4.1. Flux QML vers QML

Les composants enfants ne manipulent pas directement l'état global ni les boîtes de dialogue. Ils émettent des signaux que les composants parents relaient.

```text
PlayerPanel
    └─ playerClicked(name)
       └─ HomeView
          └─ playerSelected(name)
             └─ Main.qml
                ├─ appController.selectPlayer(name)
                └─ playerDetailsDialog.open()
```

### 4.2. Flux C++ vers QML

Le contrôleur C++ est exposé au contexte racine sous le nom `appController`, par exemple avec `setInitialProperties` ou `rootContext()->setContextProperty`.

Le QML peut également fonctionner sans backend C++ grâce à des gardes défensives :

- vérifier la présence du contrôleur avec `typeof appController !== "undefined"` ;
- utiliser des données de démonstration (`dummyModel`) et des valeurs par défaut lorsque le backend n'est pas disponible.

## 5. Déclaration du module QML dans CMake

Chaque composant QML doit être déclaré dans `QML_FILES` pour que Qt génère le cache QML et enregistre les types du module.

La déclaration actuelle se trouve dans le `CMakeLists.txt` à la racine du projet :

```cmake
qt_add_qml_module(babyfoot-app
    URI Babyfoot
    VERSION 1.0
    QML_FILES
        src/ui/Main.qml
        src/ui/HomeView.qml
        src/ui/PlayerPanel.qml
        src/ui/MatchPanel.qml
        src/ui/PlayerDetailsDialog.qml
        src/ui/Sidebar.qml
)
```

### Convention de nommage

Le nom déclaré dans CMake, le nom du fichier `.qml` et le nom utilisé comme type dans le code doivent correspondre exactement, y compris la casse.

Par exemple, `RankingView.qml` doit être utilisé comme `RankingView` et déclaré comme fichier QML dans `qt_add_qml_module`.

## 6. Ajouter une nouvelle fonctionnalité

Pour ajouter une page, par exemple un classement :

1. Créer le composant autonome `src/ui/RankingView.qml`.
2. Ajouter ce fichier à `QML_FILES` dans le `CMakeLists.txt` racine.
3. Insérer `RankingView` dans le `StackLayout` de `Main.qml` à l'index correspondant.
4. Ajouter ou adapter l'entrée de navigation dans `Sidebar.qml`.

Exemple :

```qml
StackLayout {
    currentIndex: root.currentPage

    HomeView {}       // Index 0
    MatchesView {}    // Index 1
    PlayersView {}    // Index 2
    RankingView {}    // Index 3
}
```

> Dans l'état actuel du projet, les pages des index 1 à 4 sont encore représentées par des `Rectangle` temporaires dans `Main.qml`. Elles pourront être remplacées progressivement par des composants dédiés.