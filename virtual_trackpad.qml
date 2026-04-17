import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: window
    title: "Virtual Trackpad"
    width: 300
    height: 400
    visible: true
    
    // Make window stay on top
    flags: Qt.Window | Qt.WindowStaysOnTopHint
    
    property real sensitivity: 2.0
    property real lastX: 0
    property real lastY: 0
    
    // Simple cursor control (for now just logs)
    function moveCursor(deltaX, deltaY) {
        console.log("Move cursor by:", deltaX, deltaY)
        // TODO: Implement actual cursor movement
    }
    
    function leftClick() {
        console.log("Left click")
        // TODO: Implement actual left click
    }
    
    function rightClick() {
        console.log("Right click")
        // TODO: Implement actual right click
    }
    
    function middleClick() {
        console.log("Middle click")
        // TODO: Implement actual middle click
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#2b2b2b"
        border.color: "#3daee9"
        border.width: 2
        radius: 8
        
        // Title bar
        Rectangle {
            id: titleBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 30
            color: "#3daee9"
            radius: 6
            
            Text {
                anchors.centerIn: parent
                text: "Virtual Trackpad"
                color: "white"
                font.bold: true
            }
            
            MouseArea {
                property real clickX: 0
                property real clickY: 0
                
                anchors.fill: parent
                onPressed: {
                    clickX = mouseX
                    clickY = mouseY
                }
                
                onPositionChanged: {
                    window.x += mouseX - clickX
                    window.y += mouseY - clickY
                }
            }
        }
        
        // Trackpad area
        Rectangle {
            id: trackpadArea
            anchors.top: titleBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: buttonRow.top
            anchors.margins: 10
            color: "#323232"
            border.color: "#555555"
            border.width: 1
            radius: 4
            
            Text {
                anchors.centerIn: parent
                text: "Touch Area\n(Drag to move cursor)"
                color: "#888888"
                font.italic: true
                visible: !trackpadMouseArea.containsMouse
                horizontalAlignment: Text.AlignHCenter
            }
            
            MouseArea {
                id: trackpadMouseArea
                anchors.fill: parent
                
                onPressed: {
                    lastX = mouseX
                    lastY = mouseY
                }
                
                onPositionChanged: {
                    var deltaX = mouseX - lastX
                    var deltaY = mouseY - lastY
                    moveCursor(deltaX, deltaY)
                    lastX = mouseX
                    lastY = mouseY
                }
                
                // Visual feedback
                Rectangle {
                    width: 20
                    height: 20
                    radius: 10
                    color: "#3daee9"
                    opacity: 0.6
                    visible: trackpadMouseArea.pressed
                    x: trackpadMouseArea.mouseX - 10
                    y: trackpadMouseArea.mouseY - 10
                }
            }
        }
        
        // Button row
        Row {
            id: buttonRow
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 10
            spacing: 10
            
            // Left click button
            Rectangle {
                width: 50
                height: 50
                color: leftMouseArea.pressed ? "#3daee9" : "#4a4a4a"
                border.color: "#3daee9"
                border.width: 1
                radius: 8
                
                Text {
                    anchors.centerIn: parent
                    text: "L"
                    color: "white"
                    font.bold: true
                }
                
                MouseArea {
                    id: leftMouseArea
                    anchors.fill: parent
                    onClicked: leftClick()
                }
            }
            
            // Middle click button
            Rectangle {
                width: 50
                height: 50
                color: middleMouseArea.pressed ? "#3daee9" : "#4a4a4a"
                border.color: "#3daee9"
                border.width: 1
                radius: 8
                
                Text {
                    anchors.centerIn: parent
                    text: "M"
                    color: "white"
                    font.bold: true
                }
                
                MouseArea {
                    id: middleMouseArea
                    anchors.fill: parent
                    onClicked: middleClick()
                }
            }
            
            // Right click button
            Rectangle {
                width: 50
                height: 50
                color: rightMouseArea.pressed ? "#3daee9" : "#4a4a4a"
                border.color: "#3daee9"
                border.width: 1
                radius: 8
                
                Text {
                    anchors.centerIn: parent
                    text: "R"
                    color: "white"
                    font.bold: true
                }
                
                MouseArea {
                    id: rightMouseArea
                    anchors.fill: parent
                    onClicked: rightClick()
                }
            }
        }
        
        // Status indicator
        Text {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 5
            text: "v1.0"
            color: "#888888"
            font.pixelSize: 10
        }
    }
}
