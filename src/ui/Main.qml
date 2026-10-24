import QtQuick.Controls
import QtQuick 2.15
import QtQuick.Layouts 1.15


ApplicationWindow {
    id: root

    property int currentPage: 0

    width: 1100
    height: 650
    minimumWidth: 980
    minimumHeight: 560
    visible: true
    title: "Babyfoot Arena Master"
    color: "#0B0F19"

    // Fond néon & repères de terrain
    Item {
        anchors.fill: parent

        Rectangle {
            width: 350; height: 350; radius: 175
            color: "#00E5FF"; opacity: 0.12
            anchors.top: parent.top; anchors.left: parent.left
            anchors.margins: -80
        }

        Rectangle {
            width: 400; height: 400; radius: 200
            color: "#FF007A"; opacity: 0.10
            anchors.bottom: parent.bottom; anchors.right: parent.right
            anchors.margins: -100
        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.95; height: parent.height * 0.9
            color: "transparent"
            border.color: "#FFFFFF"; border.width: 1
            opacity: 0.04; radius: 30
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 22
        spacing: 16

        Sidebar {
            currentIndex: root.currentPage
            onCurrentIndexChanged: root.currentPage = currentIndex
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.currentPage

            // Page 0 : Accueil (Match + Inscription)
            HomeView {
                onPlayerSelected: (name) => {
                    if (typeof appController !== "undefined") {
                        appController.selectPlayer(name)
                    }
                    playerDetailsDialog.open()
                }
            }

            // Page 1 : Matchs (ex. feature/regle)
            Rectangle { radius: 24; color: "#141A29"; border.color: "#222D42"; border.width: 1 }

            // Page 2 : Joueurs (ex. feature/joueur-mmr)
            Rectangle { radius: 24; color: "#141A29"; border.color: "#222D42"; border.width: 1 }

            // Page 3 : Classement
            Rectangle { radius: 24; color: "#141A29"; border.color: "#222D42"; border.width: 1 }

            // Page 4 : Historique
            Rectangle { radius: 24; color: "#141A29"; border.color: "#222D42"; border.width: 1 }
        }
    }

    PlayerDetailsDialog {
        id: playerDetailsDialog
        parent: Overlay.overlay
    }
}