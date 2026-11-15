// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QDir>
#include <QTimer>

#include "autogen/environment.h"
#include "ScadaEngine.h"

int main(int argc, char *argv[])
{
    set_qt_environment();
    QApplication app(argc, argv);
    app.setOrganizationName("PVASystems");
    app.setApplicationName("PVA VPU-50 Industrial SCADA");

    QCommandLineParser parser;
    parser.setApplicationDescription("PVA Systems VPU-50 Industrial SCADA Native Qt 6 Desktop Client");
    parser.addHelpOption();

    QCommandLineOption modeOption(QStringList() << "m" << "mode",
                                  "Operating mode (SIMULATION, BENCH_MONITOR, BENCH_CONTROL)",
                                  "mode", "BENCH_MONITOR");
    parser.addOption(modeOption);

    QCommandLineOption ipOption(QStringList() << "plc-ip",
                                "Target Delta AS332T PLC IP address",
                                "ip", "192.168.1.7");
    parser.addOption(ipOption);

    QCommandLineOption portOption(QStringList() << "plc-port",
                                  "Modbus TCP port",
                                  "port", "502");
    parser.addOption(portOption);

    QCommandLineOption verifyOption("verify-qml", "Load QML offscreen to verify syntax, then exit cleanly.");
    parser.addOption(verifyOption);

    parser.process(app);

    QString mode = parser.value(modeOption);
    QString plcIp = parser.value(ipOption);
    int plcPort = parser.value(portOption).toInt();
    if (plcPort <= 0) plcPort = 502;
    bool verifyOnly = parser.isSet(verifyOption);

    QString runtimeDir = QDir::current().filePath("runtime");

    ScadaEngine scadaEngine(runtimeDir, mode, plcIp, plcPort, &app);
    QObject::connect(&app, &QCoreApplication::aboutToQuit, &scadaEngine, &ScadaEngine::cleanup);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("Scada", &scadaEngine);

    const QUrl url(mainQmlFile);
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated, &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);

    engine.addImportPath(QCoreApplication::applicationDirPath() + "/qml");
    engine.addImportPath(":/");
    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        scadaEngine.cleanup();
        return -1;
    }

    if (verifyOnly) {
        QTimer::singleShot(200, [&app, &scadaEngine]() {
            scadaEngine.cleanup();
            app.quit();
        });
    }

    return app.exec();
}
