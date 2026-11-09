import QtQuick.Controls
import QtQuick 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: control
    anchors.centerIn: parent
    width: Math.min(parent.width - 48, 520)
    modal: true
    dim: true
    title: ""
    padding: 24
    property bool detailsVisible: false
    property int detailEventIndex: 0
    property var detailEvents: ["goal", "own_goal", "gamelle"]
    property var detailLabels: ["Buts", "CSC", "Gamelles"]

    function detailCounts() {
        if (typeof appController === "undefined" || !appController.selectedPlayer)
            return []
        var pseudo = appController.selectedPlayer.pseudo
        if (typeof pseudo !== "string" || pseudo.length === 0)
            return []
        return appController.positionEventCounts(pseudo, detailEvents[detailEventIndex])
    }

    function detailCount(position) {
        var counts = detailCounts()
        return counts.length > position ? Number(counts[position]) : 0
    }

    function detailTotal() {
        var total = 0
        var counts = detailCounts()
        for (var i = 1; i < counts.length; ++i)
            total += Number(counts[i])
        return total
    }

    function detailPercent(position) {
        var total = detailTotal()
        return total === 0 ? 0 : Math.round(detailCount(position) * 1000 / total) / 10
    }

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
                    text: (typeof appController !== "undefined" && appController.selectedPlayer) ? (appController.selectedPlayer.pseudo || "Joueur") : "Joueur"
                    color: "#FFFFFF"
                    font.pixelSize: 24
                    font.bold: true
                    elide: Text.ElideRight
                }

                Label {
                    text: (typeof appController !== "undefined" && appController.selectedPlayer) ? (appController.selectedPlayer.rank || "Unranked") : "Unranked"
                    color: "#00E5FF"
                    font.pixelSize: 14
                    font.bold: true
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Label {
                    text: "Statistiques :"
                    color: "#7E8FA6"
                    font.pixelSize: 12
                }

                ComboBox {
                    id: statsModeBox
                    Layout.fillWidth: true
                    model: ["1v1 amical", "2v2 amical", "1v1 compétitif", "2v2 compétitif"]
                    currentIndex: (appController.statsCompetitive ? 2 : 0) +
                                  (appController.statsFormat === 2 ? 1 : 0)
                    onActivated: {
                        if (typeof appController !== "undefined") {
                            appController.setStatsMode((currentIndex % 2) + 1, currentIndex >= 2)
                        }
                    }
                }

                Button {
                    text: control.detailsVisible ? "Fermer détails" : "Détails"
                    onClicked: control.detailsVisible = !control.detailsVisible
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
                    text: {
                        var p = (typeof appController !== "undefined" && appController.selectedPlayer) ? appController.selectedPlayer.pseudo : "?"
                        return (p || "?").charAt(0).toUpperCase()
                    }
                    color: "#00E5FF"
                    font.pixelSize: 18
                    font.bold: true
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 420
            visible: control.detailsVisible
            radius: 14
            color: "#0E131F"
            border.color: "#2C3B59"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: "DÉTAILS PAR POSITION"
                        color: "#7E8FA6"
                        font.pixelSize: 10
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    ComboBox {
                        model: control.detailLabels
                        currentIndex: control.detailEventIndex
                        onActivated: control.detailEventIndex = currentIndex
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#15803D"
                    radius: 16
                    border.color: "#86EFAC"
                    border.width: 2
                    clip: true

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 14
                        color: "transparent"
                        border.color: "white"
                        border.width: 2
                        opacity: 0.65
                        Rectangle {
                            anchors.centerIn: parent
                            width: 2
                            height: parent.height
                            color: "white"
                        }
                        Rectangle {
                            anchors.centerIn: parent
                            width: 70
                            height: 70
                            radius: 35
                            color: "transparent"
                            border.color: "white"
                            border.width: 2
                        }
                    }

                    Repeater {
                        model: [
                            {code: 1, x: 8, y: 50, label: "G"},
                            {code: 2, x: 24, y: 25, label: "DG"},
                            {code: 3, x: 24, y: 75, label: "DD"},
                            {code: 4, x: 50, y: 15, label: "M1"},
                            {code: 5, x: 50, y: 32, label: "M2"},
                            {code: 6, x: 50, y: 68, label: "M3"},
                            {code: 7, x: 50, y: 85, label: "M4"},
                            {code: 8, x: 50, y: 50, label: "M5"},
                            {code: 9, x: 76, y: 25, label: "AG"},
                            {code: 10, x: 82, y: 50, label: "AC"},
                            {code: 11, x: 76, y: 75, label: "AD"}
                        ]
                        delegate: Rectangle {
                            required property var modelData
                            x: parent.width * modelData.x / 100 - width / 2
                            y: parent.height * modelData.y / 100 - height / 2
                            width: 58
                            height: 38
                            radius: 10
                            color: "#172033"
                            border.color: modelData.code === 1 ? "#FACC15" : "#BAE6FD"
                            border.width: 1
                            Column {
                                anchors.centerIn: parent
                                spacing: 0
                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.label
                                    color: "white"
                                    font.pixelSize: 9
                                    font.bold: true
                                }
                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: control.detailPercent(modelData.code) + "%"
                                    color: "#FACC15"
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }
                        }
                    }
                }

                Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: control.detailTotal() === 0
                          ? "Aucun événement enregistré"
                          : "Répartition des " + control.detailLabels[control.detailEventIndex].toLowerCase()
                    color: "#7E8FA6"
                    font.pixelSize: 11
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
                        text: "🔥  " + Number((typeof appController !== "undefined" && appController.selectedPlayer) ? (appController.selectedPlayer.mmr ?? 1000) : 1000).toFixed(0) + " MMR"
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
                    text: (typeof appController !== "undefined" && appController.selectedPlayer) ? (appController.selectedPlayer.rank || "Unranked") : "Unranked"
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
                        text: "🏆  " + String((typeof appController !== "undefined" && appController.selectedPlayer) ? (appController.selectedPlayer.wins ?? 0) : 0)
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
                        text: String((typeof appController !== "undefined" && appController.selectedPlayer) ? (appController.selectedPlayer.matchesPlayed ?? 0) : 0)
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
                        text: "💔  " + String((typeof appController !== "undefined" && appController.selectedPlayer) ? (appController.selectedPlayer.losses ?? 0) : 0)
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
                            text: "⚽  " + String((typeof appController !== "undefined" && appController.selectedPlayer) ? (appController.selectedPlayer.goals ?? 0) : 0)
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
                            text: "🥅  " + String((typeof appController !== "undefined" && appController.selectedPlayer) ? (appController.selectedPlayer.gamelles ?? 0) : 0)
                            color: "#E1E7F0"
                            font.pixelSize: 19
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Label {
                            Layout.fillWidth: true
                            text: "Gamelles"
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
                            text: "😅  " + String((typeof appController !== "undefined" && appController.selectedPlayer) ? (appController.selectedPlayer.ownGoals ?? 0) : 0)
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
                            text: "✨  " + String((typeof appController !== "undefined" && appController.selectedPlayer) ? (appController.selectedPlayer.usefulGoals ?? 0) : 0)
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
            onClicked: control.close()

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