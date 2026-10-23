import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

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

    // --- Arrière-plan stylisé (Terrain & Lumières d'ambiance) ---
    Item {
        anchors.fill: parent

        // Glow néon en arrière-plan
        Rectangle {
            width: 350
            height: 350
            radius: 175
            color: "#00E5FF"
            opacity: 0.12
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: -80
        }

        Rectangle {
            width: 400
            height: 400
            radius: 200
            color: "#FF007A"
            opacity: 0.10
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: -100
        }

        // Lignes discrètes façon terrain de sport
        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.95
            height: parent.height * 0.9
            color: "transparent"
            border.color: "#FFFFFF"
            border.width: 1
            opacity: 0.04
            radius: 30
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 22
        spacing: 16

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 160
            radius: 20
            color: "#141A29"
            border.color: "#222D42"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    spacing: 10

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 9
                        color: "#1A2A44"
                        border.color: "#00E5FF"
                        border.width: 1

                        Label {
                            anchors.centerIn: parent
                            text: "⚽"
                            font.pixelSize: 15
                        }
                    }

                    Label {
                        text: "BFC"
                        color: "#FFFFFF"
                        font.pixelSize: 15
                        font.bold: true
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#222D42"
                }

                Repeater {
                    model: [
                        { label: "Accueil", icon: "⌂" },
                        { label: "Matchs", icon: "⚽" },
                        { label: "Joueurs", icon: "♟" },
                        { label: "Classement", icon: "🏆" },
                        { label: "Historique", icon: "◷" }
                    ]

                    delegate: Button {
                        required property int index
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 46
                        onClicked: root.currentPage = index

                        contentItem: RowLayout {
                            spacing: 10

                            Label {
                                Layout.preferredWidth: 20
                                text: modelData.icon
                                color: root.currentPage === index ? "#00E5FF" : "#7E8FA6"
                                font.pixelSize: 16
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Label {
                                Layout.fillWidth: true
                                text: modelData.label
                                color: root.currentPage === index ? "#FFFFFF" : "#9AA9BD"
                                font.pixelSize: 12
                                font.weight: root.currentPage === index ? Font.DemiBold : Font.Normal
                                elide: Text.ElideRight
                            }
                        }

                        background: Rectangle {
                            radius: 11
                            color: root.currentPage === index ? "#1A2A44" : (parent.hovered ? "#192238" : "transparent")
                            border.color: root.currentPage === index ? "#2C3B59" : "transparent"
                            border.width: 1
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }

        // ==========================================
        // PANNEAU GAUCHE : Match & Compteur
        // ==========================================
        Rectangle {
            visible: root.currentPage === 0
            Layout.fillHeight: true
            Layout.preferredWidth: 380
            radius: 24
            color: "#141A29"
            border.color: "#222D42"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 28
                spacing: 20

                // En-tête
                RowLayout {
                    spacing: 12
                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: "#00E5FF"
                    }
                    Label {
                        text: "BABYFOOT ARENA"
                        font.pixelSize: 13
                        font.bold: true
                        font.letterSpacing: 3
                        color: "#7E8FA6"
                    }
                }

                Label {
                    text: "Match en cours"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#FFFFFF"
                }

                Item { Layout.fillHeight: true }

                // Afficheur de score central géant
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 220
                    height: 180
                    radius: 24
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#192238" }
                        GradientStop { position: 1.0; color: "#0F1626" }
                    }
                    border.color: "#2C3B59"
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 4

                        Label {
                            id: scoreLabel
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: typeof appController !== "undefined" ? appController.counter : "10"
                            font.pixelSize: 64
                            font.bold: true
                            color: "#00E5FF"

                            // Animation de pulsation au changement de valeur
                            Behavior on text {
                                SequentialAnimation {
                                    PropertyAnimation { target: scoreLabel; property: "scale"; to: 1.25; duration: 120; easing.type: Easing.OutQuad }
                                    PropertyAnimation { target: scoreLabel; property: "scale"; to: 1.0; duration: 120; easing.type: Easing.InQuad }
                                }
                            }
                        }

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "POINTS MARQUÉS"
                            font.pixelSize: 11
                            font.bold: true
                            font.letterSpacing: 1.5
                            color: "#5B6E8C"
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                // Bouton Incrémenter (Glow & scale)
                Button {
                    id: incBtn
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    text: "⚡ BUT MARQUÉ !"

                    contentItem: Text {
                        text: incBtn.text
                        font.pixelSize: 16
                        font.bold: true
                        color: "#FFFFFF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 20
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: incBtn.down ? "#009BB0" : "#00C6FF" }
                            GradientStop { position: 1.0; color: incBtn.down ? "#0055A5" : "#0072FF" }
                        }
                    }

                    scale: pressed ? 0.96 : (hovered ? 1.02 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                    onClicked: {
                        if (typeof appController !== "undefined") {
                            appController.incrementCounter()
                        } else {
                            scoreLabel.text = (parseInt(scoreLabel.text) + 1).toString()
                        }
                    }
                }
            }
        }

        // ==========================================
        // PANNEAU DROIT : Joueurs & Inscription
        // ==========================================
        Rectangle {
            visible: root.currentPage === 0
            Layout.fillHeight: true
            Layout.fillWidth: true
            radius: 24
            color: "#141A29"
            border.color: "#222D42"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 28
                spacing: 16

                Label {
                    text: "Joueurs en lice"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#FFFFFF"
                }

                // Saisie du pseudo
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    TextField {
                        id: pseudoField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        placeholderText: "Nom du challenger..."
                        placeholderTextColor: "#55657E"
                        color: "#FFFFFF"
                        font.pixelSize: 15
                        leftPadding: 20
                        rightPadding: 20

                        background: Rectangle {
                            radius: 16
                            color: "#0E131F"
                            border.color: pseudoField.activeFocus ? "#00E5FF" : "#222D42"
                            border.width: 1.5
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                        }

                        onAccepted: addPlayerBtn.clicked()
                    }

                    // Bouton Ajouter (+)
                    Button {
                        id: addPlayerBtn
                        Layout.preferredWidth: 56
                        Layout.preferredHeight: 56

                        contentItem: Text {
                            text: "+"
                            font.pixelSize: 26
                            font.bold: true
                            color: "#FFFFFF"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 16
                            color: addPlayerBtn.down ? "#D60066" : (addPlayerBtn.hovered ? "#FF1A8C" : "#FF007A")
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        scale: pressed ? 0.94 : (hovered ? 1.04 : 1.0)
                        Behavior on scale { NumberAnimation { duration: 120 } }

                        onClicked: {
                            if (pseudoField.text.trim() === "") return
                            if (typeof appController !== "undefined") {
                                appController.addPlayer(pseudoField.text)
                            } else {
                                dummyModel.append({ "name": pseudoField.text })
                            }
                            pseudoField.clear()
                        }
                    }
                }

                // Modèle factice si non relié au C++
                ListModel {
                    id: dummyModel
                    ListElement { name: "Maxime 'Striker'" }
                    ListElement { name: "Sarah 'Pissette Master'" }
                    ListElement { name: "Alexandre 'Demi'" }
                }

                // Liste des joueurs stylisée
                ListView {
                    id: playerListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 10

                    model: typeof appController !== "undefined" ? appController.players : dummyModel

                    // Animation fluide d'apparition
                    add: Transition {
                        ParallelAnimation {
                            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 250; easing.type: Easing.OutQuad }
                            NumberAnimation { property: "scale"; from: 0.8; to: 1.0; duration: 250; easing.type: Easing.OutBack }
                        }
                    }

                    remove: Transition {
                        ParallelAnimation {
                            NumberAnimation { property: "opacity"; to: 0; duration: 200 }
                            NumberAnimation { property: "scale"; to: 0.7; duration: 200 }
                        }
                    }

                    delegate: Rectangle {
                        id: playerCard
                        property string playerName: typeof modelData !== "undefined" ? modelData : model.name
                        width: playerListView.width
                        height: 60
                        radius: 16
                        color: cardMouseArea.containsMouse ? "#1E273D" : "#101624"
                        border.color: cardMouseArea.containsMouse ? "#374766" : "#1B2334"
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 150 } }

                        MouseArea {
                            id: cardMouseArea
                            anchors.fill: parent
                            z: 1
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (typeof appController !== "undefined") {
                                    appController.selectPlayer(playerCard.playerName)
                                    playerDetailsDialog.open()
                                }
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 14

                            // Pastille avatar avec initiale
                            Rectangle {
                                width: 34
                                height: 34
                                radius: 17
                                color: "#1A2A44"
                                border.color: "#00E5FF"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: {
                                        var raw = playerCard.playerName
                                        return raw && raw.length > 0 ? raw.charAt(0).toUpperCase() : "?"
                                    }
                                    color: "#00E5FF"
                                    font.bold: true
                                    font.pixelSize: 14
                                }
                            }

                            // Nom du joueur
                            Text {
                                Layout.fillWidth: true
                                text: playerCard.playerName
                                color: "#E1E7F0"
                                font.pixelSize: 15
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }

                            // Indicateur de statut
                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: "#00FF66"
                            }
                        }
                    }
                }
            }
        }

        Item {
            visible: root.currentPage !== 0
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                anchors.fill: parent
                radius: 24
                color: "#141A29"
                border.color: "#222D42"
                border.width: 1
            }
        }
    }

    Dialog {
        id: playerDetailsDialog
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: Math.min(root.width - 48, 520)
        modal: true
        dim: true
        title: ""
        padding: 24

        background: Rectangle {
            radius: 20
            color: "#141A29"
            border.color: "#2C3B59"
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: 18

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Label {
                        Layout.fillWidth: true
                        text: appController.selectedPlayer.pseudo || "Joueur"
                        color: "#FFFFFF"
                        font.pixelSize: 24
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Label {
                        text: appController.selectedPlayer.rank || "Unranked"
                        color: "#00E5FF"
                        font.pixelSize: 14
                        font.bold: true
                    }
                }

                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: "#1A2A44"
                    border.color: "#00E5FF"
                    border.width: 1

                    Label {
                        anchors.centerIn: parent
                        text: (appController.selectedPlayer.pseudo || "?").charAt(0).toUpperCase()
                        color: "#00E5FF"
                        font.pixelSize: 18
                        font.bold: true
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 86
                radius: 14
                color: "#0E131F"
                border.color: "#2C3B59"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    spacing: 16

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Label {
                            text: "🔥  " + Number(appController.selectedPlayer.mmr ?? 1000).toFixed(0) + " MMR"
                            color: "#FFFFFF"
                            font.pixelSize: 27
                            font.bold: true
                        }

                        Label {
                            text: "CLASSEMENT"
                            color: "#7E8FA6"
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }

                    Rectangle {
                        width: 1
                        Layout.fillHeight: true
                        Layout.topMargin: 18
                        Layout.bottomMargin: 18
                        color: "#2C3B59"
                    }

                    Label {
                        text: appController.selectedPlayer.rank || "Unranked"
                        color: "#00E5FF"
                        font.pixelSize: 20
                        font.bold: true
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 92
                radius: 14
                color: "#0E131F"
                border.color: "#222D42"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    spacing: 8

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Label {
                            Layout.fillWidth: true
                            text: "🏆  " + String(appController.selectedPlayer.wins ?? 0)
                            color: "#8DE0A8"
                            font.pixelSize: 20
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Label {
                            Layout.fillWidth: true
                            text: "Victoires"
                            color: "#7E8FA6"
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    Rectangle {
                        width: 1
                        Layout.fillHeight: true
                        Layout.topMargin: 18
                        Layout.bottomMargin: 18
                        color: "#222D42"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Label {
                            Layout.fillWidth: true
                            text: String(appController.selectedPlayer.matchesPlayed ?? 0)
                            color: "#FFFFFF"
                            font.pixelSize: 32
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Label {
                            Layout.fillWidth: true
                            text: "⚽ MATCHS JOUÉS"
                            color: "#7E8FA6"
                            font.pixelSize: 10
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    Rectangle {
                        width: 1
                        Layout.fillHeight: true
                        Layout.topMargin: 18
                        Layout.bottomMargin: 18
                        color: "#222D42"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Label {
                            Layout.fillWidth: true
                            text: "💔  " + String(appController.selectedPlayer.losses ?? 0)
                            color: "#FF8A9B"
                            font.pixelSize: 20
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Label {
                            Layout.fillWidth: true
                            text: "Défaites"
                            color: "#7E8FA6"
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 106
                radius: 14
                color: "#0E131F"
                border.color: "#222D42"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 8

                    Label {
                        text: "🥅  STATISTIQUES DE BUTS"
                        color: "#7E8FA6"
                        font.pixelSize: 10
                        font.bold: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Label {
                                Layout.fillWidth: true
                                text: "⚽  " + String(appController.selectedPlayer.goals ?? 0)
                                color: "#E1E7F0"
                                font.pixelSize: 19
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Label {
                                Layout.fillWidth: true
                                text: "Buts marqués"
                                color: "#7E8FA6"
                                font.pixelSize: 10
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Label {
                                Layout.fillWidth: true
                                text: "😅  " + String(appController.selectedPlayer.ownGoals ?? 0)
                                color: "#E1E7F0"
                                font.pixelSize: 19
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Label {
                                Layout.fillWidth: true
                                text: "CSC"
                                color: "#7E8FA6"
                                font.pixelSize: 10
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Label {
                                Layout.fillWidth: true
                                text: "✨  " + String(appController.selectedPlayer.usefulGoals ?? 0)
                                color: "#E1E7F0"
                                font.pixelSize: 19
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Label {
                                Layout.fillWidth: true
                                text: "Buts utiles"
                                color: "#7E8FA6"
                                font.pixelSize: 10
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }
            }

            Button {
                Layout.alignment: Qt.AlignRight
                text: "Fermer"
                onClicked: playerDetailsDialog.close()

                contentItem: Text {
                    text: parent.text
                    color: "#FFFFFF"
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 10
                    color: parent.down ? "#0055A5" : "#0072FF"
                }
            }
        }
    }
}