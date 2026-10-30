import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: control
    radius: 24
    color: "#141A29"
    border.color: "#222D42"
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 28
        spacing: 18

        Label {
            text: "Historique des matchs"
            color: "#FFFFFF"
            font.pixelSize: 24
            font.bold: true
        }

        Label {
            visible: appController.matchHistory.length === 0
            text: "Aucun match enregistré pour le moment."
            color: "#9AA9BD"
            font.pixelSize: 15
        }

        ListView {
            visible: appController.matchHistory.length > 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            clip: true
            model: appController.matchHistory

            delegate: Rectangle {
                required property var modelData
                Accessible.name: "Détails du match"
                width: ListView.view.width
                height: 82
                radius: 14
                color: "#1A2234"
                border.color: "#2C3B59"
                border.width: 1

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: matchDetailsDialog.openFor(modelData.id)
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 18

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Label {
                            text: modelData.participants
                            color: "#FFFFFF"
                            font.pixelSize: 15
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Label {
                            text: modelData.playedAt + "  •  " +
                                  (modelData.competitive ? "Compétitif" : "Amical") +
                                  "  •  " + modelData.format + "v" + modelData.format
                            color: "#9AA9BD"
                            font.pixelSize: 12
                        }
                    }

                    Label {
                        text: modelData.score
                        color: "#00E5FF"
                        font.pixelSize: 22
                        font.bold: true
                    }
                }
            }
        }
    }
}
