#ifndef SIMPLE_CURSOR_CONTROLLER_H
#define SIMPLE_CURSOR_CONTROLLER_H

#include <QObject>
#include <QProcess>

class SimpleCursorController : public QObject
{
    Q_OBJECT

public:
    explicit SimpleCursorController(QObject *parent = nullptr);

    Q_INVOKABLE void moveCursor(qreal deltaX, qreal deltaY);
    Q_INVOKABLE void leftClick();
    Q_INVOKABLE void rightClick();
    Q_INVOKABLE void middleClick();

private:
    void executeCommand(const QString &command);
};

#endif // SIMPLE_CURSOR_CONTROLLER_H
