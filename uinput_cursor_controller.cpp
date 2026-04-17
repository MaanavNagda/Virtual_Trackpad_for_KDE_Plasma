#include "uinput_cursor_controller.h"
#include <QDebug>
#include <QGuiApplication>
#include <QScreen>

UInputCursorController::UInputCursorController(QObject *parent)
    : QObject(parent)
    , m_sensitivity(0.3)
    , m_velocityX(0.0)
    , m_velocityY(0.0)
    , m_uinputFd(-1)
{
    m_movementTimer = new QTimer(this);
    connect(m_movementTimer, &QTimer::timeout, this, &UInputCursorController::updateCursorPosition);
    m_movementTimer->setInterval(16); // ~60 FPS
    
    if (!initUInputDevice()) {
        qDebug() << "Failed to initialize uinput device";
    }
}

UInputCursorController::~UInputCursorController()
{
    cleanupUInputDevice();
}

bool UInputCursorController::initUInputDevice()
{
    // Open uinput device
    m_uinputFd = open("/dev/uinput", O_WRONLY | O_NONBLOCK);
    if (m_uinputFd < 0) {
        qDebug() << "Failed to open /dev/uinput:" << strerror(errno);
        return false;
    }

    // Enable mouse events
    ioctl(m_uinputFd, UI_SET_EVBIT, EV_KEY);
    ioctl(m_uinputFd, UI_SET_KEYBIT, BTN_LEFT);
    ioctl(m_uinputFd, UI_SET_KEYBIT, BTN_RIGHT);
    ioctl(m_uinputFd, UI_SET_KEYBIT, BTN_MIDDLE);
    
    ioctl(m_uinputFd, UI_SET_EVBIT, EV_REL);
    ioctl(m_uinputFd, UI_SET_RELBIT, REL_X);
    ioctl(m_uinputFd, UI_SET_RELBIT, REL_Y);

    // Create the uinput device
    memset(&m_uinputDev, 0, sizeof(m_uinputDev));
    strncpy(m_uinputDev.name, "Virtual Trackpad", UINPUT_MAX_NAME_SIZE);
    m_uinputDev.id.bustype = BUS_USB;
    m_uinputDev.id.vendor = 0x1234;
    m_uinputDev.id.product = 0x5678;
    m_uinputDev.id.version = 1;

    if (write(m_uinputFd, &m_uinputDev, sizeof(m_uinputDev)) < 0) {
        qDebug() << "Failed to write uinput device structure:" << strerror(errno);
        close(m_uinputFd);
        return false;
    }

    if (ioctl(m_uinputFd, UI_DEV_CREATE) < 0) {
        qDebug() << "Failed to create uinput device:" << strerror(errno);
        close(m_uinputFd);
        return false;
    }

    qDebug() << "UInput device created successfully";
    return true;
}

void UInputCursorController::cleanupUInputDevice()
{
    if (m_uinputFd >= 0) {
        ioctl(m_uinputFd, UI_DEV_DESTROY);
        close(m_uinputFd);
        m_uinputFd = -1;
    }
}

void UInputCursorController::moveCursor(qreal deltaX, qreal deltaY)
{
    if (m_uinputFd < 0) {
        qDebug() << "UInput device not initialized";
        return;
    }

    m_velocityX += deltaX * m_sensitivity;
    m_velocityY += deltaY * m_sensitivity;
    
    if (!m_movementTimer->isActive()) {
        m_movementTimer->start();
    }
}

void UInputCursorController::leftClick()
{
    if (m_uinputFd < 0) {
        qDebug() << "UInput device not initialized";
        return;
    }

    // Press left button
    emitEvent(EV_KEY, BTN_LEFT, 1);
    emitEvent(EV_SYN, SYN_REPORT, 0);
    
    // Release left button
    emitEvent(EV_KEY, BTN_LEFT, 0);
    emitEvent(EV_SYN, SYN_REPORT, 0);
    
    qDebug() << "Left click sent";
}

void UInputCursorController::rightClick()
{
    if (m_uinputFd < 0) {
        qDebug() << "UInput device not initialized";
        return;
    }

    // Press right button
    emitEvent(EV_KEY, BTN_RIGHT, 1);
    emitEvent(EV_SYN, SYN_REPORT, 0);
    
    // Release right button
    emitEvent(EV_KEY, BTN_RIGHT, 0);
    emitEvent(EV_SYN, SYN_REPORT, 0);
    
    qDebug() << "Right click sent";
}

void UInputCursorController::middleClick()
{
    if (m_uinputFd < 0) {
        qDebug() << "UInput device not initialized";
        return;
    }

    // Press middle button
    emitEvent(EV_KEY, BTN_MIDDLE, 1);
    emitEvent(EV_SYN, SYN_REPORT, 0);
    
    // Release middle button
    emitEvent(EV_KEY, BTN_MIDDLE, 0);
    emitEvent(EV_SYN, SYN_REPORT, 0);
    
    qDebug() << "Middle click sent";
}

void UInputCursorController::updateCursorPosition()
{
    if (m_uinputFd < 0) {
        qDebug() << "UInput device not initialized";
        return;
    }

    if (qAbs(m_velocityX) > 0.1 || qAbs(m_velocityY) > 0.1) {
        int deltaX = qRound(m_velocityX);
        int deltaY = qRound(m_velocityY);
        
        // Emit relative movement events
        if (deltaX != 0) {
            emitEvent(EV_REL, REL_X, deltaX);
        }
        if (deltaY != 0) {
            emitEvent(EV_REL, REL_Y, deltaY);
        }
        emitEvent(EV_SYN, SYN_REPORT, 0);
        
        // Apply friction
        m_velocityX *= 0.8;
        m_velocityY *= 0.8;
    } else {
        m_velocityX = 0.0;
        m_velocityY = 0.0;
        m_movementTimer->stop();
    }
}

void UInputCursorController::emitEvent(int type, int code, int value)
{
    struct input_event ev;
    memset(&ev, 0, sizeof(ev));
    
    gettimeofday(&ev.time, NULL);
    ev.type = type;
    ev.code = code;
    ev.value = value;
    
    if (write(m_uinputFd, &ev, sizeof(ev)) < 0) {
        qDebug() << "Failed to emit event:" << strerror(errno);
    }
}

qreal UInputCursorController::sensitivity() const
{
    return m_sensitivity;
}

void UInputCursorController::setSensitivity(qreal newSensitivity)
{
    if (qFuzzyCompare(m_sensitivity, newSensitivity))
        return;
    
    m_sensitivity = newSensitivity;
    emit sensitivityChanged();
}
