#include "cursormanager.h"
#include <QGuiApplication>
#include <QScreen>
#include <QDebug>

CursorManager::CursorManager(QObject *parent)
    : QObject(parent)
    , m_sensitivity(2.0)
    , m_velocityX(0.0)
    , m_velocityY(0.0)
{
    m_movementTimer = new QTimer(this);
    connect(m_movementTimer, &QTimer::timeout, this, &CursorManager::updateCursorPosition);
    m_movementTimer->setInterval(16); // ~60 FPS
}

void CursorManager::moveCursor(qreal deltaX, qreal deltaY)
{
    m_velocityX += deltaX * m_sensitivity;
    m_velocityY += deltaY * m_sensitivity;
    
    if (!m_movementTimer->isActive()) {
        m_movementTimer->start();
    }
}

void CursorManager::leftClick()
{
    // Simulate left mouse click using system events
    // This is a simplified version - in production, you'd want to use
    // platform-specific APIs for proper click simulation
    qDebug() << "Left click simulated";
}

void CursorManager::rightClick()
{
    qDebug() << "Right click simulated";
}

void CursorManager::middleClick()
{
    qDebug() << "Middle click simulated";
}

void CursorManager::updateCursorPosition()
{
    if (qAbs(m_velocityX) > 0.1 || qAbs(m_velocityY) > 0.1) {
        QPoint currentPos = QCursor::pos();
        QPoint newPos(
            qBound(0, currentPos.x() + qRound(m_velocityX), QGuiApplication::primaryScreen()->geometry().right()),
            qBound(0, currentPos.y() + qRound(m_velocityY), QGuiApplication::primaryScreen()->geometry().bottom())
        );
        
        QCursor::setPos(newPos);
        
        // Apply friction
        m_velocityX *= 0.8;
        m_velocityY *= 0.8;
    } else {
        m_velocityX = 0.0;
        m_velocityY = 0.0;
        m_movementTimer->stop();
    }
}

qreal CursorManager::sensitivity() const
{
    return m_sensitivity;
}

void CursorManager::setSensitivity(qreal newSensitivity)
{
    if (qFuzzyCompare(m_sensitivity, newSensitivity))
        return;
    
    m_sensitivity = newSensitivity;
    emit sensitivityChanged();
}
