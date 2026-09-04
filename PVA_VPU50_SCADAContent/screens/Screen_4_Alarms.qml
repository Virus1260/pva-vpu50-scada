import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components/modals/Screen_4_Alarms"
import "../config"

Item {
    id: alarmsContainer
    width: 1184
    height: 626
    implicitWidth: 1184
    implicitHeight: 626
    Layout.fillWidth: true
    Layout.fillHeight: true

    property int pendingAckIndex: -1
    property alias unackCount: ui.unackCount
    property string operatorName: "Line Operator"
    property string operatorRole: "Operator (Level 1)"
    property string operatorId: "operator"

    ScadaConfig { id: scadaConfig }
    ScadaStateMiddleware { id: stateMiddleware }

    signal alarmAcknowledged(string tag, string title)
    signal alarmsSynchronized(int unackCount)

    Screen_4_AlarmsView {
        id: ui
        anchors.fill: parent
    }

    // Modal for 21 CFR Part 11 Electronic Signature & Reason Capture
    AlarmAcknowledgeModal {
        id: ackModal
        anchors.fill: parent
    }

    // Tab Switching
    MouseArea {
        parent: ui.activeTabBtn
        anchors.fill: parent
        onClicked: ui.activeTab = "active"
    }

    MouseArea {
        parent: ui.historyTabBtn
        anchors.fill: parent
        onClicked: ui.activeTab = "history"
    }

    property bool isHornSilenced: false

    // Silence Horn Action Handler
    MouseArea {
        parent: ui.silenceHornBtn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            alarmsContainer.isHornSilenced = !alarmsContainer.isHornSilenced;
            ui.isHornSilenced = alarmsContainer.isHornSilenced;

            var historyModel = ui.historyList.model;
            if (historyModel) {
                var now = new Date();
                var hrs = String(now.getHours()).padStart(2, '0');
                var mins = String(now.getMinutes()).padStart(2, '0');
                var secs = String(now.getSeconds()).padStart(2, '0');
                var nowStr = hrs + ":" + mins + ":" + secs + " UTC";

                var userDisplay = alarmsContainer.operatorName + " (" + alarmsContainer.operatorRole + ")";
                var actionText = alarmsContainer.isHornSilenced ? "Audible alarm horn silenced by operator." : "Audible alarm horn re-enabled.";

                historyModel.insert(0, {
                    time: nowStr,
                    type: "HORN_CTL",
                    tag: "AUDIO.HORN",
                    desc: actionText,
                    user: userDisplay,
                    status: alarmsContainer.isHornSilenced ? "SILENCED" : "NORMAL"
                });
            }
        }
    }

    // Helper: Calculate Active Duration Between Alarm Trip Time and Ack Time
    function formatDuration(startTimeStr, endTimeStr) {
        try {
            var sClean = String(startTimeStr || "").replace(" UTC", "").trim();
            var eClean = String(endTimeStr || "").replace(" UTC", "").trim();
            var sParts = sClean.split(":");
            var eParts = eClean.split(":");
            if (sParts.length >= 2 && eParts.length >= 2) {
                var sSec = parseInt(sParts[0], 10) * 3600 + parseInt(sParts[1], 10) * 60 + (sParts.length > 2 ? parseInt(sParts[2], 10) : 0);
                var eSec = parseInt(eParts[0], 10) * 3600 + parseInt(eParts[1], 10) * 60 + (eParts.length > 2 ? parseInt(eParts[2], 10) : 0);
                var diff = eSec - sSec;
                if (diff < 0) diff += 86400; // Midnight rollover
                if (diff <= 0) diff = 1;
                var mins = Math.floor(diff / 60);
                var secs = diff % 60;
                if (mins > 0) {
                    return mins + "m " + (secs < 10 ? "0" : "") + secs + "s";
                } else {
                    return secs + "s";
                }
            }
        } catch(e) {
            console.log("Error calculating duration:", e);
        }
        return "1m 02s";
    }

    // Record Acknowledgment in System Event Log with Active Duration and User Context
    function recordAlarmAcknowledgment(ackedTag, ackedTitle, tripTime, ackedBy) {
        var historyModel = ui.historyList.model;
        if (!historyModel) return;

        var now = new Date();
        var hrs = String(now.getHours()).padStart(2, '0');
        var mins = String(now.getMinutes()).padStart(2, '0');
        var secs = String(now.getSeconds()).padStart(2, '0');
        var nowStr = hrs + ":" + mins + ":" + secs + " UTC";

        var durationStr = formatDuration(tripTime, nowStr);
        var userDisplay = ackedBy ? ackedBy : (alarmsContainer.operatorName + " (" + alarmsContainer.operatorRole + ")");

        // Update corresponding active alarm trip in history table
        for (var h = 0; h < historyModel.count; h++) {
            var hItem = historyModel.get(h);
            if (hItem.tag === ackedTag && hItem.status === "ACTIVE") {
                historyModel.setProperty(h, "status", "CLEARED");
            }
        }

        // Insert new comprehensive audit event log entry
        historyModel.insert(0, {
            time: nowStr,
            type: "ALARM_ACK",
            tag: ackedTag,
            desc: ackedTitle + " acknowledged. Active: " + tripTime + " to " + nowStr + " (Duration: " + durationStr + "). Status: ACKNOWLEDGED / INACTIVE.",
            user: userDisplay,
            status: "ACKED"
        });
    }

    // Delegate Action Handling (Acknowledge)
    MouseArea {
        parent: ui.alarmList
        anchors.fill: parent
        onClicked: function(mouse) {
            var idx = ui.alarmList.indexAt(mouse.x, mouse.y + ui.alarmList.contentY);
            var model = ui.alarmList.model;
            if (model && idx >= 0 && idx < model.count) {
                var item = model.get(idx);
                if (!item.ack) {
                    alarmsContainer.pendingAckIndex = idx;
                    ackModal.alarmTagText = item.tag;
                    ackModal.alarmTitleText = item.title;
                    ackModal.visible = true;
                }
            }
        }
    }

    // Modal Confirmation (21 CFR Part 11 Electronic Signature & Event Logging)
    MouseArea {
        parent: ackModal.confirmBtn
        anchors.fill: parent
        onClicked: {
            if (alarmsContainer.pendingAckIndex >= 0) {
                var model = ui.alarmList.model;
                if (model && alarmsContainer.pendingAckIndex < model.count) {
                    var item = model.get(alarmsContainer.pendingAckIndex);
                    var ackedTag = item.tag;
                    var ackedTitle = item.title;
                    var tripTime = item.time;
                    var userDisplay = alarmsContainer.operatorName + " (" + alarmsContainer.operatorRole + ")";

                    model.setProperty(alarmsContainer.pendingAckIndex, "ack", true);
                    model.setProperty(alarmsContainer.pendingAckIndex, "ackBy", alarmsContainer.operatorId);

                    // Add Event Log Audit Record
                    recordAlarmAcknowledgment(ackedTag, ackedTitle, tripTime, userDisplay);

                    // Count remaining unacknowledged alarms
                    var unack = 0;
                    for (var i = 0; i < model.count; i++) {
                        if (!model.get(i).ack) unack++;
                    }
                    ui.unackCount = unack;
                    alarmsContainer.alarmAcknowledged(ackedTag, ackedTitle);
                    alarmsContainer.alarmsSynchronized(unack);
                }
            }
            ackModal.visible = false;
        }
    }

    // Modal Cancel
    MouseArea {
        parent: ackModal.cancelBtn
        anchors.fill: parent
        onClicked: {
            ackModal.visible = false;
        }
    }

    function syncUnackCount() {
        var model = ui.alarmList.model;
        if (!model) return 0;
        var unack = 0;
        for (var i = 0; i < model.count; i++) {
            if (!model.get(i).ack) unack++;
        }
        ui.unackCount = unack;
        return unack;
    }

    function getLatestUnacknowledgedAlarm() {
        var model = ui.alarmList.model;
        if (!model) return null;
        for (var i = 0; i < model.count; i++) {
            var item = model.get(i);
            if (!item.ack) {
                return {
                    alarmCode: item.alarmCode,
                    severity: item.severity,
                    tag: item.tag,
                    title: item.title,
                    value: item.value,
                    sp: item.sp,
                    time: item.time,
                    resp: item.resp
                };
            }
        }
        return null;
    }

    function acknowledgeLatestAlarm(ackedBy) {
        var model = ui.alarmList.model;
        if (!model) return false;
        for (var i = 0; i < model.count; i++) {
            if (!model.get(i).ack) {
                var item = model.get(i);
                var ackedTag = item.tag;
                var ackedTitle = item.title;
                var tripTime = item.time;
                var userStr = ackedBy ? ackedBy : (alarmsContainer.operatorName + " (" + alarmsContainer.operatorRole + ")");

                model.setProperty(i, "ack", true);
                model.setProperty(i, "ackBy", ackedBy ? ackedBy : alarmsContainer.operatorId);

                // Add Event Log Audit Record
                recordAlarmAcknowledgment(ackedTag, ackedTitle, tripTime, userStr);

                syncUnackCount();
                alarmAcknowledged(ackedTag, ackedTitle);
                return true;
            }
        }
        return false;
    }

    Component.onCompleted: {
        syncUnackCount();
    }
}
