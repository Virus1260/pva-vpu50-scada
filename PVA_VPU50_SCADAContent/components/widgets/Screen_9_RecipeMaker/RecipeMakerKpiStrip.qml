import QtQuick
import QtQuick.Layouts

// At-a-glance recipe scale: stages, tasks, holds, duration, vessel.
Rectangle {
    id: kpiRoot
    Layout.fillWidth: true
    Layout.preferredHeight: 58
    color: "transparent"

    property int stageCount: 0
    property int taskCount: 0
    property int holdCount: 0
    property string estDuration: "—"
    property string vesselTag: "1B1001"

    RowLayout {
        anchors.fill: parent
        spacing: 8

        RecipeMakerKpiCard { Layout.fillWidth: true; Layout.fillHeight: true; label: "STAGES"; value: kpiRoot.stageCount }
        RecipeMakerKpiCard { Layout.fillWidth: true; Layout.fillHeight: true; label: "TASKS"; value: kpiRoot.taskCount }
        RecipeMakerKpiCard { Layout.fillWidth: true; Layout.fillHeight: true; label: "HOLD POINTS"; value: kpiRoot.holdCount }
        RecipeMakerKpiCard { Layout.fillWidth: true; Layout.fillHeight: true; label: "EST. DURATION"; valueText: kpiRoot.estDuration }
        RecipeMakerKpiCard { Layout.fillWidth: true; Layout.fillHeight: true; label: "VESSEL"; valueText: kpiRoot.vesselTag }
    }
}
