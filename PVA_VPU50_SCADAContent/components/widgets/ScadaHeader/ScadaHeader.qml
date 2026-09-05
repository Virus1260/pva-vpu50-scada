import QtQuick
import QtQuick.Layouts

Rectangle {
    id: headerRoot
    implicitWidth: 1024
    width: 1024
    implicitHeight: 86
    height: 86
    color: "#08213b"
    clip: true

    property string activeBatchId: "B1"
    property string vesselName: "VPU 50"
    property string plantModeText: "(A)"
    property string alarmMessage: "SYSTEM READY - RECIPE [VPU_BATCH_01] STANDBY"
    property string operatorName: "Line Operator"
    property string operatorRole: "Operator (Level 1)"
    property string timeString: "17:25:00"
    property string dateString: "15/08/2026"
    property bool isAlarmActive: false

    property alias ackButton: centerAnnunciator.ackButton

    signal plantModeRequested()
    signal userLoginRequested()

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date();
            var hrs = String(now.getHours()).padStart(2, '0');
            var mins = String(now.getMinutes()).padStart(2, '0');
            var secs = String(now.getSeconds()).padStart(2, '0');
            headerRoot.timeString = hrs + ":" + mins + ":" + secs;
            var day = String(now.getDate()).padStart(2, '0');
            var month = String(now.getMonth() + 1).padStart(2, '0');
            var year = now.getFullYear();
            headerRoot.dateString = day + "/" + month + "/" + year;
        }
    }

    // =========================================================================
    // 1. LEFT CLUSTER: Machine Badges & Vessel Capsule
    // =========================================================================
    HeaderMachineCluster {
        id: leftMachineCluster
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        activeBatchId: headerRoot.activeBatchId
        vesselName: headerRoot.vesselName
        plantModeText: headerRoot.plantModeText
        onPlantModeRequested: headerRoot.plantModeRequested()
    }

    // =========================================================================
    // 2. RIGHT CLUSTER: User Identity, Digital Clock & OEM Logo
    // =========================================================================
    HeaderUserCluster {
        id: rightUserCluster
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        operatorName: headerRoot.operatorName
        operatorRole: headerRoot.operatorRole
        timeString: headerRoot.timeString
        dateString: headerRoot.dateString
        onUserLoginRequested: headerRoot.userLoginRequested()
    }

    // =========================================================================
    // 3. CENTER CLUSTER: Responsive Process Annunciator & Alarm Banner
    // =========================================================================
    HeaderAnnunciator {
        id: centerAnnunciator
        anchors.left: leftMachineCluster.right
        anchors.leftMargin: 16
        anchors.right: rightUserCluster.left
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        isAlarmActive: headerRoot.isAlarmActive
        alarmMessage: headerRoot.alarmMessage
    }
}
