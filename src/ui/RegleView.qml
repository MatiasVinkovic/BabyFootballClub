import QtQuick.Controls
import QtQuick 2.15
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
        spacing: 20

        // En-tête
        RowLayout {
            spacing: 12
            Rectangle {
                width: 12
                height: 12
                radius: 6
                color: "#00E5FF"
            }
            Label {
                text: "RÈGLEMENT DU BFC"
                font.pixelSize: 13
                font.bold: true
                font.letterSpacing: 3
                color: "#7E8FA6"
            }
        }

        Label {
            text: "Règles Officielles du comité du BFC"
            font.pixelSize: 24
            font.bold: true
            color: "#FFFFFF"
        }

        // --- Formulaire d'ajout d'une règle ---
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                TextField {
                    id: ruleNameField
                    Layout.preferredWidth: 260
                    Layout.preferredHeight: 46
                    placeholderText: "Nom de la règle (ex. Pissette)..."
                    placeholderTextColor: "#55657E"
                    color: "#FFFFFF"
                    font.pixelSize: 14
                    leftPadding: 16

                    background: Rectangle {
                        radius: 12
                        color: "#0E131F"
                        border.color: ruleNameField.activeFocus ? "#00E5FF" : "#222D42"
                        border.width: 1.5
                    }
                }

                TextField {
                    id: ruleContentField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    placeholderText: "Description de la règle..."
                    placeholderTextColor: "#55657E"
                    color: "#FFFFFF"
                    font.pixelSize: 14
                    leftPadding: 16

                    background: Rectangle {
                        radius: 12
                        color: "#0E131F"
                        border.color: ruleContentField.activeFocus ? "#00E5FF" : "#222D42"
                        border.width: 1.5
                    }

                    onAccepted: addRuleBtn.clicked()
                }

                Button {
                    id: addRuleBtn
                    Layout.preferredHeight: 46
                    Layout.preferredWidth: 100
                    text: "+ Ajouter"

                    contentItem: Text {
                        text: addRuleBtn.text
                        color: "#FFFFFF"
                        font.bold: true
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 12
                        color: addRuleBtn.down ? "#009BB0" : (addRuleBtn.hovered ? "#00E5FF" : "#00A8C6")
                    }

                    onClicked: {
                        if (ruleNameField.text.trim() === "" || ruleContentField.text.trim() === "") return

                        if (typeof appController !== "undefined") {
                            appController.addRegle(ruleNameField.text, ruleContentField.text)
                        } else {
                            dummyRules.append({
                                "nom": ruleNameField.text,
                                "contenu": ruleContentField.text
                            })
                        }

                        ruleNameField.clear()
                        ruleContentField.clear()
                    }
                }
            }
        }

        // Modèle de secours si testé sans backend
        ListModel {
            id: dummyRules
            ListElement {
                nom: "Pissette"
                contenu: "But marqué de l'ailier droit sans déviation. Interdit sauf accord mutuel avant engagement."
            }
            ListElement {
                nom: "Roulette"
                contenu: "Rotation de la barre supérieure à 360 degrés sans contrôle préalable interdite."
            }
            ListElement {
                nom: "Râteaux"
                contenu: "Action d'intercepter la balle avec les demis de façon répétée et agressive."
            }
        }

        // --- Liste des règles déroulante ---
        ListView {
            id: rulesListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 12

            model: typeof appController !== "undefined" ? appController.regles : dummyRules

            delegate: Rectangle {
                width: rulesListView.width
                implicitHeight: cardLayout.implicitHeight + 28
                radius: 16
                color: "#101624"
                border.color: "#1E273D"
                border.width: 1

                ColumnLayout {
                    id: cardLayout
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 6

                    RowLayout {
                        spacing: 10
                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: "#00E5FF"
                        }
                        Label {
                            text: model.nom || modelData.nom
                            color: "#FFFFFF"
                            font.pixelSize: 16
                            font.bold: true
                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        text: model.contenu || modelData.contenu
                        color: "#9AA9BD"
                        font.pixelSize: 13
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
    }
}