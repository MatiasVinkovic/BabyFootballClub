import QtQuick.Controls
import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: control

    signal playerClicked(string name)

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

        ListModel {
            id: dummyModel
            ListElement { name: "Maxime 'Striker'" }
            ListElement { name: "Sarah 'Pissette Master'" }
            ListElement { name: "Alexandre 'Demi'" }
        }

        ListView {
            id: playerListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 10

            model: typeof appController !== "undefined" ? appController.players : dummyModel

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
                    onClicked: control.playerClicked(playerCard.playerName)
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 14

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

                    Text {
                        Layout.fillWidth: true
                        text: playerCard.playerName
                        color: "#E1E7F0"
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }

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