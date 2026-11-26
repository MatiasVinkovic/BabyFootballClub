import QtQuick

Rectangle {
    id: splash
    anchors.fill: parent
    color: "#0B1220"
    z: 1000

    signal finished()

    // 0 -> 1 : pilote l'onde de choc et les confettis
    property real burst: 0
    property bool done: false

    readonly property var confettiColors: ["#43D6E8", "#F7C96B", "#FF007A", "#FFFFFF"]

    function finish() {
        if (done) return
        done = true
        anim.stop()
        visible = false
        finished()
    }

    // Onde de choc
    Rectangle {
        anchors.centerIn: parent
        width: 220; height: 220; radius: 110
        color: "transparent"
        border.color: "#43D6E8"
        border.width: 4
        scale: 0.6 + splash.burst * 2.4
        opacity: splash.burst > 0 ? 0.8 * (1 - splash.burst) : 0
    }

    // Confettis
    Repeater {
        model: 18
        delegate: Rectangle {
            required property int index
            property real angle: index * 2 * Math.PI / 18
            property real dist: 190 + (index % 3) * 60
            width: 10; height: 10; radius: 2
            color: splash.confettiColors[index % splash.confettiColors.length]
            x: splash.width / 2 + Math.cos(angle) * splash.burst * dist - width / 2
            y: splash.height / 2 + Math.sin(angle) * splash.burst * dist - height / 2
            rotation: splash.burst * 360
            opacity: splash.burst > 0 ? 1 - splash.burst : 0
        }
    }

    // Logo
    Item {
        id: logoBox
        width: 220; height: 220
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: -(splash.width / 2 + 200)

        Image {
            id: logo
            anchors.fill: parent
            source: "logo.png"
            sourceSize.width: 440
            sourceSize.height: 440
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
    }

    // Balle
    Item {
        id: ball
        width: 56; height: 56
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: splash.width / 2 + 80

        Rectangle {
            anchors.fill: parent
            radius: 28
            color: "#FFFFFF"
            border.color: "#1B2A3F"
            border.width: 2

            Rectangle {
                anchors.centerIn: parent
                width: 20; height: 20; radius: 4
                rotation: 45
                color: "#1B2A3F"
            }
            Rectangle { x: 6;  y: 8;  width: 8; height: 8; radius: 4; color: "#1B2A3F" }
            Rectangle { x: 42; y: 10; width: 8; height: 8; radius: 4; color: "#1B2A3F" }
            Rectangle { x: 24; y: 42; width: 8; height: 8; radius: 4; color: "#1B2A3F" }
        }
    }

    // Texte "BUT !"
    Text {
        id: goalText
        text: "BFC !"
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -165
        font.pixelSize: 72
        font.bold: true
        font.letterSpacing: 4
        color: "#F7C96B"
        style: Text.Outline
        styleColor: "#FF007A"
        scale: 0
        opacity: 1
    }

    // Flash blanc à l'impact
    Rectangle {
        id: flash
        anchors.fill: parent
        color: "#FFFFFF"
        opacity: 0
    }

    SequentialAnimation {
        id: anim

        // 1. Le logo arrive de la gauche
        NumberAnimation {
            target: logoBox; property: "anchors.horizontalCenterOffset"
            to: 0; duration: 550; easing.type: Easing.OutCubic
        }

        PauseAnimation { duration: 100 }

        // 2. La balle roule jusqu'au logo
        ParallelAnimation {
            NumberAnimation {
                target: ball; property: "anchors.horizontalCenterOffset"
                to: 138; duration: 380; easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: ball; property: "rotation"
                to: -720; duration: 380
            }
        }

        // 3. Impact : flash, onde, confettis, BUT, tremblement, rebond
        ParallelAnimation {
            SequentialAnimation {
                NumberAnimation { target: flash; property: "opacity"; to: 0.7; duration: 40 }
                NumberAnimation { target: flash; property: "opacity"; to: 0;   duration: 220 }
            }
            NumberAnimation {
                target: splash; property: "burst"
                from: 0; to: 1; duration: 750; easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: goalText; property: "scale"
                to: 1; duration: 350; easing.type: Easing.OutBack
            }
            SequentialAnimation {
                NumberAnimation { target: logo; property: "scale"; to: 0.82; duration: 60 }
                NumberAnimation { target: logo; property: "scale"; to: 1; duration: 500; easing.type: Easing.OutElastic }
            }
            SequentialAnimation {
                NumberAnimation { target: logoBox; property: "rotation"; to: -10; duration: 60 }
                NumberAnimation { target: logoBox; property: "rotation"; to: 10;  duration: 90 }
                NumberAnimation { target: logoBox; property: "rotation"; to: -7;  duration: 90 }
                NumberAnimation { target: logoBox; property: "rotation"; to: 7;   duration: 80 }
                NumberAnimation { target: logoBox; property: "rotation"; to: -3;  duration: 70 }
                NumberAnimation { target: logoBox; property: "rotation"; to: 0;   duration: 60 }
            }
            // La balle rebondit vers le haut à droite
            ParallelAnimation {
                NumberAnimation {
                    target: ball; property: "anchors.horizontalCenterOffset"
                    to: splash.width / 2 + 120; duration: 600; easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: ball; property: "anchors.verticalCenterOffset"
                    to: -(splash.height / 2 + 100); duration: 600; easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: ball; property: "rotation"
                    to: -1500; duration: 600
                }
            }
        }

        PauseAnimation { duration: 250 }

        // 4. Le logo est expulsé vers la droite
        ParallelAnimation {
            NumberAnimation {
                target: logoBox; property: "anchors.horizontalCenterOffset"
                to: splash.width / 2 + 250; duration: 450; easing.type: Easing.InBack
            }
            NumberAnimation {
                target: logoBox; property: "rotation"
                to: 360; duration: 450
            }
            NumberAnimation {
                target: goalText; property: "opacity"
                to: 0; duration: 300
            }
        }

        // 5. Fondu du fond
        NumberAnimation {
            target: splash; property: "opacity"
            to: 0; duration: 250
        }

        ScriptAction { script: splash.finish() }
    }

    // Toucher l'écran pour passer (bloque aussi les clics derrière)
    TapHandler { onTapped: splash.finish() }

    Component.onCompleted: anim.start()
}