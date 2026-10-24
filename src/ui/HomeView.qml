import QtQuick 2.15
import QtQuick.Layouts 1.15

RowLayout {
    id: control
    spacing: 16

    signal playerSelected(string name)
    
    MatchPanel {}

    PlayerPanel {
        onPlayerClicked: function(name) { control.playerSelected(name) }
    }
}