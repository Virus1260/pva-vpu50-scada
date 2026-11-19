#include "PlcModbusClient.h"
#include <QDebug>
#include <QUrl>

PlcModbusClient::PlcModbusClient(QObject *parent)
    : QObject(parent)
    , m_modbusClient(new QModbusTcpClient(this))
    , m_pollTimer(new QTimer(this))
    , m_reconnectTimer(new QTimer(this))
    , m_plcHost("192.168.1.7")
    , m_plcPort(502)
    , m_serverAddress(1)
    , m_operatingMode("BENCH_MONITOR")
    , m_isConnected(false)
    , m_statusMessage("Initializing Modbus TCP Client...")
    , m_pollCycle(0)
    , m_packetsSent(0)
    , m_packetsReceived(0)
    , m_packetErrors(0)
    , m_lastLatencyMs(1)
{
    connect(m_modbusClient, &QModbusClient::stateChanged, this, &PlcModbusClient::onStateChanged);
    connect(m_modbusClient, &QModbusClient::errorOccurred, this, &PlcModbusClient::onErrorOccurred);

    connect(m_pollTimer, &QTimer::timeout, this, &PlcModbusClient::onPollTimerTick);
    m_reconnectTimer->setSingleShot(true);
    connect(m_reconnectTimer, &QTimer::timeout, this, &PlcModbusClient::connectToPlc);
}

PlcModbusClient::~PlcModbusClient()
{
    stopPolling();
    disconnectFromPlc();
}

bool PlcModbusClient::isConnected() const
{
    return m_isConnected;
}

QString PlcModbusClient::statusMessage() const
{
    return m_statusMessage;
}

QString PlcModbusClient::operatingMode() const
{
    return m_operatingMode;
}

void PlcModbusClient::setOperatingMode(const QString &mode)
{
    if (m_operatingMode != mode) {
        m_operatingMode = mode;
        if (m_operatingMode == "SIMULATION") {
            disconnectFromPlc();
            m_isConnected = false;
            m_statusMessage = "Simulation Mode Active (Software Virtual Skid)";
            emit connectionStateChanged(false, m_statusMessage);
        } else {
            connectToPlc();
        }
    }
}

QString PlcModbusClient::plcHost() const
{
    return m_plcHost;
}

void PlcModbusClient::setPlcHost(const QString &host)
{
    if (m_plcHost != host) {
        setPlcTarget(host, m_plcPort);
    }
}

int PlcModbusClient::plcPort() const
{
    return m_plcPort;
}

void PlcModbusClient::setPlcPort(int port)
{
    if (m_plcPort != port) {
        setPlcTarget(m_plcHost, port);
    }
}

void PlcModbusClient::setPlcTarget(const QString &host, int port)
{
    if (m_reconnectTimer && m_reconnectTimer->isActive()) {
        m_reconnectTimer->stop();
    }

    disconnectFromPlc();

    m_plcHost = host;
    m_plcPort = port;

    m_statusMessage = QString("Connecting to Delta AS332T PLC at %1:%2...").arg(m_plcHost).arg(m_plcPort);
    emit connectionStateChanged(false, m_statusMessage);

    if (m_operatingMode != "SIMULATION") {
        if (!m_modbusClient || m_modbusClient->state() == QModbusDevice::UnconnectedState) {
            connectToPlc();
        } else {
            // Allow asynchronous disconnect to settle before connecting to new target
            QTimer::singleShot(100, this, &PlcModbusClient::connectToPlc);
        }
    }
}

void PlcModbusClient::connectToPlc()
{
    if (m_operatingMode == "SIMULATION") {
        m_statusMessage = "Simulation Mode Active (Hardware Offline)";
        emit connectionStateChanged(false, m_statusMessage);
        return;
    }

    if (m_modbusClient->state() == QModbusDevice::ConnectedState) {
        return;
    }

    m_statusMessage = QString("Connecting to Delta AS332T PLC at %1:%2...").arg(m_plcHost).arg(m_plcPort);
    emit connectionStateChanged(false, m_statusMessage);

    m_modbusClient->setConnectionParameter(QModbusDevice::NetworkAddressParameter, m_plcHost);
    m_modbusClient->setConnectionParameter(QModbusDevice::NetworkPortParameter, m_plcPort);
    m_modbusClient->setTimeout(1500);
    m_modbusClient->setNumberOfRetries(2);

    if (!m_modbusClient->connectDevice()) {
        m_statusMessage = QString("Connection setup failed: %1").arg(m_modbusClient->errorString());
        emit connectionStateChanged(false, m_statusMessage);
        scheduleReconnect();
    }
}

void PlcModbusClient::disconnectFromPlc()
{
    if (m_modbusClient && m_modbusClient->state() != QModbusDevice::UnconnectedState) {
        m_modbusClient->disconnectDevice();
    }
    m_isConnected = false;
}

void PlcModbusClient::startPolling(int intervalMs)
{
    if (!m_pollTimer->isActive()) {
        m_pollTimer->start(intervalMs);
    }
}

void PlcModbusClient::stopPolling()
{
    if (m_pollTimer->isActive()) {
        m_pollTimer->stop();
    }
    if (m_reconnectTimer->isActive()) {
        m_reconnectTimer->stop();
    }
}

void PlcModbusClient::scheduleReconnect()
{
    if (m_operatingMode != "SIMULATION" && !m_reconnectTimer->isActive()) {
        m_reconnectTimer->start(3000); // Retry every 3 seconds
    }
}

qint16 PlcModbusClient::toSigned16(quint16 val) const
{
    return static_cast<qint16>(val);
}

void PlcModbusClient::onStateChanged(QModbusDevice::State state)
{
    if (state == QModbusDevice::ConnectedState) {
        m_isConnected = true;
        m_statusMessage = QString("ONLINE - Connected to Delta AS332T at %1:%2").arg(m_plcHost).arg(m_plcPort);
        emit connectionStateChanged(true, m_statusMessage);
        startPolling(100);
    } else if (state == QModbusDevice::UnconnectedState) {
        m_isConnected = false;
        m_statusMessage = QString("OFFLINE - Disconnected from %1:%2").arg(m_plcHost).arg(m_plcPort);
        emit connectionStateChanged(false, m_statusMessage);
        scheduleReconnect();
    }
}

void PlcModbusClient::onErrorOccurred(QModbusDevice::Error error)
{
    if (error != QModbusDevice::NoError) {
        m_statusMessage = QString("Modbus Error: %1").arg(m_modbusClient->errorString());
        emit connectionStateChanged(m_isConnected, m_statusMessage);
    }
}

void PlcModbusClient::onPollTimerTick()
{
    if (!m_isConnected || m_modbusClient->state() != QModbusDevice::ConnectedState) {
        return;
    }

    m_pollCycle++;

    // Step 1: Read Discrete Inputs X0.0 - X0.15 (Base 24576 = 0x6000)
    QModbusDataUnit readX0(QModbusDataUnit::DiscreteInputs, 24576, 16);
    if (auto *reply = m_modbusClient->sendReadRequest(readX0, m_serverAddress)) {
        m_packetsSent++;
        if (!reply->isFinished()) {
            connect(reply, &QModbusReply::finished, this, &PlcModbusClient::onReadDiscreteInputsFinished);
        } else {
            delete reply;
        }
    } else {
        m_packetErrors++;
    }

    // Step 2: Read Discrete Inputs X1.0 - X1.15 (Slot 1 AS16AM10N-A, Base 24592 = 0x6010)
    QModbusDataUnit readX1(QModbusDataUnit::DiscreteInputs, 24592, 16);
    if (auto *reply = m_modbusClient->sendReadRequest(readX1, m_serverAddress)) {
        m_packetsSent++;
        if (!reply->isFinished()) {
            connect(reply, &QModbusReply::finished, this, &PlcModbusClient::onReadExtensionInputsFinished);
        } else {
            delete reply;
        }
    } else {
        m_packetErrors++;
    }

    // Step 3: Read Physical Coils Y0.0 - Y0.15 (Base 40960 = 0xA000)
    QModbusDataUnit readY0(QModbusDataUnit::Coils, 40960, 16);
    if (auto *reply = m_modbusClient->sendReadRequest(readY0, m_serverAddress)) {
        m_packetsSent++;
        if (!reply->isFinished()) {
            connect(reply, &QModbusReply::finished, this, &PlcModbusClient::onReadCoilsFinished);
        } else {
            delete reply;
        }
    } else {
        m_packetErrors++;
    }

    // Step 4: Read Telemetry Holding Registers D0 - D19 (Base 0, count 20)
    QModbusDataUnit readD0(QModbusDataUnit::HoldingRegisters, 0, 20);
    if (auto *reply = m_modbusClient->sendReadRequest(readD0, m_serverAddress)) {
        m_packetsSent++;
        if (!reply->isFinished()) {
            connect(reply, &QModbusReply::finished, this, &PlcModbusClient::onReadTelemetryRegistersFinished);
        } else {
            delete reply;
        }
    } else {
        m_packetErrors++;
    }

    // Step 5: Read RTD Expansion Module D28060 - D28065 (Slot 4 AS06RTD-A, Base 28060, count 6)
    QModbusDataUnit readRtd(QModbusDataUnit::HoldingRegisters, 28060, 6);
    if (auto *reply = m_modbusClient->sendReadRequest(readRtd, m_serverAddress)) {
        m_packetsSent++;
        if (!reply->isFinished()) {
            connect(reply, &QModbusReply::finished, this, &PlcModbusClient::onReadRtdRegistersFinished);
        } else {
            delete reply;
        }
    } else {
        m_packetErrors++;
    }

    // Step 6: Read Analog Inputs Module D28020 - D28023 (Slot 2 AS04AD-A, Base 28020, count 4)
    QModbusDataUnit readAd(QModbusDataUnit::HoldingRegisters, 28020, 4);
    if (auto *reply = m_modbusClient->sendReadRequest(readAd, m_serverAddress)) {
        m_packetsSent++;
        if (!reply->isFinished()) {
            connect(reply, &QModbusReply::finished, this, &PlcModbusClient::onReadAnalogRegistersFinished);
        } else {
            delete reply;
        }
    } else {
        m_packetErrors++;
    }

    // Step 7: Read Analog Output Module D28040 - D28043 (Slot 3 AS04DA-A, Base 28040, count 4)
    QModbusDataUnit readDa(QModbusDataUnit::HoldingRegisters, 28040, 4);
    if (auto *reply = m_modbusClient->sendReadRequest(readDa, m_serverAddress)) {
        m_packetsSent++;
        if (!reply->isFinished()) {
            connect(reply, &QModbusReply::finished, this, &PlcModbusClient::onReadDaRegistersFinished);
        } else {
            delete reply;
        }
    } else {
        m_packetErrors++;
    }
}

void PlcModbusClient::onReadDiscreteInputsFinished()
{
    auto *reply = qobject_cast<QModbusReply *>(sender());
    if (!reply) return;

    if (reply->error() == QModbusDevice::NoError) {
        m_packetsReceived++;
        const QModbusDataUnit unit = reply->result();
        QVariantList x0List;
        for (uint i = 0; i < unit.valueCount(); ++i) {
            bool state = (unit.value(i) != 0);
            x0List.append(state);
            m_currentSweepData[QString("X0.%1").arg(i)] = state;
            m_currentSweepData[QString("bench.input.x0%1").arg(i, 2, 10, QChar('0'))] = state;
        }
        m_currentSweepData["digital_inputs_x0"] = x0List;
    } else {
        m_packetErrors++;
    }
    reply->deleteLater();
}

void PlcModbusClient::onReadExtensionInputsFinished()
{
    auto *reply = qobject_cast<QModbusReply *>(sender());
    if (!reply) return;

    if (reply->error() == QModbusDevice::NoError) {
        m_packetsReceived++;
        const QModbusDataUnit unit = reply->result();
        QVariantList x1List;
        for (uint i = 0; i < unit.valueCount(); ++i) {
            bool state = (unit.value(i) != 0);
            x1List.append(state);
            m_currentSweepData[QString("X1.%1").arg(i)] = state;
            m_currentSweepData[QString("bench.input.x1%1").arg(i, 2, 10, QChar('0'))] = state;
        }
        m_currentSweepData["digital_inputs_x1"] = x1List;
    } else {
        m_packetErrors++;
    }
    reply->deleteLater();
}

void PlcModbusClient::onReadCoilsFinished()
{
    auto *reply = qobject_cast<QModbusReply *>(sender());
    if (!reply) return;

    if (reply->error() == QModbusDevice::NoError) {
        m_packetsReceived++;
        const QModbusDataUnit unit = reply->result();
        QVariantList y0List;
        for (uint i = 0; i < unit.valueCount(); ++i) {
            bool state = (unit.value(i) != 0);
            y0List.append(state);
            m_currentSweepData[QString("Y0.%1").arg(i)] = state;
            m_currentSweepData[QString("bench.output.y0%1").arg(i, 2, 10, QChar('0'))] = state;
        }
        m_currentSweepData["digital_outputs_y0"] = y0List;
    } else {
        m_packetErrors++;
    }
    reply->deleteLater();
}

void PlcModbusClient::onReadTelemetryRegistersFinished()
{
    auto *reply = qobject_cast<QModbusReply *>(sender());
    if (!reply) return;

    if (reply->error() == QModbusDevice::NoError) {
        m_packetsReceived++;
        const QModbusDataUnit unit = reply->result();
        if (unit.valueCount() >= 6) {
            // D0: Agitator Speed PV (RPM)
            double agitSpeed = static_cast<double>(unit.value(0));
            m_currentSweepData["vpu.main.agitator_speed"] = agitSpeed;

            // D1: Homogenizer Speed PV (RPM)
            double homoSpeed = static_cast<double>(unit.value(1));
            m_currentSweepData["vpu.main.homogenizer_speed"] = homoSpeed;

            // D2: Vessel Temp PV (0.1 deg C)
            double vesselTemp = toSigned16(unit.value(2)) / 10.0;
            m_currentSweepData["vpu.main.temperature"] = vesselTemp;

            // D3: Jacket Temp PV (0.1 deg C)
            double jacketTemp = toSigned16(unit.value(3)) / 10.0;
            m_currentSweepData["vpu.jacket.temperature"] = jacketTemp;

            // D4: Vacuum Pressure PV (0.1 mbar)
            double vacuumPress = toSigned16(unit.value(4)) / 10.0;
            m_currentSweepData["vpu.main.vacuum_pressure"] = vacuumPress;

            // D5: Vessel Level PV (0.1 L)
            double vesselLevel = static_cast<double>(unit.value(5)) / 10.0;
            m_currentSweepData["vpu.main.level"] = vesselLevel;
        }

        m_currentSweepData["packets_sent"] = QVariant::fromValue(m_packetsSent);
        m_currentSweepData["packets_received"] = QVariant::fromValue(m_packetsReceived);
        m_currentSweepData["packet_errors"] = QVariant::fromValue(m_packetErrors);
        m_currentSweepData["latency_ms"] = m_lastLatencyMs;

        m_currentSweepData["cpu_battery_low"] = true; // Warning 16#0027 (RTC battery low)
        m_currentSweepData["plc_connected"] = true;
        m_currentSweepData["plc_status"] = m_statusMessage;
        m_currentSweepData["timestamp"] = QDateTime::currentDateTimeUtc().toString(Qt::ISODate);

        emit rawDataPolled(m_currentSweepData);
    } else {
        m_packetErrors++;
    }
    reply->deleteLater();
}

void PlcModbusClient::onReadDaRegistersFinished()
{
    auto *reply = qobject_cast<QModbusReply *>(sender());
    if (!reply) return;

    if (reply->error() == QModbusDevice::NoError) {
        const QModbusDataUnit unit = reply->result();
        if (unit.valueCount() >= 1) {
            quint16 ch0 = unit.value(0);
            if (ch0 == 6145) { // Error 16#1801
                m_currentSweepData["da_slot3_fault"] = true;
                m_currentSweepData["da_slot3_error_code"] = "16#1801 (External 24V abnormal)";
            } else {
                m_currentSweepData["da_slot3_fault"] = false;
                m_currentSweepData["da_slot3_error_code"] = "";
            }
        }
    }
    reply->deleteLater();
}

void PlcModbusClient::onReadRtdRegistersFinished()
{
    auto *reply = qobject_cast<QModbusReply *>(sender());
    if (!reply) return;

    if (reply->error() == QModbusDevice::NoError) {
        const QModbusDataUnit unit = reply->result();
        if (unit.valueCount() >= 1) {
            quint16 ch0 = unit.value(0);
            if (ch0 == 6145) { // Error 16#1801 (External voltage abnormal)
                m_currentSweepData["rtd_slot4_fault"] = true;
                m_currentSweepData["rtd_slot4_error_code"] = "16#1801 (External 24V abnormal)";
                m_currentSweepData["vpu.rtd.ch1_quality"] = "FAULT_1801";
                // Do NOT publish 6145 as valid temperature!
            } else {
                m_currentSweepData["rtd_slot4_fault"] = false;
                m_currentSweepData["vpu.rtd.ch1_quality"] = "GOOD";
                m_currentSweepData["vpu.rtd.ch1_temperature"] = toSigned16(ch0) / 10.0;
            }
        }
    }
    reply->deleteLater();
}

void PlcModbusClient::onReadAnalogRegistersFinished()
{
    auto *reply = qobject_cast<QModbusReply *>(sender());
    if (!reply) return;

    if (reply->error() == QModbusDevice::NoError) {
        const QModbusDataUnit unit = reply->result();
        if (unit.valueCount() >= 1) {
            quint16 ch0 = unit.value(0);
            if (ch0 == 6145) { // Error 16#1801
                m_currentSweepData["ad_slot2_fault"] = true;
                m_currentSweepData["ad_slot2_error_code"] = "16#1801 (External 24V abnormal)";
                m_currentSweepData["vpu.ad.ch1_quality"] = "FAULT_1801";
            } else {
                m_currentSweepData["ad_slot2_fault"] = false;
                m_currentSweepData["vpu.ad.ch1_quality"] = "GOOD";
                m_currentSweepData["vpu.ad.ch1_raw"] = ch0;
            }
        }
    }
    reply->deleteLater();
}

bool PlcModbusClient::writeHoldingRegister(int address, quint16 value, QString *errorMsg)
{
    if (m_operatingMode == "BENCH_MONITOR") {
        if (errorMsg) *errorMsg = "SAFETY INTERLOCK: Setpoint adjustment is prohibited in BENCH_MONITOR (Read-Only) mode.";
        return false;
    }

    if (!m_isConnected || m_modbusClient->state() != QModbusDevice::ConnectedState) {
        if (errorMsg) *errorMsg = "PLC is not connected over Modbus TCP.";
        return false;
    }

    QModbusDataUnit writeUnit(QModbusDataUnit::HoldingRegisters, address, 1);
    writeUnit.setValue(0, value);

    auto *reply = m_modbusClient->sendWriteRequest(writeUnit, m_serverAddress);
    if (!reply) {
        if (errorMsg) *errorMsg = QString("Send write request failed: %1").arg(m_modbusClient->errorString());
        return false;
    }

    connect(reply, &QModbusReply::finished, this, [this, reply, address]() {
        bool success = (reply->error() == QModbusDevice::NoError);
        QString err = success ? QString() : reply->errorString();
        emit writeCompleted(address, success, err);
        reply->deleteLater();
    });

    return true;
}

bool PlcModbusClient::writeCoil(int address, bool value, QString *errorMsg)
{
    if (m_operatingMode == "BENCH_MONITOR") {
        if (errorMsg) *errorMsg = "SAFETY INTERLOCK: Output control is prohibited in BENCH_MONITOR (Read-Only) mode.";
        return false;
    }

    // Prevent direct writes to Y0-Y15 while BENCH_CHASER_ST running light executes
    if (address >= 40960 && address <= 40975) {
        if (errorMsg) *errorMsg = "SAFETY INTERLOCK: Direct writes to physical Y outputs are blocked while BENCH_CHASER_ST runs.";
        return false;
    }

    if (!m_isConnected || m_modbusClient->state() != QModbusDevice::ConnectedState) {
        if (errorMsg) *errorMsg = "PLC is not connected over Modbus TCP.";
        return false;
    }

    QModbusDataUnit writeUnit(QModbusDataUnit::Coils, address, 1);
    writeUnit.setValue(0, value ? 1 : 0);

    auto *reply = m_modbusClient->sendWriteRequest(writeUnit, m_serverAddress);
    if (!reply) {
        if (errorMsg) *errorMsg = QString("Send write request failed: %1").arg(m_modbusClient->errorString());
        return false;
    }

    connect(reply, &QModbusReply::finished, this, [this, reply, address]() {
        bool success = (reply->error() == QModbusDevice::NoError);
        QString err = success ? QString() : reply->errorString();
        emit writeCompleted(address, success, err);
        reply->deleteLater();
    });

    return true;
}
