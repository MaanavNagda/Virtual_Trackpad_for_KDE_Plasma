#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "cursor_controller.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    
    // Register the cursor controller for use in QML
    CursorController cursorController;
    engine.rootContext()->setContextProperty("cursorController", &cursorController);
    
    const QUrl url(QStringLiteral("qrc:/virtual_trackpad_app.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
