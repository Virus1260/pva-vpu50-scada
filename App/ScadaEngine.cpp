#include "ScadaEngine.h"

#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QSqlError>
#include <QDebug>
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
