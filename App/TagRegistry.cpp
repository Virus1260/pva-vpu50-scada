#include "TagRegistry.h"
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QDebug>

TagRegistry::TagRegistry(const QString &configFilePath, QObject *parent)
    : QObject(parent)
    , m_configFilePath(configFilePath)
{
    loadCatalog();
}

bool TagRegistry::loadCatalog()
{
    QString path = m_configFilePath;
    if (!QFile::exists(path)) {
        path = ":/qt/qml/scada/config/tag_catalog.json";
    }

    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Failed to open tag catalog at" << path;
        return false;
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(data, &err);
    if (err.error != QJsonParseError::NoError || !doc.isObject()) {
        qWarning() << "JSON parse error in tag catalog:" << err.errorString();
        return false;
    }

    m_definitions.clear();
    QJsonObject root = doc.object();
    QJsonArray tags = root["tags"].toArray();

    for (const QJsonValue &v : tags) {
        QJsonObject obj = v.toObject();
        TagDefinition def;
        def.id = obj["id"].toString();
        def.displayName = obj["display_name"].toString();
        def.description = obj["description"].toString();
        def.unit = obj["unit"].toString();
        def.dataType = obj["data_type"].toString("number");

        QJsonObject src = obj["source"].toObject();
        def.protocol = src["adapter"].toString("modbus");
        def.modbusAddress = src["modbus_address"].toInt(0);
        def.scale = src.contains("scale") ? src["scale"].toDouble() : 1.0;
        def.isSigned = src["signed"].toBool(false);

        QJsonObject lim = obj["limits"].toObject();
        def.minVal = lim["minimum"].toDouble(0.0);
        def.maxVal = lim["maximum"].toDouble(100.0);
        def.warningLow = lim["warning_low"].toDouble(def.minVal);
        def.warningHigh = lim["warning_high"].toDouble(def.maxVal);
        def.alarmLow = lim["alarm_low"].toDouble(def.minVal);
        def.alarmHigh = lim["alarm_high"].toDouble(def.maxVal);

        QJsonObject acc = obj["access"].toObject();
        def.commandPermission = acc["command_permission"].toString();

        m_definitions[def.id] = def;
        m_qualities[def.id] = "UNKNOWN";
        m_values[def.id] = (def.dataType == "boolean") ? QVariant(false) : QVariant(0.0);
        m_timestamps[def.id] = QDateTime::currentDateTimeUtc();
    }

    emit catalogChanged();
    return true;
}

bool TagRegistry::saveCatalog()
{
    QJsonObject root;
    root["catalog_version"] = "1.0.0";
    root["plant_id"] = "VPU-50";
    root["plc_model"] = "Delta AS332T-A";

    QJsonArray tagsArray;
    for (auto it = m_definitions.begin(); it != m_definitions.end(); ++it) {
        const TagDefinition &def = it.value();
        QJsonObject obj;
        obj["id"] = def.id;
        obj["display_name"] = def.displayName;
        obj["description"] = def.description;
        obj["unit"] = def.unit;
        obj["data_type"] = def.dataType;

        QJsonObject src;
        src["adapter"] = def.protocol;
        src["modbus_address"] = def.modbusAddress;
        src["scale"] = def.scale;
        src["signed"] = def.isSigned;
        obj["source"] = src;

        QJsonObject lim;
        lim["minimum"] = def.minVal;
        lim["maximum"] = def.maxVal;
        lim["warning_low"] = def.warningLow;
        lim["warning_high"] = def.warningHigh;
        lim["alarm_low"] = def.alarmLow;
        lim["alarm_high"] = def.alarmHigh;
        obj["limits"] = lim;

        QJsonObject acc;
        acc["read_permission"] = "telemetry.read";
        acc["command_permission"] = def.commandPermission.isEmpty() ? QJsonValue(QJsonValue::Null) : QJsonValue(def.commandPermission);
        obj["access"] = acc;

        tagsArray.append(obj);
    }
    root["tags"] = tagsArray;

    QFile file(m_configFilePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        return false;
    }
    file.write(QJsonDocument(root).toJson(QJsonDocument::Indented));
    file.close();
    return true;
}

bool TagRegistry::hasTag(const QString &tagId) const
{
    return m_definitions.contains(tagId);
}

QVariant TagRegistry::tagValue(const QString &tagId, const QVariant &defaultVal) const
{
    return m_values.value(tagId, defaultVal);
}

QString TagRegistry::tagQuality(const QString &tagId) const
{
    return m_qualities.value(tagId, "UNKNOWN");
}

QString TagRegistry::tagUnit(const QString &tagId) const
{
    if (m_definitions.contains(tagId)) {
        return m_definitions[tagId].unit;
    }
    return QString();
}

QVariantMap TagRegistry::tagLimits(const QString &tagId) const
{
    QVariantMap map;
    if (m_definitions.contains(tagId)) {
        const TagDefinition &def = m_definitions[tagId];
        map["minimum"] = def.minVal;
        map["maximum"] = def.maxVal;
        map["warning_low"] = def.warningLow;
        map["warning_high"] = def.warningHigh;
        map["alarm_low"] = def.alarmLow;
        map["alarm_high"] = def.alarmHigh;
    }
    return map;
}

TagDefinition TagRegistry::getDefinition(const QString &tagId) const
{
    return m_definitions.value(tagId);
}

void TagRegistry::updateLiveValue(const QString &tagId, const QVariant &val, const QString &quality)
{
    m_values[tagId] = val;
    m_qualities[tagId] = quality;
    m_timestamps[tagId] = QDateTime::currentDateTimeUtc();
    emit tagValueChanged(tagId, val, quality);
}

void TagRegistry::updateFromPlcTelemetry(const QVariantMap &telemetry)
{
    for (auto it = telemetry.constBegin(); it != telemetry.constEnd(); ++it) {
        const QString &key = it.key();
        const QVariant &rawVal = it.value();

        if (m_definitions.contains(key)) {
            const TagDefinition &def = m_definitions[key];
            QVariant finalVal = rawVal;
            QString qual = "GOOD";

            // If hardware fault detected for this tag
            if (key.contains("rtd") && telemetry.value("rtd_slot4_fault", false).toBool()) {
                qual = "FAULT_1801";
            } else if (key.contains("ad") && telemetry.value("ad_slot2_fault", false).toBool()) {
                qual = "FAULT_1801";
            }

            m_values[key] = finalVal;
            m_qualities[key] = qual;
            m_timestamps[key] = QDateTime::currentDateTimeUtc();
            emit tagValueChanged(key, finalVal, qual);
        } else {
            // Also store ad-hoc physical points like X0.0, Y0.0
            m_values[key] = rawVal;
            m_qualities[key] = "GOOD";
        }
    }
}

QVariantList TagRegistry::getAllTags() const
{
    QVariantList list;
    for (auto it = m_definitions.begin(); it != m_definitions.end(); ++it) {
        const TagDefinition &def = it.value();
        QVariantMap map;
        map["id"] = def.id;
        map["display_name"] = def.displayName;
        map["description"] = def.description;
        map["unit"] = def.unit;
        map["data_type"] = def.dataType;
        map["protocol"] = def.protocol;
        map["modbus_address"] = def.modbusAddress;
        map["scale"] = def.scale;
        map["value"] = m_values.value(def.id);
        map["quality"] = m_qualities.value(def.id, "UNKNOWN");
        map["command_permission"] = def.commandPermission;
        list.append(map);
    }
    return list;
}

QString TagRegistry::getAllTagsJson() const
{
    QJsonArray arr;
    for (auto it = m_definitions.begin(); it != m_definitions.end(); ++it) {
        const TagDefinition &def = it.value();
        QJsonObject obj;
        obj["id"] = def.id;
        obj["display_name"] = def.displayName;
        obj["description"] = def.description;
        obj["unit"] = def.unit;
        obj["data_type"] = def.dataType;
        obj["protocol"] = def.protocol;
        obj["modbus_address"] = def.modbusAddress;
        obj["scale"] = def.scale;
        obj["value"] = QJsonValue::fromVariant(m_values.value(def.id));
        obj["quality"] = m_qualities.value(def.id, "UNKNOWN");
        obj["command_permission"] = def.commandPermission;
        arr.append(obj);
    }
    return QString::fromUtf8(QJsonDocument(arr).toJson(QJsonDocument::Compact));
}

bool TagRegistry::saveTagJson(const QString &tagJsonStr, QString *errorMessage)
{
    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(tagJsonStr.toUtf8(), &err);
    if (err.error != QJsonParseError::NoError || !doc.isObject()) {
        if (errorMessage) *errorMessage = QString("Invalid JSON format: %1").arg(err.errorString());
        return false;
    }

    QJsonObject obj = doc.object();
    QString tagId = obj["id"].toString().trimmed();
    if (tagId.isEmpty()) {
        if (errorMessage) *errorMessage = "Tag ID cannot be empty.";
        return false;
    }

    TagDefinition def;
    def.id = tagId;
    def.displayName = obj["display_name"].toString(tagId);
    def.description = obj["description"].toString();
    def.unit = obj["unit"].toString();
    def.dataType = obj["data_type"].toString("number");
    def.protocol = obj["protocol"].toString("modbus");
    def.modbusAddress = obj["modbus_address"].toInt(0);
    def.scale = obj.contains("scale") ? obj["scale"].toDouble() : 1.0;
    def.isSigned = obj["signed"].toBool(false);
    def.minVal = obj["minimum"].toDouble(0.0);
    def.maxVal = obj["maximum"].toDouble(100.0);
    def.commandPermission = obj["command_permission"].toString();

    m_definitions[def.id] = def;
    if (!m_values.contains(def.id)) {
        m_values[def.id] = (def.dataType == "boolean") ? QVariant(false) : QVariant(0.0);
        m_qualities[def.id] = "UNKNOWN";
        m_timestamps[def.id] = QDateTime::currentDateTimeUtc();
    }

    saveCatalog();
    emit catalogChanged();
    return true;
}

bool TagRegistry::removeTag(const QString &tagId)
{
    if (m_definitions.contains(tagId)) {
        m_definitions.remove(tagId);
        m_values.remove(tagId);
        m_qualities.remove(tagId);
        m_timestamps.remove(tagId);
        saveCatalog();
        emit catalogChanged();
        return true;
    }
    return false;
}

QVariantMap TagRegistry::testEvaluateRaw(const QString &tagId, double rawValue) const
{
    QVariantMap result;
    if (!m_definitions.contains(tagId)) {
        result["valid"] = false;
        result["error"] = "Tag ID not found";
        return result;
    }

    const TagDefinition &def = m_definitions[tagId];
    double scaled = rawValue * def.scale;
    result["valid"] = true;
    result["id"] = def.id;
    result["raw"] = rawValue;
    result["scaled"] = scaled;
    result["unit"] = def.unit;
    result["in_limits"] = (scaled >= def.minVal && scaled <= def.maxVal);
    return result;
}
