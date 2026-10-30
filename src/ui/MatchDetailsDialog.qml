import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: control
    anchors.centerIn: parent
    width: Math.min(parent.width - 48, 680)
    height: Math.min(parent.height - 48, 620)
    modal: true
    padding: 0
    property var details: ({})

    function openFor(matchId) {
        if (typeof appController === "undefined")
            return
        var loaded = appController.matchDetails(matchId)
        if (!loaded || !loaded.id)
            return
        details = loaded
        open()
    }

    function playersForTeam(team) {
        var result = []
        var players = details.participants || []
        for (var i = 0; i < players.length; ++i) {
            if (Number(players[i].team) === team)
                result.push(players[i])
        }
        return result
    }

    function eventIcon(type) {
        if (type === "But")
            return "⚽"
        if (type === "CSC")
            return "↩"
        return "🔥"
    }

    function eventColor(type) {
        if (type === "But")
            return "#00E5FF"
        if (type === "CSC")
            return "#FDA4AF"
        return "#FBBF24"
    }

    function eventSummary(type) {
        var count = 0
        var events = details.events || []
        for (var i = 0; i < events.length; ++i) {
            if (events[i].type === type)
                ++count
        }
        return count
    }

    background: Rectangle {
        radius: 26
        color: "#0D1423"
        border.color: "#30415F"
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 178
            radius: 26
            color: "#17243D"
            clip: true

            Rectangle {
                width: 280
                height: 280
                radius: 140
                x: -80
                y: -150
                color: "#00E5FF"
                opacity: 0.08
            }

            Rectangle {
                width: 260
                height: 260
                radius: 130
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: -100
                anchors.topMargin: -130
                color: "#FF007A"
                opacity: 0.09
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "MATCH REPORT"
                        color: "#00E5FF"
                        font.pixelSize: 11
                        font.bold: true
                        font.letterSpacing: 2
                    }

                    Item { Layout.fillWidth: true }

                    Label {
                        text: control.details.competitive ? "COMPÉTITIF" : "AMICAL"
                        color: control.details.competitive ? "#FBBF24" : "#86EFAC"
                        font.pixelSize: 11
                        font.bold: true
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 18

                    Label {
                        text: "ÉQUIPE A"
                        color: "#FF7AAE"
                        font.pixelSize: 14
                        font.bold: true
                        Layout.preferredWidth: 105
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: "SCORE FINAL"
                            color: "#7E8FA6"
                            font.pixelSize: 10
                            font.bold: true
                        }
                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: (control.details.teamAScore || 0) + "  :  " +
                                  (control.details.teamBScore || 0)
                            color: "#FFFFFF"
                            font.pixelSize: 38
                            font.bold: true
                        }
                    }

                    Label {
                        text: "ÉQUIPE B"
                        color: "#6EE7FF"
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                        Layout.preferredWidth: 105
                    }
                }

                Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: (control.details.playedAt || "") + "   •   " +
                          (control.details.format || "") + "v" +
                          (control.details.format || "")
                    color: "#9AA9BD"
                    font.pixelSize: 11
                }
            }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: body.implicitHeight + 40
            clip: true
            ScrollBar.vertical: ScrollBar {}

            ColumnLayout {
                id: body
                x: 24
                y: 20
                width: parent.width - 48
                spacing: 18

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Label {
                            text: "LES ÉQUIPES"
                            color: "#FFFFFF"
                            font.pixelSize: 13
                            font.bold: true
                        }
                        Label {
                            text: "La composition et le résultat de chaque joueur"
                            color: "#7E8FA6"
                            font.pixelSize: 11
                        }
                    }

                    Rectangle {
                        width: 72
                        height: 48
                        radius: 12
                        color: "#16233A"
                        border.color: "#2C3B59"
                        Label {
                            anchors.centerIn: parent
                            text: (control.details.events || []).length
                            color: "#00E5FF"
                            font.pixelSize: 20
                            font.bold: true
                        }
                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 4
                            text: "ACTIONS"
                            color: "#7E8FA6"
                            font.pixelSize: 8
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Repeater {
                        model: [1, 2]
                        delegate: Rectangle {
                            required property int modelData
                            property int teamNumber: modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 112
                            radius: 16
                            color: modelData === 1 ? "#211A31" : "#142A39"
                            border.color: modelData === 1 ? "#713B68" : "#22617A"
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 13
                                spacing: 6

                                RowLayout {
                                    Layout.fillWidth: true
                                    Label {
                                        text: "ÉQUIPE " + (teamNumber === 1 ? "A" : "B")
                                        color: teamNumber === 1 ? "#FF7AAE" : "#6EE7FF"
                                        font.pixelSize: 12
                                        font.bold: true
                                    }
                                    Item { Layout.fillWidth: true }
                                    Label {
                                        text: (teamNumber === 1
                                               ? (control.details.teamAScore || 0)
                                               : (control.details.teamBScore || 0))
                                        color: "#FFFFFF"
                                        font.pixelSize: 20
                                        font.bold: true
                                    }
                                }

                                Repeater {
                                    model: control.playersForTeam(teamNumber)
                                    delegate: RowLayout {
                                        required property var modelData
                                        Layout.fillWidth: true
                                        spacing: 6
                                        Label {
                                            text: modelData.won ? "✓" : "•"
                                            color: modelData.won ? "#86EFAC" : "#7E8FA6"
                                            font.bold: true
                                        }
                                        Label {
                                            text: modelData.pseudo
                                            color: "#E5EDF8"
                                            font.pixelSize: 12
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Repeater {
                        model: ["But", "CSC", "Gamelle"]
                        delegate: Rectangle {
                            required property string modelData
                            Layout.fillWidth: true
                            height: 58
                            radius: 12
                            color: "#141E30"
                            border.color: control.eventColor(modelData)
                            border.width: 1
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 9
                                spacing: 8
                                Label {
                                    text: control.eventIcon(modelData)
                                    color: control.eventColor(modelData)
                                    font.pixelSize: 20
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0
                                    Label {
                                        text: modelData
                                        color: "#FFFFFF"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                    Label {
                                        text: control.eventSummary(modelData)
                                        color: control.eventColor(modelData)
                                        font.pixelSize: 16
                                        font.bold: true
                                    }
                                }
                            }
                        }
                    }
                }

                Label {
                    text: "CHRONIQUE DU MATCH"
                    color: "#FFFFFF"
                    font.pixelSize: 13
                    font.bold: true
                }

                Label {
                    visible: (control.details.events || []).length === 0
                    text: "Aucune action n'a été saisie pour ce match."
                    color: "#7E8FA6"
                    font.pixelSize: 12
                }

                Repeater {
                    model: control.details.events || []
                    delegate: Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        height: 48
                        radius: 12
                        color: "#141E30"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12
                            Label {
                                text: control.eventIcon(modelData.type)
                                color: control.eventColor(modelData.type)
                                font.pixelSize: 18
                                Layout.preferredWidth: 24
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                Label {
                                    text: modelData.type + "  •  " + modelData.pseudo
                                    color: "#FFFFFF"
                                    font.pixelSize: 12
                                    font.bold: true
                                }
                                Label {
                                    text: "Position " + modelData.positionCode
                                    color: "#7E8FA6"
                                    font.pixelSize: 10
                                }
                            }
                            Label {
                                text: "ACTION"
                                color: control.eventColor(modelData.type)
                                font.pixelSize: 9
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }

        Button {
            Layout.alignment: Qt.AlignRight
            Layout.rightMargin: 24
            Layout.bottomMargin: 18
            text: "FERMER"
            onClicked: control.close()
        }
    }
}
