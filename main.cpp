#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "utils.h"                                                          //for setContextProperty("utils"...), "extern" of _Utils def'd below:
QSharedPointer<Utils>                                   _Utils{};           //global pointer to shared data

int main(int argc, char *argv[])
{
#ifdef Q_OS_WIN  //for parity with https://github.com/QUItCoding/qnanopainter/commit/e8563866718eb0cc147088b95250f9d3cd1e6d85
    // Select between OpenGL and OpenGL ES (Angle)
    //QCoreApplication::setAttribute(Qt::AA_UseOpenGLES);
    QCoreApplication::setAttribute(Qt::AA_UseDesktopOpenGL);
#endif

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);

    Utils                                           utils;
    qmlRegisterSingletonInstance("com.nielsmayer.Utils", 1, 0,
                                                   "Utils",
                                                   &utils);
    _Utils.reset(                                  &utils,
                                                   &utilsDeleter);
    engine.load(url);

    return app.exec();
}
