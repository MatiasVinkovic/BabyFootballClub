import QtQuick.Controls
import QtQuick 2.15
import QtQuick.Layouts 1.15


Rectangle {
    id: control

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