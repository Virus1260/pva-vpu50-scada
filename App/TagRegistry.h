#ifndef TAG_REGISTRY_H
#define TAG_REGISTRY_H

#include <QObject>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QVariantMap>
#include <QVariantList>
#include <QDateTime>

struct TagDefinition {
    QString id;
    QString displayName;
    QString description;
    QString unit;
    QString dataType; // "number", "boolean", "string"
    QString protocol; // "modbus", "opcua", "simulated"
    int modbusAddress;
    double scale;
    bool isSigned;
    double minVal;
    double maxVal;
    double warningLow;
    double warningHigh;
    double alarmLow;
    double alarmHigh;
    QString commandPermission;
};

class TagRegistry : public QObject
{
    Q_OBJECT

public:
    explicit TagRegistry(const QString &configFilePath, QObject *parent = nullptr);

    bool loadCatalog();
    bool saveCatalog();

    // Tag Querying
    bool hasTag(const QString &tagId) const;
    QVariant tagValue(const QString &tagId, const QVariant &defaultVal = QVariant()) const;
    QString tagQuality(const QString &tagId) const;
    QString tagUnit(const QString &tagId) const;
    QVariantMap tagLimits(const QString &tagId) const;
    TagDefinition getDefinition(const QString &tagId) const;

    // Live Value Updates
    void updateLiveValue(const QString &tagId, const QVariant &val, const QString &quality = "GOOD");
    void updateFromPlcTelemetry(const QVariantMap &telemetry);

    // QML-Facing Methods for I/O Editor
    Q_INVOKABLE QVariantList getAllTags() const;
    Q_INVOKABLE QString getAllTagsJson() const;
    Q_INVOKABLE bool saveTagJson(const QString &tagJsonStr, QString *errorMessage = nullptr);
    Q_INVOKABLE bool removeTag(const QString &tagId);
    Q_INVOKABLE QVariantMap testEvaluateRaw(const QString &tagId, double rawValue) const;

signals:
    void catalogChanged();
    void tagValueChanged(const QString &tagId, const QVariant &val, const QString &quality);

private:
    QString m_configFilePath;
    QMap<QString, TagDefinition> m_definitions;
    QMap<QString, QVariant> m_values;
    QMap<QString, QString> m_qualities;
    QMap<QString, QDateTime> m_timestamps;
};

#endif // TAG_REGISTRY_H
