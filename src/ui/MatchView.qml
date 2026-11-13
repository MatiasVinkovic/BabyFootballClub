import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: view

    property bool matchStarted: false
    property int gameMode: 2 // 1 = 1v1, 2 = 2v2
    property string matchType: "Amical"
    property int winningScore: 10
    property int teamAScore: 0
    property int teamBScore: 0
    property var teamAPlayers: []
    property var teamBPlayers: []
    property string teamADefender: ""
    property string teamBDefender: ""
    property string winnerName: ""
    property bool matchRecorded: false
    property var matchStats: ({})
    property var matchEvents: []

    // Gestion de la sélection du joueur et de la gamelle
    property string selectedPlayerName: ""
    property string selectedPlayerTeam: "" // "A" (Rouge) ou "B" (Bleu)
    property int selectedPositionCode: 0
    property bool showGamelleDialog: false
    property string pendingCage: ""
    property var mmrResults: []

    radius: 20
    color: "#0F172A"
    border.color: "#1E293B"
    border.width: 1

    function selectedPlayers() {
        var result = [teamA1.currentText || "", teamB1.currentText || ""]
        if (gameMode === 2)
            result.push(teamA2.currentText || "", teamB2.currentText || "")
        return result.filter(function (name) { return name !== "" && name !== undefined })
    }

    function canStart() {
        var players = selectedPlayers()
        var expected = (gameMode === 1 ? 2 : 4)
        if (players.length !== expected)
            return false
        for (var i = 0; i < players.length; ++i) {
            if (players.indexOf(players[i]) !== i)
                return false
        }
        return true
    }

    function startMatch() {
        teamAPlayers = gameMode === 1 ? [teamA1.currentText || ""] : [teamA1.currentText || "", teamA2.currentText || ""]
        teamBPlayers = gameMode === 1 ? [teamB1.currentText || ""] : [teamB1.currentText || "", teamB2.currentText || ""]
        teamADefender = teamAPlayers[0] || ""
        teamBDefender = teamBPlayers[0] || ""
        teamAScore = 0
        teamBScore = 0
        winnerName = ""
        selectedPlayerName = ""
        selectedPlayerTeam = ""
        selectedPositionCode = 0
        showGamelleDialog = false
        pendingCage = ""
        matchRecorded = false
        matchStats = ({})
        matchEvents = []
        mmrResults = []
        matchStarted = true
    }

    Component {
    id: mmrRowComponent

    Rectangle {
        id: row
        property var r: modelData
        property real shownMmr: r.oldMmr
        property bool deltaVisible: false
        readonly property bool rankChanged: r.newRank !== "" && r.newRank !== r.oldRank

        width: 250
        height: 58
        radius: 12
        color: "#1E293B"
        border.width: 2
        border.color: r.team === 1 ? "#EF4444" : "#3B82F6"
        opacity: 0
        transform: Translate { id: shift; y: 24 }

        Column {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                text: r.pseudo + (r.won ? "  🏆" : "")
                color: "white"
                font.bold: true
                font.pixelSize: 14
            }
            Text {
                visible: r.newRank !== ""
                text: row.rankChanged ? r.oldRank + "  →  " + r.newRank : r.newRank
                color: row.rankChanged ? "#FACC15" : "#94A3B8"
                font.bold: row.rankChanged
                font.pixelSize: 11
            }
        }

        Column {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Text {
                anchors.right: parent.right
                text: Math.round(row.shownMmr) + " MMR"
                color: "#E2E8F0"
                font.pixelSize: 13
            }
            Text {
                anchors.right: parent.right
                text: (r.delta >= 0 ? "+" : "") + r.delta
                color: r.delta >= 0 ? "#22C55E" : "#EF4444"
                font.bold: true
                font.pixelSize: 20
                opacity: row.deltaVisible ? 1 : 0
                scale: row.deltaVisible ? 1 : 0.3
                Behavior on scale { NumberAnimation { duration: 450; easing.type: Easing.OutBack } }
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }

        SequentialAnimation {
            id: anim
            // Apparition en cascade : rouge puis bleu, un joueur après l'autre
            PauseAnimation { duration: 500 + (r.team - 1) * 150 + index * 350 }
            ParallelAnimation {
                NumberAnimation { target: row; property: "opacity"; to: 1; duration: 250 }
                NumberAnimation { target: shift; property: "y"; to: 0; duration: 300; easing.type: Easing.OutCubic }
            }
            ScriptAction { script: row.deltaVisible = true }
            // Le compteur MMR défile de l'ancienne à la nouvelle valeur
            NumberAnimation {
                target: row
                property: "shownMmr"
                to: r.newMmr
                duration: 1200
                easing.type: Easing.OutCubic
            }
        }

        Component.onCompleted: anim.start()
    }
}

    function recordPlayerEvent(name, eventName) {
        if (!name) return
        if (!matchStats[name]) {
            matchStats[name] = { goals: 0, ownGoals: 0, gamelles: 0 }
        }
        matchStats[name][eventName] = (matchStats[name][eventName] || 0) + 1
        matchEvents.push({
            pseudo: name,
            type: eventName === "goals" ? "goal" :
                  (eventName === "ownGoals" ? "own_goal" : "gamelle"),
            positionCode: selectedPositionCode
        })
    }

    function recordMatchResult() {
        if (matchRecorded || winnerName === "") return

        var results = []
        var winningTeam = winnerName === "ÉQUIPE ROUGE" ? teamAPlayers : teamBPlayers
        var losingTeam = winnerName === "ÉQUIPE ROUGE" ? teamBPlayers : teamAPlayers

        function appendResults(team, won) {
            for (var i = 0; i < team.length; ++i) {
                var name = team[i]
                var stats = matchStats[name] || { goals: 0, ownGoals: 0, gamelles: 0 }
                results.push({
                    pseudo: name,
                    team: team === teamAPlayers ? 1 : 2,
                    goals: stats.goals || 0,
                    ownGoals: stats.ownGoals || 0,
                    gamelles: stats.gamelles || 0,
                    win: won ? 1 : 0,
                    loss: won ? 0 : 1
                })
            }
        }

        appendResults(winningTeam, true)
        appendResults(losingTeam, false)

        if (typeof appController !== "undefined" &&
            typeof appController.recordMatch === "function") {
            var res = appController.recordMatch(gameMode, matchType === "Compétitif", {
                winningScore: winningScore,
                teamAScore: teamAScore,
                teamBScore: teamBScore,
                participants: results,
                events: matchEvents
            })
            mmrResults = res
        }
        matchRecorded = true
    }

    function getPlayerForRod(rodIndex) {
        if (!teamAPlayers || !teamBPlayers || teamAPlayers.length === 0 || teamBPlayers.length === 0)
            return ""

        if (gameMode === 1) {
            var pA = teamAPlayers[0] || ""
            var pB = teamBPlayers[0] || ""
            return isRedRod(rodIndex) ? pA : pB
        } else {
            var teamAAttacker = teamAPlayers[0] === teamADefender
                ? (teamAPlayers[1] || "") : (teamAPlayers[0] || "")
            var teamBAttacker = teamBPlayers[0] === teamBDefender
                ? (teamBPlayers[1] || "") : (teamBPlayers[0] || "")

            if (rodIndex === 0 || rodIndex === 1) return teamADefender
            if (rodIndex === 3 || rodIndex === 5) return teamAAttacker
            if (rodIndex === 6 || rodIndex === 7) return teamBDefender
            if (rodIndex === 2 || rodIndex === 4) return teamBAttacker
        }
        return ""
    }

    function isRedRod(rodIndex) {
        return rodIndex === 0 || rodIndex === 1 || rodIndex === 3 || rodIndex === 5
    }

    function positionCodeForRod(rodIndex, figureIndex) {
        if (rodIndex === 0 || rodIndex === 7)
            return 1
        if (rodIndex === 1 || rodIndex === 6)
            return figureIndex === 0 ? 2 : 3
        if (rodIndex === 2 || rodIndex === 5)
            return figureIndex === 1 ? 10 :
                   (figureIndex === 0 ? 9 : 11)
        return 4 + figureIndex
    }

    function selectPlayer(name, team, rodIndex, figureIndex) {
        if (winnerName !== "" || !name) return
        if (selectedPlayerName === name) {
            selectedPlayerName = ""
            selectedPlayerTeam = ""
            selectedPositionCode = 0
        } else {
            selectedPlayerName = name
            selectedPlayerTeam = team
            selectedPositionCode = positionCodeForRod(rodIndex, figureIndex)
        }
    }

    function openGoalChoice(cage) {
        if (!selectedPlayerName || winnerName !== "") return

        var isCSC = (cage === "LEFT" && selectedPlayerTeam === "A") || (cage === "RIGHT" && selectedPlayerTeam === "B")

        if (isCSC) {
            applyCSC(cage)
        } else {
            pendingCage = cage
            showGamelleDialog = true
        }
    }

    function applyCSC(cage) {
        var beneficiaryTeam = (cage === "LEFT") ? "B" : "A"

        if (beneficiaryTeam === "A") {
            teamAScore++
            if (teamAScore >= winningScore) winnerName = "ÉQUIPE ROUGE"
        } else {
            teamBScore++
            if (teamBScore >= winningScore) winnerName = "ÉQUIPE BLEUE"
        }
        recordPlayerEvent(selectedPlayerName, "ownGoals")
        recordMatchResult()

        // Appel backend C++ sécurisé
        if (typeof appController !== "undefined") {
            if (typeof appController.recordGoalWithDetails === "function") {
                appController.recordGoalWithDetails(selectedPlayerName, cage, true, "CSC")
            } else if (typeof appController.recordGoal === "function") {
                appController.recordGoal(selectedPlayerName)
            }
        }

        selectedPlayerName = ""
        selectedPlayerTeam = ""
        selectedPositionCode = 0
    }

    function applyGoalOption(optionType) {
        showGamelleDialog = false
        var cage = pendingCage
        var beneficiaryTeam = (cage === "LEFT") ? "B" : "A"
        var victimTeam = (cage === "LEFT") ? "A" : "B"

        if (optionType === "PLUS_ONE") {
            if (beneficiaryTeam === "A") {
                teamAScore++
                if (teamAScore >= winningScore) winnerName = "ÉQUIPE ROUGE"
            } else {
                teamBScore++
                if (teamBScore >= winningScore) winnerName = "ÉQUIPE BLEUE"
            }
            recordPlayerEvent(selectedPlayerName, "goals")
        } else if (optionType === "GAMELLE_MINUS_ONE") {
            if (victimTeam === "A") {
                teamAScore = Math.max(0, teamAScore - 1)
            } else {
                teamBScore = Math.max(0, teamBScore - 1)
            }
            recordPlayerEvent(selectedPlayerName, "gamelles")
        }
        recordMatchResult()

        // Appel backend C++ sécurisé
        if (typeof appController !== "undefined") {
            if (typeof appController.recordGoalWithDetails === "function") {
                appController.recordGoalWithDetails(selectedPlayerName, cage, false, optionType)
            } else if (typeof appController.recordGoal === "function") {
                appController.recordGoal(selectedPlayerName)
            }
        }

        selectedPlayerName = ""
        selectedPlayerTeam = ""
        selectedPositionCode = 0
        pendingCage = ""
    }

    // ==========================================
    // 1. VUE CONFIGURATION (AVANT LE MATCH)
    // ==========================================
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16
        visible: !view.matchStarted

        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Label {
                text: "CONFIGURATION DU MATCH"
                color: "#38BDF8"
                font.pixelSize: 16
                font.bold: true
                font.letterSpacing: 2
            }

            Item { Layout.fillWidth: true }

            ComboBox {
                id: modeBox
                implicitWidth: 130
                model: ["1 VS 1", "2 VS 2"]
                currentIndex: 1
                onCurrentIndexChanged: view.gameMode = currentIndex + 1
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 20

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 16

                ColumnLayout {
                    Layout.preferredWidth: 150
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 16

                    Label { text: "ÉQUIPE ROUGE"; color: "#EF4444"; font.pixelSize: 14; font.bold: true }

                    ColumnLayout {
                        spacing: 4
                        Label { text: "Joueur 1"; color: "#F87171"; font.pixelSize: 11; font.bold: true }
                        ComboBox {
                            id: teamA1
                            Layout.fillWidth: true
                            model: typeof appController !== "undefined" ? appController.players : ["Joueur 1"]
                        }
                    }

                    ColumnLayout {
                        visible: view.gameMode === 2
                        spacing: 4
                        Label { text: "Joueur 2"; color: "#F87171"; font.pixelSize: 11; font.bold: true }
                        ComboBox {
                            id: teamA2
                            Layout.fillWidth: true
                            model: typeof appController !== "undefined" ? appController.players : ["Joueur 2"]
                        }
                    }
                }

                // Terrain vertical de préparation coloré
                Rectangle {
                    id: pitchVertical
                    Layout.preferredWidth: 180
                    Layout.fillHeight: true
                    Layout.maximumHeight: 380
                    Layout.alignment: Qt.AlignHCenter
                    radius: 18
                    color: "#15803D"
                    border.color: "#334155"
                    border.width: 6
                    clip: true

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 10
                        color: "transparent"
                        border.color: "white"
                        border.width: 2
                        opacity: 0.5

                        Rectangle { anchors.centerIn: parent; width: parent.width; height: 2; color: "white" }
                        Rectangle { anchors.centerIn: parent; width: 60; height: 60; radius: 30; color: "transparent"; border.color: "white"; border.width: 2 }
                    }

                    Column {
                        anchors.fill: parent
                        anchors.topMargin: 15
                        anchors.bottomMargin: 15
                        spacing: (pitchVertical.height - 30) / 8

                        Repeater {
                            model: [
                                {team: "A", count: 1}, {team: "A", count: 2}, {team: "B", count: 3}, {team: "A", count: 5},
                                {team: "B", count: 5}, {team: "A", count: 3}, {team: "B", count: 2}, {team: "B", count: 1}
                            ]
                            delegate: Item {
                                required property var modelData
                                width: pitchVertical.width
                                height: 10

                                Rectangle { anchors.centerIn: parent; width: parent.width; height: 3; color: "#E2E8F0" }
                                Row {
                                    anchors.centerIn: parent
                                    spacing: modelData.count === 5 ? 6 : (modelData.count === 3 ? 18 : 32)
                                    Repeater {
                                        model: modelData.count
                                        Rectangle {
                                            width: 14; height: 14; radius: 7
                                            color: modelData.team === "A" ? "#DC2626" : "#2563EB"
                                            border.color: "white"
                                            border.width: 1.5
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.preferredWidth: 150
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 16

                    Label { text: "ÉQUIPE BLEUE"; color: "#60A5FA"; font.pixelSize: 14; font.bold: true }

                    ColumnLayout {
                        spacing: 4
                        Label { text: "Joueur 3"; color: "#93C5FD"; font.pixelSize: 11; font.bold: true }
                        ComboBox {
                            id: teamB1
                            Layout.fillWidth: true
                            model: typeof appController !== "undefined" ? appController.players : ["Joueur 3"]
                        }
                    }

                    ColumnLayout {
                        visible: view.gameMode === 2
                        spacing: 4
                        Label { text: "Joueur 4"; color: "#93C5FD"; font.pixelSize: 11; font.bold: true }
                        ComboBox {
                            id: teamB2
                            Layout.fillWidth: true
                            model: typeof appController !== "undefined" ? appController.players : ["Joueur 4"]
                        }
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 240
                Layout.fillHeight: true
                color: "#1E293B"
                radius: 16
                border.color: "#334155"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 16

                    Label { text: "PARAMÈTRES"; color: "white"; font.pixelSize: 14; font.bold: true; font.letterSpacing: 1 }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Label { text: "Type de match"; color: "#94A3B8"; font.pixelSize: 12 }
                        ComboBox {
                            id: typeBox
                            Layout.fillWidth: true
                            model: ["Amical", "Compétitif"]
                            onCurrentTextChanged: view.matchType = currentText
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Label { text: "Nb de points gagnants"; color: "#94A3B8"; font.pixelSize: 12 }
                        ComboBox {
                            id: scoreBox
                            Layout.fillWidth: true
                            readonly property bool ranked: view.matchType === "Compétitif"
                            model: ranked ? ["3 Buts", "5 Buts"]
                                        : ["1 But", "2 Buts", "3 Buts", "4 Buts", "5 Buts",
                                            "6 Buts", "7 Buts", "8 Buts", "9 Buts", "10 Buts"]
                            onModelChanged: currentIndex = ranked ? 1 : 9
                            onCurrentTextChanged: view.winningScore = parseInt(currentText)
                        }
                    }

                    Item { Layout.fillHeight: true }

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 46
                        enabled: view.canStart()
                        text: "Commencer le match !"

                        background: Rectangle {
                            color: parent.enabled ? (parent.down ? "#0284C7" : "#0EA5E9") : "#334155"
                            radius: 10
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.bold: true
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: view.startMatch()
                    }
                }
            }
        }
    }

    // ==========================================
    // 2. VUE MATCH HORIZONTAL
    // ==========================================
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        visible: view.matchStarted

        // Tableau de bord supérieur
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: view.gameMode === 2 ? 92 : 56
            color: "#1E293B"
            radius: 14
            border.color: "#334155"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    Label {
                        Layout.fillWidth: true
                        text: "🔴 " + view.teamAPlayers.join(" & ")
                        color: "white"
                        font.pixelSize: 13
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    RowLayout {
                        visible: view.gameMode === 2
                        spacing: 6
                        Label { text: "Défense"; color: "#FCA5A5"; font.pixelSize: 11 }
                        ComboBox {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            model: view.teamAPlayers
                            currentIndex: Math.max(0, view.teamAPlayers.indexOf(view.teamADefender))
                            onActivated: {
                                view.teamADefender = currentText
                                view.selectedPlayerName = ""
                                view.selectedPlayerTeam = ""
                                view.selectedPositionCode = 0
                            }
                        }
                    }

                    Label {
                        visible: view.gameMode === 2
                        text: "Attaque  " + (view.teamAPlayers[0] === view.teamADefender
                              ? (view.teamAPlayers[1] || "") : (view.teamAPlayers[0] || ""))
                        color: "#FCA5A5"
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    color: "#0F172A"
                    radius: 10
                    implicitWidth: 130
                    implicitHeight: 38
                    border.color: "#38BDF8"
                    border.width: 1

                    Label {
                        anchors.centerIn: parent
                        text: view.teamAScore + "  :  " + view.teamBScore
                        color: "#38BDF8"
                        font.pixelSize: 22
                        font.bold: true
                    }
                }

                Item { Layout.fillWidth: true }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    Label {
                        Layout.fillWidth: true
                        text: view.teamBPlayers.join(" & ") + " 🔵"
                        color: "white"
                        font.pixelSize: 13
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                        elide: Text.ElideLeft
                    }

                    RowLayout {
                        visible: view.gameMode === 2
                        spacing: 6
                        Label {
                            text: "Défense"
                            color: "#93C5FD"
                            font.pixelSize: 11
                        }
                        ComboBox {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            model: view.teamBPlayers
                            currentIndex: Math.max(0, view.teamBPlayers.indexOf(view.teamBDefender))
                            onActivated: {
                                view.teamBDefender = currentText
                                view.selectedPlayerName = ""
                                view.selectedPlayerTeam = ""
                                view.selectedPositionCode = 0
                            }
                        }
                    }

                    Label {
                        visible: view.gameMode === 2
                        Layout.fillWidth: true
                        text: "Attaque  " + (view.teamBPlayers[0] === view.teamBDefender
                              ? (view.teamBPlayers[1] || "") : (view.teamBPlayers[0] || ""))
                        color: "#93C5FD"
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignRight
                        elide: Text.ElideLeft
                    }
                }
            }
        }

        // Grand Terrain de Babyfoot
        Rectangle {
            id: pitchHorizontal
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 20
            color: "#15803D"
            border.color: "#022C22"
            border.width: 8
            clip: true

            // Tracés du terrain
            Rectangle {
                anchors.fill: parent
                anchors.margins: 16
                color: "transparent"
                border.color: "white"
                border.width: 2
                opacity: 0.6

                Rectangle { anchors.centerIn: parent; height: parent.height; width: 2; color: "white" }
                Rectangle { anchors.centerIn: parent; width: 110; height: 110; radius: 55; color: "transparent"; border.color: "white"; border.width: 2 }
            }

            // --- CAGE GAUCHE (Équipe Rouge) ---
            Rectangle {
                id: goalLeft
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width: 48
                height: 150
                radius: 8
                color: view.selectedPlayerName !== "" ? "#DC2626" : "#1E293B"
                border.color: view.selectedPlayerName !== "" ? "#FACC15" : "white"
                border.width: view.selectedPlayerName !== "" ? 3 : 2
                opacity: view.selectedPlayerName !== "" ? 0.95 : 0.6

                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    Label { text: "CAGE"; color: "white"; font.bold: true; font.pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
                    Label { text: "ROUGE"; color: "#FCA5A5"; font.bold: true; font.pixelSize: 10; anchors.horizontalCenter: parent.horizontalCenter }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: view.selectedPlayerName !== "" ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: view.openGoalChoice("LEFT")
                }
            }

            // --- CAGE DROITE (Équipe Bleue) ---
            Rectangle {
                id: goalRight
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width: 48
                height: 150
                radius: 8
                color: view.selectedPlayerName !== "" ? "#2563EB" : "#1E293B"
                border.color: view.selectedPlayerName !== "" ? "#FACC15" : "white"
                border.width: view.selectedPlayerName !== "" ? 3 : 2
                opacity: view.selectedPlayerName !== "" ? 0.95 : 0.6

                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    Label { text: "CAGE"; color: "white"; font.bold: true; font.pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
                    Label { text: "BLEUE"; color: "#93C5FD"; font.bold: true; font.pixelSize: 10; anchors.horizontalCenter: parent.horizontalCenter }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: view.selectedPlayerName !== "" ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: view.openGoalChoice("RIGHT")
                }
            }

            // Les 8 barres de babyfoot
            Repeater {
                model: [
                    {team: "A", count: 1, rodIdx: 0},
                    {team: "A", count: 2, rodIdx: 1},
                    {team: "B", count: 3, rodIdx: 2},
                    {team: "A", count: 5, rodIdx: 3},
                    {team: "B", count: 5, rodIdx: 4},
                    {team: "A", count: 3, rodIdx: 5},
                    {team: "B", count: 2, rodIdx: 6},
                    {team: "B", count: 1, rodIdx: 7}
                ]
                delegate: Item {
                    required property var modelData
                    required property int index

                    property string rodTeam: modelData.team
                    property int rodCount: modelData.count
                    property int rodIndex: modelData.rodIdx

                    x: 60 + (index + 0.5) * ((pitchHorizontal.width - 120) / 8) - width / 2
                    y: 0
                    width: 36
                    height: pitchHorizontal.height

                    // Barre métallique
                    Rectangle {
                        anchors.centerIn: parent
                        height: parent.height
                        width: 5
                        color: "#E2E8F0"
                        border.color: "#64748B"
                        border.width: 1
                    }

                    // Figurines sur la barre
                    Column {
                        anchors.centerIn: parent
                        spacing: rodCount === 5 ? 22 : (rodCount === 3 ? 58 : 105)

                        Repeater {
                            model: rodCount
                            delegate: Item {
                                width: 36
                                height: 46

                                property string pName: view.getPlayerForRod(rodIndex)
                                property bool isSelected: view.selectedPlayerName === pName && pName !== ""
                                property bool isRed: rodTeam === "A"

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 26
                                    height: 38
                                    radius: 8
                                    scale: isSelected ? 1.25 : 1.0

                                    color: isRed ? "#DC2626" : "#2563EB"
                                    border.color: isSelected ? "#FACC15" : "white"
                                    border.width: isSelected ? 3 : 1

                                    Behavior on scale { NumberAnimation { duration: 120 } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: (pName && pName.length > 0) ? pName.substring(0, 2).toUpperCase() : ""
                                        color: "white"
                                        font.bold: true
                                        font.pixelSize: 11
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: view.selectPlayer(pName, rodTeam, rodIndex, index)
                                }
                            }
                        }
                    }
                }
            }

            // POPUP DE SÉLECTION : BUT CLASSIQUE OU GAMELLE
            Rectangle {
                anchors.fill: parent
                color: "#D90F172A"
                visible: view.showGamelleDialog

                Rectangle {
                    anchors.centerIn: parent
                    implicitWidth: 340
                    implicitHeight: 220
                    radius: 20
                    color: "#1E293B"
                    border.color: "#38BDF8"
                    border.width: 2

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 14

                        Label {
                            text: "TYPE DE BUT / ACTION"
                            color: "#38BDF8"
                            font.bold: true
                            font.pixelSize: 14
                            font.letterSpacing: 1
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Label {
                            text: view.selectedPlayerName.toUpperCase() + " A MARQUÉ !"
                            color: "white"
                            font.bold: true
                            font.pixelSize: 16
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Button {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            text: "⚽ BUT CLASSIQUE (+1 point)"
                            background: Rectangle {
                                color: parent.down ? "#0284C7" : "#0EA5E9"
                                radius: 10
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.bold: true
                                font.pixelSize: 13
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: view.applyGoalOption("PLUS_ONE")
                        }

                        Button {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            text: "💥 GAMELLE (-1 point à l'adversaire)"
                            background: Rectangle {
                                color: parent.down ? "#B91C1C" : "#EF4444"
                                radius: 10
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.bold: true
                                font.pixelSize: 13
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: view.applyGoalOption("GAMELLE_MINUS_ONE")
                        }
                    }
                }
            }

            // Écran de victoire
            Rectangle {
                anchors.fill: parent
                color: "#F00F172A"
                visible: view.winnerName !== ""

                ColumnLayout {
    anchors.centerIn: parent
    spacing: 12

    Label {
        text: "🏆 VICTOIRE ! 🏆"
        color: "#F59E0B"
        font.pixelSize: 28
        font.bold: true
        Layout.alignment: Qt.AlignHCenter
    }

    Label {
        text: view.winnerName + " REMPORTE LE MATCH"
        color: "white"
        font.pixelSize: 18
        font.bold: true
        Layout.alignment: Qt.AlignHCenter
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 24

        Column {
            spacing: 8
            Repeater {
                model: view.mmrResults.filter(function (r) { return r.team === 1 })
                delegate: mmrRowComponent
            }
        }
        Column {
            spacing: 8
            Repeater {
                model: view.mmrResults.filter(function (r) { return r.team === 2 })
                delegate: mmrRowComponent
            }
        }
    }

    Button {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 180
        text: "Recommencer"
        onClicked: view.matchStarted = false
    }
}
            }
        }

        // Barre d'actions inférieure
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 32

            Button {
                text: "Quitter le match"
                onClicked: view.matchStarted = false
            }

            Item { Layout.fillWidth: true }

            Label {
                text: view.selectedPlayerName !== "" ? "Joueur sélectionné : " + view.selectedPlayerName : ""
                color: "#FACC15"
                font.bold: true
            }
        }
    }
}