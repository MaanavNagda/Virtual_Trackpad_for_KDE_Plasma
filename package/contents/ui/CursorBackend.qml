import QtQuick 2.15
import org.kde.kirigami 2.20 as Kirigami

QtObject {
    id: root
    
    // Register this backend to be available in QML
    // This will be connected to the C++ backend
    
    signal cursorMoved(int x, int y)
    signal leftClicked()
    signal rightClicked()
    signal middleClicked()
    
    function moveCursor(deltaX, deltaY) {
        // This will be handled by the C++ backend
        cursorMoved(deltaX, deltaY)
    }
    
    function leftClick() {
        leftClicked()
    }
    
    function rightClick() {
        rightClicked()
    }
    
    function middleClick() {
        middleClicked()
    }
}
