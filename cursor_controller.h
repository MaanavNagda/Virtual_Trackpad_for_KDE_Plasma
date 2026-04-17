#ifndef CURSOR_CONTROLLER_H
#define CURSOR_CONTROLLER_H

#include <QObject>
#include <QCursor>
#include <QPoint>
#include <QTimer>

class CursorController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(qreal sensitivity READ sensitivity WRITE setSensitivity NOTIFY sensitivityChanged)

public:
    explicit CursorController(QObject *parent = nullptr);

    Q_INVOKABLE void moveCursor(qreal deltaX, qreal deltaY);
    Q_INVOKABLE void leftClick();
    Q_INVOKABLE void rightClick();
    Q_INVOKABLE void middleClick();

    qreal sensitivity() const;
    void setSensitivity(qreal newSensitivity);

signals:
    void sensitivityChanged();

private slots:
    void updateCursorPosition();

private:
    qreal m_sensitivity;
    qreal m_velocityX;
    qreal m_velocityY;
    QTimer *m_movementTimer;
};

#endif // CURSOR_CONTROLLER_H
