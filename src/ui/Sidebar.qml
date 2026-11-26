import QtQuick.Controls
import QtQuick 2.15
import QtQuick.Layouts 1.15


Rectangle {
    id: control

    property int currentIndex: 0
    property bool collapsed: false
    signal pageSelected(int pageIndex)

    Layout.fillHeight: true
    Layout.preferredWidth: collapsed ? 64 : 160
    radius: 20
    color: "#141A29"
    border.color: "#222D42"
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: control.collapsed ? 8 : 12
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            spacing: control.collapsed ? 0 : 10

            Rectangle {
                width: 28
                height: 28
                radius: 9
                color: "#1A2A44"
                border.color: "#00E5FF"
                border.width: 1
                visible: !control.collapsed

                Label {
                    anchors.centerIn: parent
                    text: "B"
                    font.pixelSize: 15
                }
            }

            Label {
                text: "BFC"
                color: "#FFFFFF"
                font.pixelSize: 15
                font.bold: true
                visible: !control.collapsed
                Layout.fillWidth: true
            }

            Button {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                Layout.alignment: control.collapsed ? Qt.AlignHCenter : Qt.AlignRight
                text: control.collapsed ? "›" : "‹"
                Accessible.name: control.collapsed ? "Développer le menu" : "Replier le menu"
                onClicked: control.collapsed = !control.collapsed

                ToolTip.visible: hovered
                ToolTip.text: control.collapsed ? "Développer le menu" : "Replier le menu"

                contentItem: Label {
                    text: parent.text
                    color: "#9AA9BD"
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    radius: 7
                    color: parent.hovered ? "#1A2A44" : "transparent"
                }
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
                { label: "Règlement", icon: "R" },
                { label: "Matchs", icon: "M" },
                { label: "Joueurs", icon: "J" },
                
                { label: "Classement", icon: "C" },
                { label: "Historique", icon: "◷" }
            ]

            delegate: Button {
                required property int index
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                Accessible.name: modelData.label
                onClicked: control.pageSelected(index)
                ToolTip.visible: control.collapsed && hovered
                ToolTip.text: modelData.label

                contentItem: RowLayout {
                    spacing: control.collapsed ? 0 : 10

                    Label {
                        Layout.preferredWidth: 20
                        text: modelData.icon
                        color: control.currentIndex === index ? "#00E5FF" : "#7E8FA6"
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        Layout.fillWidth: true
                        text: modelData.label
                        color: control.currentIndex === index ? "#FFFFFF" : "#9AA9BD"
                        font.pixelSize: 12
                        font.weight: control.currentIndex === index ? Font.DemiBold : Font.Normal
                        elide: Text.ElideRight
                        visible: !control.collapsed
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

        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: 42
            Accessible.name: "Éteindre le Raspberry Pi"
            ToolTip.visible: hovered
            ToolTip.text: "Éteindre le Raspberry Pi"
            onClicked: poweroffDialog.open()

            contentItem: Label {
                text: control.collapsed ? "OFF" : "Éteindre"
                color: "#FF8A9B"
                font.pixelSize: 12
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                radius: 9
                color: parent.hovered ? "#3A202D" : "transparent"
                border.color: "#5A2D3C"
                border.width: 1
            }
        }
    }

    Dialog {
        id: poweroffDialog
        anchors.centerIn: Overlay.overlay
        width: 320
        modal: true
        title: "Éteindre le Raspberry Pi ?"

        contentItem: Label {
            text: "L'application et les autres services vont être arrêtés."
            color: "#D7E0EC"
            wrapMode: Text.WordWrap
        }

        footer: RowLayout {
            spacing: 10

            Item { Layout.fillWidth: true }

            Button {
                text: "Annuler"
                onClicked: poweroffDialog.reject()
            }

            Button {
                text: "Éteindre"
                onClicked: poweroffDialog.accept()
            }
        }

        onAccepted: {
            if (typeof appController !== "undefined")
                appController.poweroff()
        }
    }
}