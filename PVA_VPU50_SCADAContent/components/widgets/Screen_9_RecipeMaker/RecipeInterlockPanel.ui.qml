import QtQuick
import QtQuick.Layouts

// Recipe-level gates: sequential locks, holds, and equipment-state interlocks.
Rectangle {
    id: lockRoot
    implicitWidth: 800
    implicitHeight: 400
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#06182c"
    border.color: "#184d7e"
    border.width: 1
    radius: 6

    property int sequentialStages: 0
    property int holdPoints: 0
    property string vesselTag: "1B1001"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        Text { text: "INTERLOCKS & STOP GATES"; color: "#38bdf8"; font.bold: true; font.pixelSize: 11 }
        Text {
            text: "These rules travel with the master recipe. At Execute they are snapshotted into the batch run and cannot be edited from history."
            color: "#94a3b8"
            font.pixelSize: 10
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        RecipeInterlockRow {
            Layout.fillWidth: true
            title: "Stage sequential lock"
            body: lockRoot.sequentialStages + " stage(s) require tasks to finish in order before the next task unlocks."
        }
        RecipeInterlockRow {
            Layout.fillWidth: true
            title: "21 CFR hold points"
            body: lockRoot.holdPoints + " task(s) require operator confirm / e-signature before the engine advances."
        }
        RecipeInterlockRow {
            Layout.fillWidth: true
            title: "Equipment state gate"
            body: "Homogenizer ramp (1X1001) is only legal when the vessel is charged and agitator 1M1501 is running."
        }
        RecipeInterlockRow {
            Layout.fillWidth: true
            title: "Vessel empty / lid"
            body: "Discharge (1M2001) remains locked until stop condition vessel_empty is true on " + lockRoot.vesselTag + "."
        }
        RecipeInterlockRow {
            Layout.fillWidth: true
            title: "Override policy"
            body: "Override of a failed IPC / hold requires Incharge or Administrator electronic signature. Operators cannot bypass."
        }

        Item { Layout.fillHeight: true }
    }
}
