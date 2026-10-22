import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

ApplicationWindow {
    id: root

    width: 900
    height: 600
    minimumWidth: 800
    minimumHeight: 520
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
        anchors.margins: 28
        spacing: 24

        // ==========================================
        // PANNEAU GAUCHE : Match & Compteur
        // ==========================================
        Rectangle {
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
                            hoverEnabled: true
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
                                        var raw = typeof modelData !== "undefined" ? modelData : model.name
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
                                text: typeof modelData !== "undefined" ? modelData : model.name
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
    }
}