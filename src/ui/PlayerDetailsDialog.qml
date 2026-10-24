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