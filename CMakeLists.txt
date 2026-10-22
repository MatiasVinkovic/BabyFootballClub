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

qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

qt_add_executable(babyfoot-app
    src/main.cpp
    src/infra/SqlitePlayerRepository.cpp
    src/ui/AppController.cpp
)

qt_add_qml_module(babyfoot-app
    URI Babyfoot
    VERSION 1.0
    QML_FILES
        src/ui/Main.qml
)

target_include_directories(babyfoot-app PRIVATE src)

target_link_libraries(babyfoot-app PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Sql
)