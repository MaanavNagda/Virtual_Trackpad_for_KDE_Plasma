#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QFileInfo>
#include "uinput_cursor_controller.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    
    // Register the cursor controller for use in QML
    UInputCursorController cursorController;
    engine.rootContext()->setContextProperty("cursorController", &cursorController);
    
    // Get the directory where the executable is located
    QString appDir = QFileInfo(argv[0]).absolutePath();
    QString qmlPath = appDir + "/virtual_trackpad_app.qml";
    
    const QUrl url = QUrl::fromLocalFile(qmlPath);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
