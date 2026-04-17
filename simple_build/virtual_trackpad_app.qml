import QtQuick
import QtQuick.Controls
import QtQuick.Window

Window {
    id: window
    title: "Virtual Trackpad"
    width: 300
    height: 400
    visible: true
    flags: Qt.Window | Qt.WindowStaysOnTopHint
    
    property real sensitivity: 2.0
    property real lastX: 0
    property real lastY: 0
    
    // Timer for smooth cursor movement
    Timer {
        id: movementTimer
        interval: 16 // ~60 FPS
        running: false
        repeat: true
        
        property real velocityX: 0
        property real velocityY: 0
        
        onTriggered: {
            if (Math.abs(velocityX) > 0.1 || Math.abs(velocityY) > 0.1) {
                // Try multiple methods for cursor control
                try {
                    // Method 1: Qt.cursorPos (Qt 6)
                    if (typeof Qt.cursorPos !== 'undefined') {
                        var currentPos = Qt.cursorPos()
                        var newX = currentPos.x + velocityX * sensitivity
                        var newY = currentPos.y + velocityY * sensitivity
                        
                        // Keep cursor within screen bounds
                        newX = Math.max(0, Math.min(newX, Screen.width || 1920))
                        newY = Math.max(0, Math.min(newY, Screen.height || 1080))
                        
                        Qt.cursorPos = Qt.point(newX, newY)
                    }
                    // Method 2: Call system command (fallback)
                    else {
                        // Use xdotool on X11 or appropriate Wayland tool
                        var cmd = "xdotool mousemove_relative -- " + Math.round(velocityX * sensitivity) + " " + Math.round(velocityY * sensitivity)
                        console.log("Moving cursor with:", cmd)
                        // Execute the command using Qt's process API
                        try {
                            var process = Qt.createQmlObject('import QtQuick; Timer {}', root, "processTimer")
                            process.interval = 1
                            process.repeat = false
                            process.triggered.connect(function() {
                                // Use a workaround to execute system command
                                console.log("Executing:", cmd)
                                // The actual command execution would need a C++ backend
                                // For now, this shows the command that would be executed
                            })
                            process.start()
                        } catch (e) {
                            console.log("Failed to execute command:", e)
                        }
                    }
                } catch (e) {
                    console.log("Cursor movement not available:", e)
                    console.log("Try running with: qmlscene6 virtual_trackpad_app.qml")
                    console.log("On Wayland, cursor control may require additional permissions")
                }
                
                // Apply friction
                velocityX *= 0.8
                velocityY *= 0.8
            } else {
                velocityX = 0
                velocityY = 0
                movementTimer.running = false
            }
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#2b2b2b"
        border.color: "#3daee9"
        border.width: 2
        radius: 8
        
        // Title bar for dragging
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
                    
                    // Use the C++ cursor controller for actual system cursor movement
                    if (typeof cursorController !== 'undefined') {
                        cursorController.moveCursor(deltaX, deltaY)
                    } else {
                        // Fallback to QML-only method
                        movementTimer.velocityX += deltaX
                        movementTimer.velocityY += deltaY
                        
                        if (!movementTimer.running) {
                            movementTimer.running = true
                        }
                    }
                    
                    lastX = mouseX
                    lastY = mouseY
                }
                
                onReleased: {
                    // Friction will naturally slow down the movement
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
                    onClicked: {
                        if (typeof cursorController !== 'undefined') {
                            cursorController.leftClick()
                        } else {
                            console.log("Left click")
                        }
                    }
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
                    onClicked: {
                        if (typeof cursorController !== 'undefined') {
                            cursorController.middleClick()
                        } else {
                            console.log("Middle click")
                        }
                    }
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
                    onClicked: {
                        if (typeof cursorController !== 'undefined') {
                            cursorController.rightClick()
                        } else {
                            console.log("Right click")
                        }
                    }
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
