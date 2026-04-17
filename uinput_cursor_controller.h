#ifndef UINPUT_CURSOR_CONTROLLER_H
#define UINPUT_CURSOR_CONTROLLER_H

#include <QObject>
#include <QTimer>
#include <QPointF>
#include <linux/uinput.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

class UInputCursorController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(qreal sensitivity READ sensitivity WRITE setSensitivity NOTIFY sensitivityChanged)

public:
    explicit UInputCursorController(QObject *parent = nullptr);
    ~UInputCursorController();

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
    bool initUInputDevice();
    void cleanupUInputDevice();
    void emitEvent(int type, int code, int value);

    qreal m_sensitivity;
    qreal m_velocityX;
    qreal m_velocityY;
    QTimer *m_movementTimer;
    
    int m_uinputFd;
    struct uinput_user_dev m_uinputDev;
};

#endif // UINPUT_CURSOR_CONTROLLER_H
