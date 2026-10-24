import QtQuick.Controls
import QtQuick 2.15
import QtQuick.Layouts 1.15


Rectangle {
    id: control

    property int currentIndex: 0

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
                { label: "Règlement", icon: "📖" },
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
                onClicked: control.currentIndex = index

                contentItem: RowLayout {
                    spacing: 10

                    Label {
                        Layout.preferredWidth: 20
                        text: modelData.icon
                        color: control.currentIndex === index ? "#00E5FF" : "#7E8FA6"
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Label {
                        Layout.fillWidth: true
                        text: modelData.label
                        color: control.currentIndex === index ? "#FFFFFF" : "#9AA9BD"
                        font.pixelSize: 12
                        font.weight: control.currentIndex === index ? Font.DemiBold : Font.Normal
                        elide: Text.ElideRight
                    }
                }

                background: Rectangle {
                    radius: 11
                    color: control.currentIndex === index ? "#1A2A44" : (parent.hovered ? "#192238" : "transparent")
                    border.color: control.currentIndex === index ? "#2C3B59" : "transparent"
                    border.width: 1
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}