import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

Item {
    id: root
    
    width: 300
    height: 400
    
    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    
    Rectangle {
        anchors.fill: parent
        color: PlasmaCore.Theme.backgroundColor
        border.color: PlasmaCore.Theme.highlightColor
        border.width: 2
        radius: 8
        
        Text {
            anchors.centerIn: parent
            text: "Virtual Trackpad\n\nPlasma 6 Compatible\n\nClick buttons below:"
            color: PlasmaCore.Theme.textColor
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 16
        }
        
        Row {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 20
            spacing: 10
            
            Rectangle {
                width: 50
                height: 50
                color: "lightblue"
                radius: 8
                Text {
                    anchors.centerIn: parent
                    text: "L"
                    color: "black"
                    font.bold: true
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: console.log("Left click")
                }
            }
            
            Rectangle {
                width: 50
                height: 50
                color: "lightgreen"
                radius: 8
                Text {
                    anchors.centerIn: parent
                    text: "M"
                    color: "black"
                    font.bold: true
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: console.log("Middle click")
                }
            }
            
            Rectangle {
                width: 50
                height: 50
                color: "lightcoral"
                radius: 8
                Text {
                    anchors.centerIn: parent
                    text: "R"
                    color: "black"
                    font.bold: true
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: console.log("Right click")
                }
            }
        }
    }
}
