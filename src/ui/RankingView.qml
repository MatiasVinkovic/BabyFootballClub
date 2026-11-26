import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: control

    signal playerClicked(string name)

    Layout.fillWidth: true
    Layout.fillHeight: true
    radius: 24
    color: "#10213A"
    border.color: "#31547A"
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 28
        spacing: 18

        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Label {
                    text: "Classement"
                    color: "#FFFFFF"
                    font.pixelSize: 24
                    font.bold: true
                }

                Label {
                    text: appController.leaderboardRanked ? "MODE RANKED" : "MODE CASUAL"
                    color: appController.leaderboardRanked ? "#FF8A65" : "#63D6C5"
                    font.pixelSize: 11
                    font.bold: true
                }
            }

            ComboBox {
                id: modeSelector
                Layout.preferredWidth: 132
                Layout.preferredHeight: 40
                model: ["Casual", "Ranked"]
                currentIndex: appController.leaderboardRanked ? 1 : 0
                onActivated: appController.setLeaderboardMode(currentIndex === 1)

                contentItem: Text {
                    leftPadding: 10
                    rightPadding: 24
                    text: modeSelector.displayText
                    color: "#0B2542"
                    font.pixelSize: 14
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                }

                indicator: Text {
                    x: modeSelector.width - width - 10
                    y: (modeSelector.height - height) / 2
                    text: "⌄"
                    color: "#0B2542"
                    font.pixelSize: 18
                    font.bold: true
                }

                background: Rectangle {
                    color: "#7DD3FC"
                    border.color: "#BAE6FD"
                    border.width: 1
                    radius: 6
                }
            }

            ComboBox {
                id: rankingCriterion
                Layout.preferredWidth: 150
                Layout.preferredHeight: 40
                property var sortKeys: appController.leaderboardRanked
                    ? ["mmr", "goals", "usefulGoals", "wins", "matches", "ownGoals", "losses", "gamelles"]
                    : ["goals", "usefulGoals", "wins", "matches", "ownGoals", "losses", "gamelles"]
                model: appController.leaderboardRanked
                    ? ["MMR", "Buts marqués", "Buts utiles", "Victoires", "Matchs joués", "CSC", "Défaites", "Gamelles"]
                    : ["Buts marqués", "Buts utiles", "Victoires", "Matchs joués", "CSC", "Défaites", "Gamelles"]
                currentIndex: sortKeys.indexOf(appController.leaderboardSort)
                onActivated: appController.setLeaderboardSort(sortKeys[currentIndex])

                contentItem: Text {
                    leftPadding: 10
                    rightPadding: 24
                    text: rankingCriterion.displayText
                    color: "#0B2542"
                    font.pixelSize: 14
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                indicator: Text {
                    x: rankingCriterion.width - width - 10
                    y: (rankingCriterion.height - height) / 2
                    text: "⌄"
                    color: "#0B2542"
                    font.pixelSize: 18
                    font.bold: true
                }

                background: Rectangle {
                    color: "#7DD3FC"
                    border.color: "#BAE6FD"
                    border.width: 1
                    radius: 6
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#31547A"
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 14
            Layout.rightMargin: 14
            height: 32

            Label {
                Layout.preferredWidth: 56
                text: "PLACE"
                color: "#8490A4"
                font.pixelSize: 10
                font.bold: true
            }
            Label {
                Layout.fillWidth: true
                text: "JOUEUR"
                color: "#8490A4"
                font.pixelSize: 10
                font.bold: true
            }
            Label {
                Layout.preferredWidth: 110
                text: rankingCriterion.displayText.toUpperCase()
                color: "#8490A4"
                font.pixelSize: 10
                font.bold: true
                horizontalAlignment: Text.AlignRight
            }
        }

        ListView {
            id: rankings
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 6
            model: appController.leaderboard

            delegate: Rectangle {
                required property var modelData
                width: rankings.width
                height: modelData.position === 1 ? 84
                    : modelData.position === 2 ? 76
                    : modelData.position === 3 ? 68 : 56
                radius: 8
                color: modelData.position === 1 ? "#594711"
                    : modelData.position === 2 ? "#46515C"
                    : modelData.position === 3 ? "#59361F" : "#0B2542"
                border.color: modelData.position === 1 ? "#D8B34A"
                         : modelData.position === 2 ? "#C4CDD5"
                         : modelData.position === 3 ? "#C78B58" : "#23496F"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 12

                    Label {
                        Layout.preferredWidth: 62
                        text: modelData.position <= 3 ? "#" + modelData.position
                            : String(modelData.position).padStart(2, "0")
                        color: "#FFFFFF"
                        font.pixelSize: 14
                        font.bold: true
                    }
                    Label {
                        Layout.fillWidth: true
                        text: modelData.pseudo
                        color: "#FFFFFF"
                        font.pixelSize: modelData.position <= 3 ? 16 : 15
                        font.bold: modelData.position <= 3
                        elide: Text.ElideRight
                    }
                    RowLayout {
                        Layout.preferredWidth: 112
                        Layout.alignment: Qt.AlignRight
                        spacing: 6
                        visible: appController.leaderboardSort === "mmr"

                        Image {
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 48
                            source: modelData.rankIcon || ""
                            sourceSize.width: 96
                            sourceSize.height: 96
                            fillMode: Image.PreserveAspectFit
                        }

                        Label {
                            text: String(modelData.value)
                            color: "#FFFFFF"
                            font.pixelSize: 16
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    Label {
                        Layout.preferredWidth: 112
                        visible: appController.leaderboardSort !== "mmr"
                        text: String(modelData.value)
                        color: "#FFFFFF"
                        font.pixelSize: 16
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                    }
                }

                TapHandler {
                    onTapped: control.playerClicked(modelData.pseudo)
                }

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
            }

            Label {
                anchors.centerIn: parent
                visible: rankings.count === 0
                text: "Aucun joueur"
                color: "#D8E8F7"
                font.pixelSize: 14
            }
        }
    }
}