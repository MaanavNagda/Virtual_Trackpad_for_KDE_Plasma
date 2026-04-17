import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid

Item {
    id: root
    
    width: 300
    height: 400
    
    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    Plasmoid.backgroundHints: "NoBackground"
    
    property real sensitivity: 2.0
    property bool isDragging: false
    property real lastX: 0
    property real lastY: 0
    
    // Simple backend for cursor control (without actual cursor movement for now)
    QtObject {
        id: cursorBackend
        
        function moveCursor(deltaX, deltaY) {
            console.log("Moving cursor by:", deltaX, deltaY)
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
    }
    
    // Main container with draggable functionality
    Rectangle {
        id: mainContainer
        anchors.fill: parent
        color: PlasmaCore.Theme.backgroundColor
        border.color: PlasmaCore.Theme.highlightColor
        border.width: 2
        radius: 8
        
        // Title bar for dragging
        Rectangle {
            id: titleBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 30
            color: PlasmaCore.Theme.highlightColor
            radius: 6
            
            Text {
                anchors.centerIn: parent
                text: "Virtual Trackpad"
                color: PlasmaCore.Theme.textColor
                font.bold: true
            }
            
            MouseArea {
                anchors.fill: parent
                onPressed: {
                    root.isDragging = true
                    root.lastX = mouseX
                    root.lastY = mouseY
                }
                
                onPositionChanged: {
                    if (root.isDragging) {
                        var deltaX = mouseX - root.lastX
                        var deltaY = mouseY - root.lastY
                        root.x += deltaX
                        root.y += deltaY
                    }
                }
                
                onReleased: {
                    root.isDragging = false
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
            color: PlasmaCore.Theme.alternateBackgroundColor
            border.color: PlasmaCore.Theme.disabledTextColor
            border.width: 1
            radius: 4
            
            Text {
                anchors.centerIn: parent
                text: "Touch Area\n(Drag to move cursor)"
                color: PlasmaCore.Theme.disabledTextColor
                font.italic: true
                visible: !trackpadMouseArea.containsMouse
                horizontalAlignment: Text.AlignHCenter
            }
            
            MouseArea {
                id: trackpadMouseArea
                anchors.fill: parent
                
                onPressed: {
                    root.lastX = mouseX
                    root.lastY = mouseY
                }
                
                onPositionChanged: {
                    var deltaX = mouseX - root.lastX
                    var deltaY = mouseY - root.lastY
                    cursorBackend.moveCursor(deltaX, deltaY)
                    root.lastX = mouseX
                    root.lastY = mouseY
                }
                
                // Visual feedback
                Rectangle {
                    width: 20
                    height: 20
                    radius: 10
                    color: PlasmaCore.Theme.highlightColor
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
            PlasmaComponents.Button {
                id: leftButton
                text: "L"
                implicitWidth: 40
                implicitHeight: 40
                
                background: Rectangle {
                    color: leftButton.pressed ? PlasmaCore.Theme.highlightColor : 
                           leftButton.hovered ? PlasmaCore.Theme.alternateBackgroundColor : 
                           PlasmaCore.Theme.backgroundColor
                    border.color: PlasmaCore.Theme.textColor
                    border.width: 1
                    radius: 4
                }
                
                contentItem: Text {
                    text: leftButton.text
                    color: PlasmaCore.Theme.textColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                }
                
                onClicked: {
                    cursorBackend.leftClick()
                }
            }
            
            // Middle click button
            PlasmaComponents.Button {
                id: middleButton
                text: "M"
                implicitWidth: 40
                implicitHeight: 40
                
                background: Rectangle {
                    color: middleButton.pressed ? PlasmaCore.Theme.highlightColor : 
                           middleButton.hovered ? PlasmaCore.Theme.alternateBackgroundColor : 
                           PlasmaCore.Theme.backgroundColor
                    border.color: PlasmaCore.Theme.textColor
                    border.width: 1
                    radius: 4
                }
                
                contentItem: Text {
                    text: middleButton.text
                    color: PlasmaCore.Theme.textColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                }
                
                onClicked: {
                    cursorBackend.middleClick()
                }
            }
            
            // Right click button
            PlasmaComponents.Button {
                id: rightButton
                text: "R"
                implicitWidth: 40
                implicitHeight: 40
                
                background: Rectangle {
                    color: rightButton.pressed ? PlasmaCore.Theme.highlightColor : 
                           rightButton.hovered ? PlasmaCore.Theme.alternateBackgroundColor : 
                           PlasmaCore.Theme.backgroundColor
                    border.color: PlasmaCore.Theme.textColor
                    border.width: 1
                    radius: 4
                }
                
                contentItem: Text {
                    text: rightButton.text
                    color: PlasmaCore.Theme.textColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                }
                
                onClicked: {
                    cursorBackend.rightClick()
                }
            }
        }
        
        // Status indicator
        Text {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 5
            text: "v1.0"
            color: PlasmaCore.Theme.disabledTextColor
            font.pixelSize: 10
        }
    }
}
