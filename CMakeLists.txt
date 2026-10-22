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

# Activation de CTest pour la pipeline actions github
include(CTest)

if(BUILD_TESTING)
    # Exemple d'exécutable de test pour le repository
    add_executable(unit_tests
        tests/test_repository.cpp
        src/infra/SqlitePlayerRepository.cpp
    )
    target_include_directories(unit_tests PRIVATE src)
    target_link_libraries(unit_tests PRIVATE
        Qt6::Sql
        Qt6::Test
    )
    # Enregistrement du binaire auprès de ctest
    add_test(NAME RepoTests COMMAND unit_tests)
endif()