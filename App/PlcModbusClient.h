#ifndef PLC_MODBUS_CLIENT_H
#define PLC_MODBUS_CLIENT_H

#include <QObject>
#include <QModbusTcpClient>
#include <QModbusDataUnit>
#include <QModbusReply>
#include <QTimer>
#include <QVariantMap>
#include <QDateTime>

class PlcModbusClient : public QObject
{
    Q_OBJECT

public:
    explicit PlcModbusClient(QObject *parent = nullptr);
    ~PlcModbusClient() override;

    bool isConnected() const;
    QString statusMessage() const;
    QString operatingMode() const;
    void setOperatingMode(const QString &mode);

    QString plcHost() const;
    void setPlcHost(const QString &host);
    int plcPort() const;
    void setPlcPort(int port);

    // Operational Commands
    void connectToPlc();
    void disconnectFromPlc();
    void startPolling(int intervalMs = 100);
    void stopPolling();

    // Setpoint & Output writes (permitted ONLY in BENCH_CONTROL mode)
    bool writeHoldingRegister(int address, quint16 value, QString *errorMsg = nullptr);
    bool writeCoil(int address, bool value, QString *errorMsg = nullptr);

signals:
    void connectionStateChanged(bool connected, const QString &statusText);
    void rawDataPolled(const QVariantMap &rawData);
    void writeCompleted(int address, bool success, const QString &errorMsg);

private slots:
    void onStateChanged(QModbusDevice::State state);
    void onErrorOccurred(QModbusDevice::Error error);
    void onPollTimerTick();
    void onReadDiscreteInputsFinished();
    void onReadExtensionInputsFinished();
    void onReadCoilsFinished();
    void onReadTelemetryRegistersFinished();
    void onReadRtdRegistersFinished();
    void onReadAnalogRegistersFinished();

private:
    void scheduleReconnect();
    qint16 toSigned16(quint16 val) const;

    QModbusTcpClient *m_modbusClient;
    QTimer *m_pollTimer;
    QTimer *m_reconnectTimer;

    QString m_plcHost;
    int m_plcPort;
    int m_serverAddress; // Modbus slave ID = 1
    QString m_operatingMode; // "SIMULATION", "BENCH_MONITOR", "BENCH_CONTROL"

    bool m_isConnected;
    QString m_statusMessage;
    int m_pollCycle;

    // Temporary storage during a single poll sweep
    QVariantMap m_currentSweepData;
};

#endif // PLC_MODBUS_CLIENT_H
