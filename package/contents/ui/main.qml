import QtQuick
import org.kde.plasma.plasmoid

Item {
    width: 200
    height: 200
    
    Rectangle {
        anchors.fill: parent
        color: "#3daee9"
        
        Text {
            anchors.centerIn: parent
            text: "Virtual Trackpad"
            color: "white"
            font.bold: true
        }
    }
}
