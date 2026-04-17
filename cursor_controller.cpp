#include "cursor_controller.h"
#include <QGuiApplication>
#include <QScreen>
#include <QDebug>

CursorController::CursorController(QObject *parent)
    : QObject(parent)
    , m_sensitivity(2.0)
    , m_velocityX(0.0)
    , m_velocityY(0.0)
{
    m_movementTimer = new QTimer(this);
    connect(m_movementTimer, &QTimer::timeout, this, &CursorController::updateCursorPosition);
    m_movementTimer->setInterval(16); // ~60 FPS
}

void CursorController::moveCursor(qreal deltaX, qreal deltaY)
{
    m_velocityX += deltaX * m_sensitivity;
    m_velocityY += deltaY * m_sensitivity;
    
    if (!m_movementTimer->isActive()) {
        m_movementTimer->start();
    }
}

void CursorController::leftClick()
{
    qDebug() << "Left click - would simulate actual mouse click";
    // TODO: Implement actual click simulation using system APIs
}

void CursorController::rightClick()
{
    qDebug() << "Right click - would simulate actual mouse click";
    // TODO: Implement actual click simulation using system APIs
}

void CursorController::middleClick()
{
    qDebug() << "Middle click - would simulate actual mouse click";
    // TODO: Implement actual click simulation using system APIs
}

void CursorController::updateCursorPosition()
{
    if (qAbs(m_velocityX) > 0.1 || qAbs(m_velocityY) > 0.1) {
        QPoint currentPos = QCursor::pos();
        QPoint newPos(
            qBound(0, currentPos.x() + qRound(m_velocityX), QGuiApplication::primaryScreen()->geometry().right()),
            qBound(0, currentPos.y() + qRound(m_velocityY), QGuiApplication::primaryScreen()->geometry().bottom())
        );
        
        QCursor::setPos(newPos);
        qDebug() << "Moving cursor to:" << newPos;
        
        // Apply friction
        m_velocityX *= 0.8;
        m_velocityY *= 0.8;
    } else {
        m_velocityX = 0.0;
        m_velocityY = 0.0;
        m_movementTimer->stop();
    }
}

qreal CursorController::sensitivity() const
{
    return m_sensitivity;
}

void CursorController::setSensitivity(qreal newSensitivity)
{
    if (qFuzzyCompare(m_sensitivity, newSensitivity))
        return;
    
    m_sensitivity = newSensitivity;
    emit sensitivityChanged();
}
