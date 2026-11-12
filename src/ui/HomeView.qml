import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: control

    signal playerSelected(string name)
    signal navigateTo(int pageIndex)

    Layout.fillWidth: true
    Layout.fillHeight: true
    radius: 22
    color: "#101827"
    border.color: "#25364D"
    border.width: 1
    clip: true

    property bool entered: false

    Component.onCompleted: introTimer.start()

    Timer {
        id: introTimer
        interval: 80
        onTriggered: control.entered = true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 112
            opacity: control.entered ? 1 : 0
            transform: Translate {
                y: control.entered ? 0 : 14
                Behavior on y { NumberAnimation { duration: 420; easing.type: Easing.OutCubic } }
            }
            Behavior on opacity { NumberAnimation { duration: 420; easing.type: Easing.OutCubic } }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Label {
                    text: "⚽  BABYFOOT CLUB"
                    color: "#66D9EF"
                    font.pixelSize: 11
                    font.bold: true
                }

                Label {
                    text: "Le terrain vous attend."
                    color: "#FFFFFF"
                    font.pixelSize: 30
                    font.bold: true
                    wrapMode: Text.WordWrap
                }

                Label {
                    text: "Préparez la partie, retrouvez les joueurs en forme et gardez un œil sur le classement."
                    color: "#A7B5C8"
                    font.pixelSize: 13
                    wrapMode: Text.WordWrap
                    Layout.maximumWidth: 520
                }
            }

            Button {
                text: "⚽  Créer un match"
                Layout.preferredWidth: 178
                Layout.preferredHeight: 48
                scale: hovered ? 1.04 : (down ? 0.98 : 1)
                onClicked: control.navigateTo(2)
                Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                contentItem: Text {
                    text: parent.text
                    color: "#07131F"
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    radius: 8
                    color: parent.hovered ? "#7DEBFF" : "#43D6E8"
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 2
            rowSpacing: 12
            columnSpacing: 12

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 145
                radius: 10
                color: rankingHover.hovered ? "#1C3551" : "#14243A"
                border.color: rankingHover.hovered ? "#5AA9C8" : "#2A4562"
                scale: rankingHover.hovered ? 1.018 : 1
                z: rankingHover.hovered ? 2 : 0
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                opacity: control.entered ? 1 : 0
                transform: Translate {
                    y: control.entered ? 0 : 18
                    Behavior on y {
                        SequentialAnimation {
                            PauseAnimation { duration: 80 }
                            NumberAnimation { duration: 420; easing.type: Easing.OutCubic }
                        }
                    }
                }
                Behavior on opacity {
                    SequentialAnimation {
                        PauseAnimation { duration: 80 }
                        NumberAnimation { duration: 420; easing.type: Easing.OutCubic }
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            Layout.fillWidth: true
                            text: "🏆 Classement"
                            color: "#FFFFFF"
                            font.pixelSize: 16
                            font.bold: true
                        }
                        Button {
                            text: "Voir tout  ›"
                            Layout.preferredWidth: 104
                            Layout.preferredHeight: 34
                            scale: hovered ? 1.04 : (down ? 0.98 : 1)
                            onClicked: control.navigateTo(4)
                            Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                            contentItem: Text {
                                text: parent.text
                                color: "#07131F"
                                font.pixelSize: 12
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                radius: 6
                                color: parent.hovered ? "#8BEAFF" : "#43D6E8"
                                Behavior on color { ColorAnimation { duration: 140 } }
                            }
                        }
                    }

                    Repeater {
                        model: appController.leaderboard.slice(0, 3)
                        delegate: RowLayout {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 24
                            Label {
                                Layout.preferredWidth: 30
                                text: modelData.position === 1 ? "🥇" : modelData.position === 2 ? "🥈" : "🥉"
                                font.pixelSize: 14
                            }
                            Label {
                                Layout.fillWidth: true
                                text: modelData.pseudo
                                color: "#F4F7FB"
                                font.pixelSize: 13
                                elide: Text.ElideRight
                            }
                            Label {
                                text: modelData.mmr + " MMR"
                                color: "#74DDEA"
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        visible: appController.leaderboard.length === 0
                        text: "Ajoutez des joueurs pour lancer le classement."
                        color: "#95A6BB"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                    }
                }

                TapHandler { onTapped: control.navigateTo(4) }
                HoverHandler {
                    id: rankingHover
                    cursorShape: Qt.PointingHandCursor
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 145
                radius: 10
                color: playersHover.hovered ? "#25384F" : "#192638"
                border.color: playersHover.hovered ? "#738CA7" : "#394B62"
                scale: playersHover.hovered ? 1.018 : 1
                z: playersHover.hovered ? 2 : 0
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                opacity: control.entered ? 1 : 0
                transform: Translate {
                    y: control.entered ? 0 : 18
                    Behavior on y {
                        SequentialAnimation {
                            PauseAnimation { duration: 150 }
                            NumberAnimation { duration: 420; easing.type: Easing.OutCubic }
                        }
                    }
                }
                Behavior on opacity {
                    SequentialAnimation {
                        PauseAnimation { duration: 150 }
                        NumberAnimation { duration: 420; easing.type: Easing.OutCubic }
                    }
                }
                HoverHandler {
                    id: playersHover
                    cursorShape: Qt.PointingHandCursor
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 9

                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            Layout.fillWidth: true
                            text: "🔥 Joueurs du moment"
                            color: "#FFFFFF"
                            font.pixelSize: 16
                            font.bold: true
                        }
                        Button {
                            text: "Joueurs  ›"
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 34
                            scale: hovered ? 1.04 : (down ? 0.98 : 1)
                            onClicked: control.navigateTo(3)
                            Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                            contentItem: Text {
                                text: parent.text
                                color: "#07131F"
                                font.pixelSize: 12
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                radius: 6
                                color: parent.hovered ? "#8BEAFF" : "#43D6E8"
                                Behavior on color { ColorAnimation { duration: 140 } }
                            }
                        }
                    }

                    Repeater {
                        model: appController.topPlayers.slice(0, 3)
                        delegate: ItemDelegate {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 25
                            padding: 2
                            scale: hovered ? 1.025 : 1
                            onClicked: control.playerSelected(modelData.pseudo)
                            Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                            background: Rectangle {
                                radius: 5
                                color: parent.hovered ? "#29415A" : "transparent"
                                Behavior on color { ColorAnimation { duration: 140 } }
                            }
                            contentItem: RowLayout {
                                Label {
                                    Layout.fillWidth: true
                                    text: modelData.pseudo
                                    color: "#FFFFFF"
                                    font.pixelSize: 13
                                    elide: Text.ElideRight
                                }
                                Label {
                                    text: modelData.wins + " victoires"
                                    color: "#F7C96B"
                                    font.pixelSize: 12
                                    font.bold: true
                                }
                            }
                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        visible: appController.topPlayers.length === 0
                        text: "Les vainqueurs apparaîtront ici après les premiers matchs."
                        color: "#95A6BB"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 132
                radius: 10
                color: rulesHover.hovered ? "#1C3551" : "#14243A"
                border.color: rulesHover.hovered ? "#5AA9C8" : "#2A4562"
                scale: rulesHover.hovered ? 1.018 : 1
                z: rulesHover.hovered ? 2 : 0
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                opacity: control.entered ? 1 : 0
                transform: Translate {
                    y: control.entered ? 0 : 18
                    Behavior on y {
                        SequentialAnimation {
                            PauseAnimation { duration: 220 }
                            NumberAnimation { duration: 420; easing.type: Easing.OutCubic }
                        }
                    }
                }
                Behavior on opacity {
                    SequentialAnimation {
                        PauseAnimation { duration: 220 }
                        NumberAnimation { duration: 420; easing.type: Easing.OutCubic }
                    }
                }
                HoverHandler {
                    id: rulesHover
                    cursorShape: Qt.PointingHandCursor
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            Layout.fillWidth: true
                            text: "📖 Règlement"
                            color: "#FFFFFF"
                            font.pixelSize: 16
                            font.bold: true
                        }
                        Button {
                            text: "Ouvrir  ›"
                            Layout.preferredWidth: 92
                            Layout.preferredHeight: 34
                            onClicked: control.navigateTo(1)
                            scale: hovered ? 1.04 : (down ? 0.98 : 1)
                            Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                            contentItem: Text {
                                text: parent.text
                                color: "#07131F"
                                font.pixelSize: 12
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                radius: 6
                                color: parent.hovered ? "#8BEAFF" : "#43D6E8"
                                Behavior on color { ColorAnimation { duration: 140 } }
                            }
                        }
                    }

                    Repeater {
                        model: appController.regles.slice(0, 2)
                        delegate: ColumnLayout {
                            required property var modelData
                            Layout.fillWidth: true
                            spacing: 2
                            Label {
                                Layout.fillWidth: true
                                text: modelData.nom
                                color: "#EAF1F8"
                                font.pixelSize: 13
                                font.bold: true
                                elide: Text.ElideRight
                            }
                            Label {
                                Layout.fillWidth: true
                                text: modelData.contenu
                                color: "#95A6BB"
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        visible: appController.regles.length === 0
                        text: "Aucune règle enregistrée pour le moment."
                        color: "#95A6BB"
                        font.pixelSize: 12
                    }
                }

                TapHandler { onTapped: control.navigateTo(1) }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 132
                radius: 10
                color: matchHover.hovered ? "#214561" : "#183047"
                border.color: matchHover.hovered ? "#55B3CF" : "#31718A"
                scale: matchHover.hovered ? 1.018 : 1
                z: matchHover.hovered ? 2 : 0
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                opacity: control.entered ? 1 : 0
                transform: Translate {
                    y: control.entered ? 0 : 18
                    Behavior on y {
                        SequentialAnimation {
                            PauseAnimation { duration: 290 }
                            NumberAnimation { duration: 420; easing.type: Easing.OutCubic }
                        }
                    }
                }
                Behavior on opacity {
                    SequentialAnimation {
                        PauseAnimation { duration: 290 }
                        NumberAnimation { duration: 420; easing.type: Easing.OutCubic }
                    }
                }
                HoverHandler {
                    id: matchHover
                    cursorShape: Qt.PointingHandCursor
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    Label {
                        text: "⚽ Prochaine partie"
                        color: "#FFFFFF"
                        font.pixelSize: 16
                        font.bold: true
                    }
                    Label {
                        Layout.fillWidth: true
                        text: "Composez les équipes et lancez le match depuis la feuille de score."
                        color: "#B6C7D7"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                    }
                    Button {
                        text: "Accéder à la création  →"
                        Layout.preferredHeight: 34
                        scale: hovered ? 1.04 : (down ? 0.98 : 1)
                        onClicked: control.navigateTo(2)
                        Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                        contentItem: Text {
                            text: parent.text
                            color: "#07131F"
                            font.pixelSize: 12
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            radius: 6
                            color: parent.hovered ? "#8BEAFF" : "#43D6E8"
                            Behavior on color { ColorAnimation { duration: 140 } }
                        }
                    }
                }

                TapHandler { onTapped: control.navigateTo(2) }
            }
        }
    }
}