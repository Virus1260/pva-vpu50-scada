#ifndef SCADA_ENGINE_H
#define SCADA_ENGINE_H

#include <QObject>
#include <QVariantMap>
#include <QVariantList>
#include <QTimer>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QDateTime>
#include <QCryptographicHash>

#include "PlcModbusClient.h"
#include "TagRegistry.h"

class ScadaEngine : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QVariantMap telemetry READ telemetry NOTIFY telemetryUpdated)
    Q_PROPERTY(QString operatingMode READ operatingMode NOTIFY telemetryUpdated)
    Q_PROPERTY(bool isPlcConnected READ isPlcConnected NOTIFY telemetryUpdated)
    Q_PROPERTY(QString plcStatusText READ plcStatusText NOTIFY telemetryUpdated)
    Q_PROPERTY(QString activeBatchId READ activeBatchId NOTIFY recipeStateUpdated)
    Q_PROPERTY(QString activeRecipeName READ activeRecipeName NOTIFY recipeStateUpdated)
    Q_PROPERTY(int currentStepIndex READ currentStepIndex NOTIFY recipeStateUpdated)
    Q_PROPERTY(int totalSteps READ totalSteps NOTIFY recipeStateUpdated)
    Q_PROPERTY(bool recipeRunning READ recipeRunning NOTIFY recipeStateUpdated)

public:
    explicit ScadaEngine(const QString &runtimeDir,
                         const QString &mode = "BENCH_MONITOR",
                         const QString &plcHost = "192.168.1.6",
                         int plcPort = 502,
                         QObject *parent = nullptr);
    ~ScadaEngine() override;

    // Property Getters
    QVariantMap telemetry() const;
    QString operatingMode() const;
    bool isPlcConnected() const;
    QString plcStatusText() const;
    QString activeBatchId() const;
    QString activeRecipeName() const;
    int currentStepIndex() const;
    int totalSteps() const;
    bool recipeRunning() const;

    // QML Invocable Methods
    Q_INVOKABLE bool loginUser(const QString &userId, const QString &roleId);
    Q_INVOKABLE bool setProcessSetpoint(const QString &tagId, double value, const QString &reason);
    Q_INVOKABLE bool acknowledgeAlarm(const QString &alarmId, const QString &comment);
    Q_INVOKABLE QString startBatch(const QString &batchName = "Production Batch");
    Q_INVOKABLE bool endBatch(const QString &batchId, const QString &status);
    Q_INVOKABLE QString getBatchTelemetryJson(const QString &batchId);
    Q_INVOKABLE QString getBatchesJson();
    Q_INVOKABLE QString getAuditEventsJson();
    Q_INVOKABLE QString verifyAuditChainJson();
    Q_INVOKABLE QString getActiveAlarmsJson();
    Q_INVOKABLE QString getRecipesJson();
    Q_INVOKABLE QString getDigitalIoStatusJson();
    Q_INVOKABLE QString setDigitalOutput(int index, bool state, bool force = false);

    // Tag Querying & Configurable I/O System
    Q_INVOKABLE QVariant tagValue(const QString &tagId, const QVariant &defaultVal = QVariant()) const;
    Q_INVOKABLE QString tagQuality(const QString &tagId) const;
    Q_INVOKABLE QString tagUnit(const QString &tagId) const;
    Q_INVOKABLE QVariantMap tagLimits(const QString &tagId) const;
    Q_INVOKABLE QString getAllTagsJson() const;
    Q_INVOKABLE QString saveTagJson(const QString &tagJsonStr);
    Q_INVOKABLE bool removeTag(const QString &tagId);
    Q_INVOKABLE QVariantMap testEvaluateTag(const QString &tagId, double rawVal) const;

    // Mode Selection
    Q_INVOKABLE void setOperatingMode(const QString &mode);

    // Lifecycle cleanup
    Q_INVOKABLE void cleanup();

signals:
    void telemetryUpdated();
    void alarmsUpdated();
    void recipeStateUpdated();
    void auditUpdated();
    void batchListUpdated();

private slots:
    void onTick();
    void onPlcTelemetryReceived(const QVariantMap &data);
    void onPlcConnectionChanged(bool connected, const QString &statusText);

private:
    void initDatabase();
    void logAuditEvent(const QString &action,
                       const QString &objectType,
                       const QString &objectId,
                       const QString &reason,
                       const QVariantMap &before,
                       const QVariantMap &after);
    void evaluateAlarms();
    void stepSimulation(double dt);

    QString m_runtimeDir;
    QString m_operatingMode; // "SIMULATION", "BENCH_MONITOR", "BENCH_CONTROL"
    QString m_currentUser;
    QString m_currentRole;

    TagRegistry *m_tagRegistry;
    PlcModbusClient *m_modbusClient;

    QTimer *m_tickTimer;
    QVariantMap m_telemetry;
    QString m_activeBatchId;
    QString m_lastAuditHash;
    QByteArray m_auditSalt;

    // Simulation variables for offline mode
    double m_simTemp;
    double m_simJacketTemp;
    double m_simVacuum;
    double m_simAgitSpeed;
    double m_simHomoSpeed;
    double m_targetAgitSpeed;
    double m_targetHomoSpeed;
    double m_targetTemp;
    double m_targetVacuum;
};

#endif // SCADA_ENGINE_H
