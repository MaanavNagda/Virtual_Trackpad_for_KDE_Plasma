#include "simple_cursor_controller.h"
#include <QDebug>

SimpleCursorController::SimpleCursorController(QObject *parent)
    : QObject(parent)
{
}

void SimpleCursorController::moveCursor(qreal deltaX, qreal deltaY)
{
    // Use xdotool to move the cursor relatively
    QString command = QString("xdotool mousemove_relative -- %1 %2")
                     .arg(qRound(deltaX))
                     .arg(qRound(deltaY));
    
    qDebug() << "Moving cursor with command:" << command;
    executeCommand(command);
}

void SimpleCursorController::leftClick()
{
    QString command = "xdotool click 1";
    qDebug() << "Left click with command:" << command;
    executeCommand(command);
}

void SimpleCursorController::rightClick()
{
    QString command = "xdotool click 3";
    qDebug() << "Right click with command:" << command;
    executeCommand(command);
}

void SimpleCursorController::middleClick()
{
    QString command = "xdotool click 2";
    qDebug() << "Middle click with command:" << command;
    executeCommand(command);
}

void SimpleCursorController::executeCommand(const QString &command)
{
    QProcess process;
    process.start("bash", QStringList() << "-c" << command);
    process.waitForFinished(100); // Wait up to 100ms
    
    if (process.exitCode() != 0) {
        qDebug() << "Command failed:" << command;
        qDebug() << "Error output:" << process.readAllStandardError();
    }
}
