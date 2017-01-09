#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QUrl>

int main(int argc, char** argv)
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    // Add the binary location to the import path so that
    // we can run from the build directory
    engine.addImportPath(app.applicationDirPath());
    engine.load(QUrl("qrc:/qml/Main.qml"));

    return app.exec();
}
