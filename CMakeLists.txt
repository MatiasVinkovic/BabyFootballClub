cmake_minimum_required(VERSION 3.21)

project(babyfoot
    VERSION 0.1.0
    LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS
    Quick
    QuickControls2
    Sql
)
qt_standard_project_setup()

if(COMMAND qt_policy)
    qt_policy(SET QTP0001 NEW)
    qt_policy(SET QTP0004 NEW)
endif()

qt_add_executable(babyfoot-app
    src/main.cpp
    src/infra/SqlitePlayerRepository.cpp
    src/infra/SqliteRegleRepository.cpp
    src/ui/AppController.cpp
)

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
        src/ui/RegleView.qml
)

target_include_directories(babyfoot-app PRIVATE src)

target_link_libraries(babyfoot-app PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Sql
)