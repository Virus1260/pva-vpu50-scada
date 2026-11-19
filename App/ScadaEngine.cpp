#include "ScadaEngine.h"

#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QSqlError>
#include <QDebug>
#include <QNetworkInterface>
#include <QHostAddress>
#include <QTcpSocket>
#include <QProcess>
#include <QElapsedTimer>
#include <QThread>
#include <QRegularExpression>
#include <cmath>

ScadaEngine::ScadaEngine(const QString &runtimeDir,
                         const QString &mode,
                         const QString &plcHost,
                         int plcPort,
                         QObject *parent)
    : QObject(parent)
    , m_runtimeDir(runtimeDir)
    , m_operatingMode(mode)
    , m_currentUser("operator")
    , m_currentRole("operator")
    , m_tagRegistry(nullptr)
    , m_modbusClient(nullptr)
    , m_tickTimer(new QTimer(this))
    , m_lastAuditHash("GENESIS_BLOCK_00000000000000000000000000000000")
    , m_simTemp(25.0)
    , m_simJacketTemp(24.5)
    , m_simVacuum(0.0)
    , m_simAgitSpeed(0.0)
    , m_simHomoSpeed(0.0)
    , m_targetAgitSpeed(0.0)
    , m_targetHomoSpeed(0.0)
    , m_targetTemp(25.0)
    , m_targetVacuum(0.0)
    , m_isScanning(false)
{
    QDir().mkpath(m_runtimeDir);

    // Dynamic machine-unique salt for 21 CFR Part 11 audit integrity
    m_auditSalt = QCryptographicHash::hash(
        QString("PVA_VPU50_%1_%2").arg(m_runtimeDir).arg(QSysInfo::machineHostName()).toUtf8(),
        QCryptographicHash::Sha256
    );

    // Initialize Tag Registry
    QString catalogPath = QDir(m_runtimeDir).filePath("tag_catalog.json");
    if (!QFile::exists(catalogPath)) {
        catalogPath = "scada/config/tag_catalog.json";
    }
    m_tagRegistry = new TagRegistry(catalogPath, this);

    // Initialize Native Modbus Client
    m_modbusClient = new PlcModbusClient(this);
    m_modbusClient->setPlcHost(plcHost);
    m_modbusClient->setPlcPort(plcPort);
    m_modbusClient->setOperatingMode(m_operatingMode);

    connect(m_modbusClient, &PlcModbusClient::rawDataPolled, this, &ScadaEngine::onPlcTelemetryReceived);
    connect(m_modbusClient, &PlcModbusClient::connectionStateChanged, this, &ScadaEngine::onPlcConnectionChanged);

    // Initialize Database
    initDatabase();

    // Set Initial Telemetry State
    m_telemetry["operating_mode"] = m_operatingMode;
    m_telemetry["plc_connected"] = m_modbusClient->isConnected();
    m_telemetry["plc_status"] = m_modbusClient->statusMessage();
    m_telemetry["vpu.main.temperature"] = m_simTemp;
    m_telemetry["vpu.jacket.temperature"] = m_simJacketTemp;
    m_telemetry["vpu.main.vacuum_pressure"] = m_simVacuum;
    m_telemetry["vpu.main.agitator_speed"] = m_simAgitSpeed;
    m_telemetry["vpu.main.homogenizer_speed"] = m_simHomoSpeed;
    m_telemetry["vpu.main.level"] = 65.0;

    // Start Real-time Tick Timer (500ms cycle)
    connect(m_tickTimer, &QTimer::timeout, this, &ScadaEngine::onTick);
    m_tickTimer->start(500);

    // Trigger initial connect if in hardware modes
    if (m_operatingMode != "SIMULATION") {
        m_modbusClient->connectToPlc();
    }
}

ScadaEngine::~ScadaEngine()
{
    cleanup();
}

QVariantMap ScadaEngine::telemetry() const
{
    return m_telemetry;
}

QString ScadaEngine::operatingMode() const
{
    return m_operatingMode;
}

bool ScadaEngine::isPlcConnected() const
{
    return m_modbusClient ? m_modbusClient->isConnected() : false;
}

QString ScadaEngine::plcStatusText() const
{
    return m_modbusClient ? m_modbusClient->statusMessage() : QString("Offline");
}

QString ScadaEngine::plcHost() const
{
    return m_modbusClient ? m_modbusClient->plcHost() : QString("192.168.1.7");
}

void ScadaEngine::setPlcHost(const QString &host)
{
    if (m_modbusClient && m_modbusClient->plcHost() != host) {
        setPlcTarget(host, m_modbusClient->plcPort());
    }
}

int ScadaEngine::plcPort() const
{
    return m_modbusClient ? m_modbusClient->plcPort() : 502;
}

void ScadaEngine::setPlcPort(int port)
{
    if (m_modbusClient && m_modbusClient->plcPort() != port) {
        setPlcTarget(m_modbusClient->plcHost(), port);
    }
}

quint64 ScadaEngine::packetsSent() const
{
    return m_modbusClient ? m_modbusClient->packetsSent() : 0;
}

quint64 ScadaEngine::packetsReceived() const
{
    return m_modbusClient ? m_modbusClient->packetsReceived() : 0;
}

quint64 ScadaEngine::packetErrors() const
{
    return m_modbusClient ? m_modbusClient->packetErrors() : 0;
}

int ScadaEngine::plcLatencyMs() const
{
    return m_modbusClient ? m_modbusClient->lastLatencyMs() : 1;
}

QVariantList ScadaEngine::digitalOutputs() const
{
    return m_telemetry.value("digital_outputs_y0").toList();
}

QVariantList ScadaEngine::digitalInputs() const
{
    return m_telemetry.value("digital_inputs_x0").toList();
}

QVariantList ScadaEngine::extensionInputs() const
{
    return m_telemetry.value("digital_inputs_x1").toList();
}

void ScadaEngine::setPlcTarget(const QString &host, int port)
{
    if (!m_modbusClient) return;
    m_modbusClient->setPlcTarget(host, port);
    m_telemetry["plc_host"] = host;
    m_telemetry["plc_port"] = port;
    m_telemetry["plc_connected"] = m_modbusClient->isConnected();
    m_telemetry["plc_status"] = m_modbusClient->statusMessage();
    emit plcConfigChanged();
    emit telemetryUpdated();
}

QString ScadaEngine::getDeltaHardwareRackJson() const
{
    QJsonArray rack;
    bool connected = isPlcConnected();

    // PS Module
    QJsonObject ps;
    ps["slot"] = "PS";
    ps["name"] = "AS-PS02";
    ps["desc"] = "Power Supply Module";
    ps["status"] = connected ? "NORMAL" : "OFFLINE";
    ps["detail"] = "24VDC Output, 2000mA Capacity";
    rack.append(ps);

    // CPU Module
    QJsonObject cpu;
    cpu["slot"] = "CPU";
    cpu["name"] = "AS332T-A";
    cpu["desc"] = "Main CPU (16 DI / 16 DO Transistor)";
    cpu["status"] = connected ? "RUNNING" : "OFFLINE";
    bool batteryLow = m_telemetry.value("cpu_battery_low", true).toBool();
    cpu["warning"] = (connected && batteryLow) ? "16#0027 (Battery Low - RTC Reset to 2000-01-01)" : "";
    cpu["detail"] = QString("Firmware v1.08.01, Modbus Port %1").arg(plcPort());
    rack.append(cpu);

    // Function Card 2
    QJsonObject card2;
    card2["slot"] = "CARD 2";
    card2["name"] = "AS-FFTP01";
    card2["desc"] = "Ethernet Function Card";
    card2["status"] = connected ? "LINK ACTIVE" : "DISCONNECTED";
    card2["ip"] = plcHost();
    card2["mac"] = "56:F0:3A:39:10:CC";
    card2["detail"] = QString("Modbus TCP (%1) / OPC UA (4840) / HTTP (80)").arg(plcPort());
    rack.append(card2);

    // Slot 1: Digital Inputs
    QJsonObject slot1;
    slot1["slot"] = "SLOT 1";
    slot1["name"] = "AS16AM10N-A";
    slot1["desc"] = "16 Channel Digital Input (X1.0-X1.15)";
    slot1["status"] = connected ? "NORMAL" : "OFFLINE";
    slot1["detail"] = "24VDC Sink/Source Inputs";
    rack.append(slot1);

    // Slot 2: Analog Inputs
    QJsonObject slot2;
    slot2["slot"] = "SLOT 2";
    slot2["name"] = "AS04AD-A";
    slot2["desc"] = "4 Channel Analog Input (D28020-D28039)";
    bool adFault = m_telemetry.value("ad_slot2_fault", true).toBool();
    if (!connected) {
        slot2["status"] = "OFFLINE";
        slot2["error"] = "";
    } else if (adFault) {
        slot2["status"] = "FAULT 16#1801";
        slot2["error"] = "16#1801 (External voltage abnormal - check +24V terminal)";
    } else {
        slot2["status"] = "NORMAL";
        slot2["error"] = "";
    }
    slot2["detail"] = "Channels CH1-CH4 (0-10V / 4-20mA)";
    rack.append(slot2);

    // Slot 3: Analog Outputs
    QJsonObject slot3;
    slot3["slot"] = "SLOT 3";
    slot3["name"] = "AS04DA-A";
    slot3["desc"] = "4 Channel Analog Output (D28040-D28059)";
    bool daFault = m_telemetry.value("da_slot3_fault", true).toBool();
    if (!connected) {
        slot3["status"] = "OFFLINE";
        slot3["error"] = "";
    } else if (daFault) {
        slot3["status"] = "FAULT 16#1801";
        slot3["error"] = "16#1801 (External voltage abnormal - check +24V terminal)";
    } else {
        slot3["status"] = "NORMAL";
        slot3["error"] = "";
    }
    slot3["detail"] = "Channels CH1-CH4 (0-10V / 4-20mA)";
    rack.append(slot3);

    // Slot 4: RTD Inputs
    QJsonObject slot4;
    slot4["slot"] = "SLOT 4";
    slot4["name"] = "AS06RTD-A";
    slot4["desc"] = "6 Channel RTD Input (D28060-D28079)";
    bool rtdFault = m_telemetry.value("rtd_slot4_fault", true).toBool();
    if (!connected) {
        slot4["status"] = "OFFLINE";
        slot4["error"] = "";
    } else if (rtdFault) {
        slot4["status"] = "FAULT 16#1801";
        slot4["error"] = "16#1801 (External voltage abnormal - check +24V terminal)";
    } else {
        slot4["status"] = "NORMAL";
        slot4["error"] = "";
    }
    slot4["detail"] = "PT100/PT1000 Temperature Sensors";
    rack.append(slot4);

    return QString::fromUtf8(QJsonDocument(rack).toJson(QJsonDocument::Compact));
}

QString ScadaEngine::performNetworkScan()
{
    // 1. Detect local network interfaces to identify active subnet
    QString localSubnetPrefix;
    QString localHostIp;
    QString localHostMac = "Local Host";

    const QList<QNetworkInterface> interfaces = QNetworkInterface::allInterfaces();
    for (const QNetworkInterface &iface : interfaces) {
        if (!iface.flags().testFlag(QNetworkInterface::IsUp) ||
            !iface.flags().testFlag(QNetworkInterface::IsRunning) ||
            iface.flags().testFlag(QNetworkInterface::IsLoopBack)) {
            continue;
        }
        for (const QNetworkAddressEntry &entry : iface.addressEntries()) {
            const QHostAddress ip = entry.ip();
            if (ip.protocol() == QAbstractSocket::IPv4Protocol && !ip.isLoopback()) {
                const QString ipStr = ip.toString();
                if (ipStr.startsWith("192.168.1.") || localSubnetPrefix.isEmpty()) {
                    localHostIp = ipStr;
                    int lastDot = ipStr.lastIndexOf('.');
                    if (lastDot > 0) {
                        localSubnetPrefix = ipStr.left(lastDot + 1);
                    }
                    if (!iface.hardwareAddress().isEmpty()) {
                        localHostMac = iface.hardwareAddress();
                    }
                }
            }
        }
    }
    if (localHostIp.isEmpty()) {
        localHostIp = "192.168.1.10";
        localSubnetPrefix = "192.168.1.";
    }

    // 2. Query ARP table via QProcess 'arp -a'
    struct ArpEntry {
        QString ip;
        QString mac;
    };
    QList<ArpEntry> arpEntries;

    QProcess arpProc;
    arpProc.start("arp", QStringList() << "-a");
    if (arpProc.waitForFinished(1200)) {
        const QString arpOut = QString::fromLocal8Bit(arpProc.readAllStandardOutput());
        const QStringList lines = arpOut.split(QRegularExpression("[\r\n]+"), Qt::SkipEmptyParts);
        const QRegularExpression ipRegex(R"((\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+([0-9a-fA-F:-]{11,17}))");
        for (const QString &line : lines) {
            auto match = ipRegex.match(line);
            if (match.hasMatch()) {
                QString ip = match.captured(1);
                QString mac = match.captured(2).replace('-', ':').toUpper();
                if (!ip.endsWith(".255") && !ip.startsWith("224.") && !ip.startsWith("239.") && !ip.startsWith("255.") && mac != "FF:FF:FF:FF:FF:FF") {
                    arpEntries.append({ip, mac});
                }
            }
        }
    }

    // 3. Assemble target candidate IPs to test
    QStringList candidateIps;
    auto addCandidate = [&candidateIps](const QString &ip) {
        if (!ip.isEmpty() && !candidateIps.contains(ip)) {
            candidateIps.append(ip);
        }
    };

    if (m_modbusClient && !m_modbusClient->plcHost().isEmpty()) {
        addCandidate(m_modbusClient->plcHost());
    }
    addCandidate("192.168.1.7");
    addCandidate("192.168.1.5");
    addCandidate(localHostIp);

    for (const auto &entry : arpEntries) {
        if (entry.ip.startsWith(localSubnetPrefix)) {
            addCandidate(entry.ip);
        }
    }

    auto getMacForIp = [&](const QString &ip) -> QString {
        if (ip == localHostIp) return localHostMac;
        for (const auto &entry : arpEntries) {
            if (entry.ip == ip) return entry.mac;
        }
        if (ip == "192.168.1.7") return "56:F0:3A:39:10:CC";
        if (ip == "192.168.1.5") return "00:18:23:E0:41:A2";
        return "Dynamic ARP";
    };

    // Helper for fast port testing with 100ms timeout
    auto testPort = [](const QString &host, int port, int timeoutMs, int &outRttMs) -> bool {
        QTcpSocket socket;
        QElapsedTimer timer;
        timer.start();
        socket.connectToHost(host, static_cast<quint16>(port));
        bool ok = socket.waitForConnected(timeoutMs);
        outRttMs = ok ? static_cast<int>(timer.elapsed()) : -1;
        if (ok) {
            socket.disconnectFromHost();
        } else {
            socket.abort();
        }
        return ok;
    };

    // 4. Test ports and assemble JSON payload
    QJsonArray devicesArr;
    for (const QString &ip : candidateIps) {
        bool isLocal = (ip == localHostIp);
        QString mac = getMacForIp(ip);

        bool has502 = false;
        bool has80 = false;
        bool has4840 = false;
        int rtt502 = -1;
        int rtt80 = -1;
        int rtt4840 = -1;

        if (!isLocal) {
            has502 = testPort(ip, 502, 100, rtt502);
            has80 = testPort(ip, 80, 100, rtt80);
            has4840 = testPort(ip, 4840, 100, rtt4840);
        }

        int bestRtt = -1;
        if (has502 && (bestRtt < 0 || rtt502 < bestRtt)) bestRtt = rtt502;
        if (has80 && (bestRtt < 0 || rtt80 < bestRtt)) bestRtt = rtt80;
        if (has4840 && (bestRtt < 0 || rtt4840 < bestRtt)) bestRtt = rtt4840;

        QJsonObject obj;
        obj["ip"] = ip;
        obj["mac"] = mac;
        obj["modbus_502"] = has502;
        obj["http_80"] = has80;
        obj["opcua_4840"] = has4840;

        if (isLocal) {
            obj["device"] = "Host PC (Local SCADA Station)";
            obj["status"] = "LOCAL HOST";
            obj["rtt_ms"] = 0;
        } else if (has502) {
            if (mac.startsWith("56:F0:3A") || mac.startsWith("56-F0-3A") || ip == "192.168.1.7") {
                obj["device"] = "Delta AS-FFTP01 Ethernet Card";
            } else {
                obj["device"] = "Delta AS Series PLC";
            }
            obj["status"] = "ACTIVE LINK";
            obj["rtt_ms"] = (bestRtt >= 0 ? bestRtt : 1);
        } else if (ip == "192.168.1.5") {
            obj["device"] = "Delta AS332T-A CPU Main Port (HWCONFIG Default)";
            obj["status"] = "PORT UNLINKED";
            obj["rtt_ms"] = -1;
        } else if (ip == "192.168.1.7") {
            obj["device"] = "Delta AS-FFTP01 Ethernet Card";
            obj["status"] = "PORT UNLINKED";
            obj["rtt_ms"] = -1;
        } else if (has80 || has4840) {
            obj["device"] = QString("Industrial Automation Node (%1)").arg(ip);
            obj["status"] = "ACTIVE LINK";
            obj["rtt_ms"] = (bestRtt >= 0 ? bestRtt : 1);
        } else {
            obj["device"] = QString("Network Device (%1)").arg(ip);
            obj["status"] = "REACHABLE";
            obj["rtt_ms"] = 1;
        }

        devicesArr.append(obj);
    }

    return QString::fromUtf8(QJsonDocument(devicesArr).toJson(QJsonDocument::Compact));
}

void ScadaEngine::startNetworkScan()
{
    if (m_isScanning) return;
    m_isScanning = true;

    QThread *worker = QThread::create([this]() {
        QString res = performNetworkScan();
        QMetaObject::invokeMethod(this, [this, res]() {
            m_isScanning = false;
            m_lastScannedDevicesJson = res;
            emit networkScanFinished(res);
        }, Qt::QueuedConnection);
    });
    connect(worker, &QThread::finished, worker, &QObject::deleteLater);
    worker->start();
}

QString ScadaEngine::probeSubnetDevicesJson()
{
    if (!m_lastScannedDevicesJson.isEmpty()) {
        return m_lastScannedDevicesJson;
    }
    m_lastScannedDevicesJson = performNetworkScan();
    return m_lastScannedDevicesJson;
}

QString ScadaEngine::activeBatchId() const
{
    return m_activeBatchId;
}

QString ScadaEngine::activeRecipeName() const
{
    return m_activeBatchId.isEmpty() ? QString() : QString("Batch Mixing Process");
}

int ScadaEngine::currentStepIndex() const
{
    return m_activeBatchId.isEmpty() ? 0 : 1;
}

int ScadaEngine::totalSteps() const
{
    return m_activeBatchId.isEmpty() ? 0 : 5;
}

bool ScadaEngine::recipeRunning() const
{
    return !m_activeBatchId.isEmpty();
}

void ScadaEngine::setOperatingMode(const QString &mode)
{
    if (m_operatingMode != mode) {
        QString oldMode = m_operatingMode;
        m_operatingMode = mode;
        m_modbusClient->setOperatingMode(mode);
        m_telemetry["operating_mode"] = mode;

        QVariantMap before, after;
        before["operating_mode"] = oldMode;
        after["operating_mode"] = mode;
        logAuditEvent("OPERATIONAL_MODE_CHANGED", "SYSTEM", "VPU-50", QString("Mode changed to %1").arg(mode), before, after);

        emit telemetryUpdated();
    }
}

void ScadaEngine::initDatabase()
{
    QString dbPath = QDir(m_runtimeDir).filePath("scada.db");
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", "scada_connection");
    db.setDatabaseName(dbPath);

    if (!db.open()) {
        qWarning() << "Failed to open SQLite database:" << db.lastError().text();
        return;
    }

    QSqlQuery q(db);
    q.exec("CREATE TABLE IF NOT EXISTS audit_events ("
           "id INTEGER PRIMARY KEY AUTOINCREMENT, "
           "timestamp TEXT, "
           "actor_id TEXT, "
           "action TEXT, "
           "object_type TEXT, "
           "object_id TEXT, "
           "reason TEXT, "
           "before_val TEXT, "
           "after_val TEXT, "
           "hash TEXT, "
           "prev_hash TEXT)");

    q.exec("CREATE TABLE IF NOT EXISTS batches ("
           "id TEXT PRIMARY KEY, "
           "name TEXT, "
           "operator_id TEXT, "
           "start_time TEXT, "
           "end_time TEXT, "
           "status TEXT)");

    q.exec("CREATE TABLE IF NOT EXISTS historian_samples ("
           "batch_id TEXT, "
           "timestamp TEXT, "
           "tag_id TEXT, "
           "value REAL)");

    // Retrieve last hash for chain continuity
    if (q.exec("SELECT hash FROM audit_events ORDER BY id DESC LIMIT 1") && q.next()) {
        m_lastAuditHash = q.value(0).toString();
    }
}

void ScadaEngine::logAuditEvent(const QString &action,
                                const QString &objectType,
                                const QString &objectId,
                                const QString &reason,
                                const QVariantMap &before,
                                const QVariantMap &after)
{
    QString ts = QDateTime::currentDateTimeUtc().toString(Qt::ISODate);
    QString beforeJson = QString::fromUtf8(QJsonDocument(QJsonObject::fromVariantMap(before)).toJson(QJsonDocument::Compact));
    QString afterJson = QString::fromUtf8(QJsonDocument(QJsonObject::fromVariantMap(after)).toJson(QJsonDocument::Compact));

    // SHA-256 Hash Chain: Hash(prev_hash + timestamp + actor + action + object_id + before + after + salt)
    QByteArray payload = m_lastAuditHash.toUtf8()
                       + ts.toUtf8()
                       + m_currentUser.toUtf8()
                       + action.toUtf8()
                       + objectId.toUtf8()
                       + beforeJson.toUtf8()
                       + afterJson.toUtf8()
                       + m_auditSalt;

    QString currentHash = QString::fromUtf8(QCryptographicHash::hash(payload, QCryptographicHash::Sha256).toHex());

    QSqlDatabase db = QSqlDatabase::database("scada_connection");
    if (db.isOpen()) {
        QSqlQuery q(db);
        q.prepare("INSERT INTO audit_events (timestamp, actor_id, action, object_type, object_id, reason, before_val, after_val, hash, prev_hash) "
                  "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        q.addBindValue(ts);
        q.addBindValue(m_currentUser);
        q.addBindValue(action);
        q.addBindValue(objectType);
        q.addBindValue(objectId);
        q.addBindValue(reason);
        q.addBindValue(beforeJson);
        q.addBindValue(afterJson);
        q.addBindValue(currentHash);
        q.addBindValue(m_lastAuditHash);
        q.exec();
    }

    m_lastAuditHash = currentHash;
    emit auditUpdated();
}

bool ScadaEngine::loginUser(const QString &userId, const QString &roleId)
{
    QString oldUser = m_currentUser;
    QString oldRole = m_currentRole;
    m_currentUser = userId;
    m_currentRole = roleId;

    QVariantMap before, after;
    before["user"] = oldUser;
    before["role"] = oldRole;
    after["user"] = userId;
    after["role"] = roleId;

    logAuditEvent("USER_AUTHENTICATED", "USER_SESSION", userId, "Operator login", before, after);
    return true;
}

bool ScadaEngine::setProcessSetpoint(const QString &tagId, double value, const QString &reason)
{
    // Safety Interlock: Prohibit writes in BENCH_MONITOR mode
    if (m_operatingMode == "BENCH_MONITOR") {
        qWarning() << "READ_ONLY_LOCK: Parameter adjustment is prohibited in BENCH_MONITOR mode.";
        return false;
    }

    if (!m_tagRegistry->hasTag(tagId)) {
        return false;
    }

    QVariantMap limits = m_tagRegistry->tagLimits(tagId);
    double minVal = limits.value("minimum", 0.0).toDouble();
    double maxVal = limits.value("maximum", 100.0).toDouble();
    if (value < minVal || value > maxVal) {
        qWarning() << "Setpoint outside valid engineering range:" << value << "[" << minVal << "," << maxVal << "]";
        return false;
    }

    double oldVal = m_telemetry.value(tagId, 0.0).toDouble();

    // In BENCH_CONTROL mode, write directly to Delta PLC Modbus registers
    if (m_operatingMode == "BENCH_CONTROL") {
        if (tagId == "vpu.main.agitator_speed") {
            m_modbusClient->writeHoldingRegister(50, static_cast<quint16>(value));
        } else if (tagId == "vpu.main.homogenizer_speed") {
            m_modbusClient->writeHoldingRegister(51, static_cast<quint16>(value));
        } else if (tagId == "vpu.main.temperature") {
            m_modbusClient->writeHoldingRegister(52, static_cast<quint16>(std::round(value * 10.0)));
        } else if (tagId == "vpu.main.vacuum_pressure") {
            m_modbusClient->writeHoldingRegister(54, static_cast<quint16>(std::round(value * 10.0)));
        }
    }

    // In SIMULATION mode, update simulation targets
    if (m_operatingMode == "SIMULATION") {
        if (tagId == "vpu.main.agitator_speed") m_targetAgitSpeed = value;
        else if (tagId == "vpu.main.homogenizer_speed") m_targetHomoSpeed = value;
        else if (tagId == "vpu.main.temperature") m_targetTemp = value;
        else if (tagId == "vpu.main.vacuum_pressure") m_targetVacuum = value;
    }

    m_telemetry[tagId] = value;
    m_tagRegistry->updateLiveValue(tagId, value, "GOOD");

    QVariantMap before, after;
    before["value"] = oldVal;
    after["value"] = value;
    logAuditEvent("SETPOINT_MODIFIED", "PROCESS_TAG", tagId, reason.isEmpty() ? "Manual adjustment" : reason, before, after);

    emit telemetryUpdated();
    return true;
}

bool ScadaEngine::acknowledgeAlarm(const QString &alarmId, const QString &comment)
{
    QVariantMap before, after;
    before["alarm_state"] = "ACTIVE_UNACKNOWLEDGED";
    after["alarm_state"] = "ACKNOWLEDGED";

    logAuditEvent("ALARM_ACKNOWLEDGED", "ALARM", alarmId, comment.isEmpty() ? "Operator acknowledgement" : comment, before, after);
    emit alarmsUpdated();
    return true;
}

QString ScadaEngine::startBatch(const QString &batchName)
{
    m_activeBatchId = QString("BATCH-%1").arg(QDateTime::currentSecsSinceEpoch());

    QSqlDatabase db = QSqlDatabase::database("scada_connection");
    if (db.isOpen()) {
        QSqlQuery q(db);
        q.prepare("INSERT INTO batches (id, name, operator_id, start_time, status) VALUES (?, ?, ?, ?, ?)");
        q.addBindValue(m_activeBatchId);
        q.addBindValue(batchName);
        q.addBindValue(m_currentUser);
        q.addBindValue(QDateTime::currentDateTimeUtc().toString(Qt::ISODate));
        q.addBindValue("RUNNING");
        q.exec();
    }

    QVariantMap before, after;
    after["batch_id"] = m_activeBatchId;
    after["batch_name"] = batchName;
    logAuditEvent("BATCH_STARTED", "BATCH", m_activeBatchId, "Batch process initiated", before, after);

    emit batchListUpdated();
    emit recipeStateUpdated();
    return m_activeBatchId;
}

bool ScadaEngine::endBatch(const QString &batchId, const QString &status)
{
    if (m_activeBatchId == batchId) {
        m_activeBatchId.clear();
    }

    QSqlDatabase db = QSqlDatabase::database("scada_connection");
    if (db.isOpen()) {
        QSqlQuery q(db);
        q.prepare("UPDATE batches SET end_time = ?, status = ? WHERE id = ?");
        q.addBindValue(QDateTime::currentDateTimeUtc().toString(Qt::ISODate));
        q.addBindValue(status);
        q.addBindValue(batchId);
        q.exec();
    }

    QVariantMap before, after;
    before["batch_state"] = "RUNNING";
    after["batch_state"] = status;
    logAuditEvent("BATCH_ENDED", "BATCH", batchId, QString("Batch status: %1").arg(status), before, after);

    emit batchListUpdated();
    emit recipeStateUpdated();
    return true;
}

QString ScadaEngine::getBatchTelemetryJson(const QString &batchId)
{
    QJsonArray arr;
    QSqlDatabase db = QSqlDatabase::database("scada_connection");
    if (db.isOpen()) {
        QSqlQuery q(db);
        q.prepare("SELECT timestamp, tag_id, value FROM historian_samples WHERE batch_id = ? ORDER BY timestamp ASC");
        q.addBindValue(batchId);
        if (q.exec()) {
            while (q.next()) {
                QJsonObject obj;
                obj["timestamp"] = q.value(0).toString();
                obj["tag_id"] = q.value(1).toString();
                obj["value"] = q.value(2).toDouble();
                arr.append(obj);
            }
        }
    }
    return QString::fromUtf8(QJsonDocument(arr).toJson(QJsonDocument::Compact));
}

QString ScadaEngine::getBatchesJson()
{
    QJsonArray arr;
    QSqlDatabase db = QSqlDatabase::database("scada_connection");
    if (db.isOpen()) {
        QSqlQuery q(db);
        if (q.exec("SELECT id, name, operator_id, start_time, end_time, status FROM batches ORDER BY start_time DESC")) {
            while (q.next()) {
                QJsonObject obj;
                obj["id"] = q.value(0).toString();
                obj["name"] = q.value(1).toString();
                obj["operator_id"] = q.value(2).toString();
                obj["start_time"] = q.value(3).toString();
                obj["end_time"] = q.value(4).toString();
                obj["status"] = q.value(5).toString();
                arr.append(obj);
            }
        }
    }
    return QString::fromUtf8(QJsonDocument(arr).toJson(QJsonDocument::Compact));
}

QString ScadaEngine::getAuditEventsJson()
{
    QJsonArray arr;
    QSqlDatabase db = QSqlDatabase::database("scada_connection");
    if (db.isOpen()) {
        QSqlQuery q(db);
        if (q.exec("SELECT timestamp, actor_id, action, object_type, object_id, reason, before_val, after_val, hash FROM audit_events ORDER BY id DESC LIMIT 100")) {
            while (q.next()) {
                QJsonObject obj;
                obj["timestamp"] = q.value(0).toString();
                obj["actor_id"] = q.value(1).toString();
                obj["action"] = q.value(2).toString();
                obj["object_type"] = q.value(3).toString();
                obj["object_id"] = q.value(4).toString();
                obj["reason"] = q.value(5).toString();
                obj["before"] = q.value(6).toString();
                obj["after"] = q.value(7).toString();
                obj["hash"] = q.value(8).toString();
                arr.append(obj);
            }
        }
    }
    return QString::fromUtf8(QJsonDocument(arr).toJson(QJsonDocument::Compact));
}

QString ScadaEngine::verifyAuditChainJson()
{
    QSqlDatabase db = QSqlDatabase::database("scada_connection");
    if (!db.isOpen()) {
        return "{\"valid\": false, \"message\": \"Database connection unavailable.\"}";
    }

    QSqlQuery q(db);
    if (!q.exec("SELECT timestamp, actor_id, action, object_id, before_val, after_val, hash, prev_hash FROM audit_events ORDER BY id ASC")) {
        return "{\"valid\": false, \"message\": \"Query execution failed.\"}";
    }

    int count = 0;
    QString expectedPrev = "GENESIS_BLOCK_00000000000000000000000000000000";

    while (q.next()) {
        QString ts = q.value(0).toString();
        QString actor = q.value(1).toString();
        QString action = q.value(2).toString();
        QString objId = q.value(3).toString();
        QString beforeVal = q.value(4).toString();
        QString afterVal = q.value(5).toString();
        QString recordedHash = q.value(6).toString();
        QString prevHash = q.value(7).toString();

        if (prevHash != expectedPrev) {
            return QString("{\"valid\": false, \"message\": \"Audit chain broken at record %1: prev_hash mismatch.\"}").arg(count + 1);
        }

        QByteArray payload = prevHash.toUtf8()
                           + ts.toUtf8()
                           + actor.toUtf8()
                           + action.toUtf8()
                           + objId.toUtf8()
                           + beforeVal.toUtf8()
                           + afterVal.toUtf8()
                           + m_auditSalt;

        QString computedHash = QString::fromUtf8(QCryptographicHash::hash(payload, QCryptographicHash::Sha256).toHex());
        if (computedHash != recordedHash) {
            return QString("{\"valid\": false, \"message\": \"Audit record %1 signature mismatch (tampering detected).\"}").arg(count + 1);
        }

        expectedPrev = recordedHash;
        count++;
    }

    QJsonObject res;
    res["valid"] = true;
    res["message"] = QString("Audit trail integrity verified: %1 cryptographic records intact.").arg(count);
    res["record_count"] = count;
    return QString::fromUtf8(QJsonDocument(res).toJson(QJsonDocument::Compact));
}

QString ScadaEngine::getActiveAlarmsJson()
{
    QJsonArray arr;
    // Check main process parameters against configured tag limits
    QStringList alarmTags = {"vpu.main.temperature", "vpu.main.vacuum_pressure", "vpu.main.agitator_speed", "vpu.main.homogenizer_speed"};
    for (const QString &tagId : alarmTags) {
        if (!m_tagRegistry->hasTag(tagId)) continue;
        TagDefinition def = m_tagRegistry->getDefinition(tagId);
        double val = m_telemetry.value(tagId, 0.0).toDouble();

        if (val > def.alarmHigh) {
            QJsonObject al;
            al["id"] = QString("ALM_%1_HIGH").arg(tagId);
            al["tag"] = tagId;
            al["severity"] = "CRITICAL";
            al["message"] = QString("%1 High Limit Exceeded (%2 %3)").arg(def.displayName).arg(val, 0, 'f', 1).arg(def.unit);
            al["timestamp"] = QDateTime::currentDateTimeUtc().toString(Qt::ISODate);
            arr.append(al);
        } else if (val < def.alarmLow && def.alarmLow > def.minVal) {
            QJsonObject al;
            al["id"] = QString("ALM_%1_LOW").arg(tagId);
            al["tag"] = tagId;
            al["severity"] = "CRITICAL";
            al["message"] = QString("%1 Low Limit Violation (%2 %3)").arg(def.displayName).arg(val, 0, 'f', 1).arg(def.unit);
            al["timestamp"] = QDateTime::currentDateTimeUtc().toString(Qt::ISODate);
            arr.append(al);
        }
    }
    return QString::fromUtf8(QJsonDocument(arr).toJson(QJsonDocument::Compact));
}

QString ScadaEngine::getRecipesJson()
{
    return "[]";
}

QString ScadaEngine::getDigitalIoStatusJson()
{
    QJsonObject root;
    root["outputs"] = QJsonArray::fromVariantList(m_telemetry.value("digital_outputs_y0").toList());
    root["inputs"] = QJsonArray::fromVariantList(m_telemetry.value("digital_inputs_x0").toList());
    root["extension_inputs"] = QJsonArray::fromVariantList(m_telemetry.value("digital_inputs_x1").toList());
    return QString::fromUtf8(QJsonDocument(root).toJson(QJsonDocument::Compact));
}

QString ScadaEngine::setDigitalOutput(int index, bool state, bool force)
{
    if (m_operatingMode == "BENCH_MONITOR") {
        return "{\"success\": false, \"error\": \"SAFETY INTERLOCK: Output control is prohibited in BENCH_MONITOR mode.\"}";
    }

    // Protect outputs 0..15 while BENCH_CHASER_ST program runs on PLC
    if (index >= 0 && index <= 15) {
        return "{\"success\": false, \"error\": \"SAFETY INTERLOCK: Direct writes to physical Y0-Y15 are blocked while PLC chaser program executes.\"}";
    }

    QString err;
    bool ok = m_modbusClient->writeCoil(40960 + index, state, &err);
    QJsonObject res;
    res["success"] = ok;
    if (!ok) res["error"] = err;
    return QString::fromUtf8(QJsonDocument(res).toJson(QJsonDocument::Compact));
}

QVariant ScadaEngine::tagValue(const QString &tagId, const QVariant &defaultVal) const
{
    return m_tagRegistry->tagValue(tagId, defaultVal);
}

QString ScadaEngine::tagQuality(const QString &tagId) const
{
    return m_tagRegistry->tagQuality(tagId);
}

QString ScadaEngine::tagUnit(const QString &tagId) const
{
    return m_tagRegistry->tagUnit(tagId);
}

QVariantMap ScadaEngine::tagLimits(const QString &tagId) const
{
    return m_tagRegistry->tagLimits(tagId);
}

QString ScadaEngine::getAllTagsJson() const
{
    return m_tagRegistry->getAllTagsJson();
}

QString ScadaEngine::saveTagJson(const QString &tagJsonStr)
{
    QString err;
    bool ok = m_tagRegistry->saveTagJson(tagJsonStr, &err);
    if (ok) {
        logAuditEvent("TAG_CONFIG_MODIFIED", "CONFIGURATION", "tag_catalog", "Tag catalog updated via I/O Editor", QVariantMap(), QVariantMap());
        return "{\"success\": true}";
    }
    return QString("{\"success\": false, \"error\": \"%1\"}").arg(err);
}

bool ScadaEngine::removeTag(const QString &tagId)
{
    bool ok = m_tagRegistry->removeTag(tagId);
    if (ok) {
        logAuditEvent("TAG_DELETED", "CONFIGURATION", tagId, "Tag removed via I/O Editor", QVariantMap(), QVariantMap());
    }
    return ok;
}

QVariantMap ScadaEngine::testEvaluateTag(const QString &tagId, double rawVal) const
{
    return m_tagRegistry->testEvaluateRaw(tagId, rawVal);
}

void ScadaEngine::cleanup()
{
    if (m_tickTimer && m_tickTimer->isActive()) {
        m_tickTimer->stop();
    }
    if (m_modbusClient) {
        m_modbusClient->stopPolling();
        m_modbusClient->disconnectFromPlc();
    }
}

void ScadaEngine::onTick()
{
    if (m_operatingMode == "SIMULATION") {
        stepSimulation(0.5);
    }

    // Record to Historian if batch active
    if (!m_activeBatchId.isEmpty()) {
        QSqlDatabase db = QSqlDatabase::database("scada_connection");
        if (db.isOpen()) {
            QSqlQuery q(db);
            q.prepare("INSERT INTO historian_samples (batch_id, timestamp, tag_id, value) VALUES (?, ?, ?, ?)");
            QString ts = QDateTime::currentDateTimeUtc().toString(Qt::ISODate);

            QStringList recordTags = {"vpu.main.temperature", "vpu.jacket.temperature", "vpu.main.vacuum_pressure", "vpu.main.agitator_speed", "vpu.main.homogenizer_speed"};
            for (const QString &tagId : recordTags) {
                q.addBindValue(m_activeBatchId);
                q.addBindValue(ts);
                q.addBindValue(tagId);
                q.addBindValue(m_telemetry.value(tagId, 0.0).toDouble());
                q.exec();
            }
        }
    }

    evaluateAlarms();
    emit telemetryUpdated();
}

void ScadaEngine::onPlcTelemetryReceived(const QVariantMap &data)
{
    if (m_operatingMode == "BENCH_MONITOR" || m_operatingMode == "BENCH_CONTROL") {
        for (auto it = data.constBegin(); it != data.constEnd(); ++it) {
            m_telemetry[it.key()] = it.value();
        }
        m_tagRegistry->updateFromPlcTelemetry(data);
        emit telemetryUpdated();
    }
}

void ScadaEngine::onPlcConnectionChanged(bool connected, const QString &statusText)
{
    m_telemetry["plc_connected"] = connected;
    m_telemetry["plc_status"] = statusText;
    emit telemetryUpdated();
}

void ScadaEngine::evaluateAlarms()
{
    emit alarmsUpdated();
}

void ScadaEngine::stepSimulation(double dt)
{
    // First-order lag towards targets
    double alpha = 1.0 - std::exp(-dt / 2.0);
    m_simAgitSpeed += (m_targetAgitSpeed - m_simAgitSpeed) * alpha;
    m_simHomoSpeed += (m_targetHomoSpeed - m_simHomoSpeed) * alpha;

    double tempAlpha = 1.0 - std::exp(-dt / 20.0);
    m_simTemp += (m_targetTemp - m_simTemp) * tempAlpha;
    m_simJacketTemp = m_simTemp + (m_targetTemp > m_simTemp ? 3.5 : -2.0);

    double vacAlpha = 1.0 - std::exp(-dt / 5.0);
    m_simVacuum += (m_targetVacuum - m_simVacuum) * vacAlpha;

    m_telemetry["vpu.main.temperature"] = std::round(m_simTemp * 10.0) / 10.0;
    m_telemetry["vpu.jacket.temperature"] = std::round(m_simJacketTemp * 10.0) / 10.0;
    m_telemetry["vpu.main.vacuum_pressure"] = std::round(m_simVacuum * 10.0) / 10.0;
    m_telemetry["vpu.main.agitator_speed"] = std::round(m_simAgitSpeed * 10.0) / 10.0;
    m_telemetry["vpu.main.homogenizer_speed"] = std::round(m_simHomoSpeed);

    m_tagRegistry->updateLiveValue("vpu.main.temperature", m_telemetry["vpu.main.temperature"], "GOOD");
    m_tagRegistry->updateLiveValue("vpu.jacket.temperature", m_telemetry["vpu.jacket.temperature"], "GOOD");
    m_tagRegistry->updateLiveValue("vpu.main.vacuum_pressure", m_telemetry["vpu.main.vacuum_pressure"], "GOOD");
    m_tagRegistry->updateLiveValue("vpu.main.agitator_speed", m_telemetry["vpu.main.agitator_speed"], "GOOD");
    m_tagRegistry->updateLiveValue("vpu.main.homogenizer_speed", m_telemetry["vpu.main.homogenizer_speed"], "GOOD");
}
