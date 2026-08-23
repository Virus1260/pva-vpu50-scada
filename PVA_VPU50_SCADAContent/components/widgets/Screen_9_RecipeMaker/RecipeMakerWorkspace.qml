import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/*
  Human-flow authoring canvas (Leucine-style stages → tasks → inspector).
  All mutable recipe data lives here so Screen_9_RecipeMakerView.ui.qml stays declarative.
*/
Item {
    id: workspace
    Layout.fillWidth: true
    Layout.fillHeight: true

    property int currentTab: 0
    property int selectedStageId: 1
    property int selectedTaskIndex: 0
    property string recipeStatus: "DRAFT"
    property string authorName: "Process Incharge"
    property string reviewerName: "—"
    property string approverName: "—"
    property string approvalDate: "—"
    property int recipeVersion: 1
    property int holdCount: 0
    property int sequentialStageCount: 0
    property string estDuration: "0m 0s"

    readonly property int stageCount: stagesModel.count
    readonly property int taskCount: tasksModel.count
    readonly property string vesselTag: "1B1001"

    readonly property var deviceTags: [
        "1M1501 Anchor",
        "1X1001 Homogenizer",
        "1M5001 Vacuum",
        "1E6001 Jacket",
        "1K1001 Charge valve",
        "1M2001 Discharge",
        "1M6001 Recirc",
        "MANUAL"
    ]
    readonly property var stopLabels: [
        "timer", "level_below", "level_above", "temp_above", "temp_below", "manual", "vessel_empty"
    ]

    function countHolds() {
        var n = 0
        for (var i = 0; i < tasksModel.count; i++) {
            var t = tasksModel.get(i)
            if (t.hasHold || t.requireConfirm)
                n++
        }
        return n
    }

    function countLocks() {
        var n = 0
        for (var i = 0; i < stagesModel.count; i++) {
            if (stagesModel.get(i).sequentialLock)
                n++
        }
        return n
    }

    function sumDurations() {
        var s = 0
        for (var i = 0; i < tasksModel.count; i++)
            s += parseInt(tasksModel.get(i).durationSec) || 0
        return s
    }

    function formatDuration(sec) {
        var m = Math.floor(sec / 60)
        var r = sec % 60
        return m + "m " + r + "s"
    }

    function nextStageId() {
        var maxId = 0
        for (var i = 0; i < stagesModel.count; i++)
            maxId = Math.max(maxId, stagesModel.get(i).stageId)
        return maxId + 1
    }

    function stageNumberForId(id) {
        for (var i = 0; i < stagesModel.count; i++) {
            if (stagesModel.get(i).stageId === id)
                return i + 1
        }
        return 0
    }

    function taskOrdinal(stageId, taskIndex) {
        var n = 0
        for (var i = 0; i <= taskIndex; i++) {
            if (tasksModel.get(i).stageId === stageId)
                n++
        }
        return n
    }

    function selectFirstTaskInStage(stageId) {
        for (var i = 0; i < tasksModel.count; i++) {
            if (tasksModel.get(i).stageId === stageId) {
                selectedTaskIndex = i
                return
            }
        }
        selectedTaskIndex = -1
    }

    function swapModel(model, a, b) {
        if (a < 0 || b < 0 || a >= model.count || b >= model.count)
            return
        model.move(a, b, 1)
    }

    function addStage() {
        var id = nextStageId()
        stagesModel.append({ stageId: id, name: "New Stage", sequentialLock: true })
        selectedStageId = id
        selectedTaskIndex = -1
        refreshStats()
    }

    function addTask() {
        tasksModel.append({
            stageId: selectedStageId,
            name: "New task",
            hasTimer: true,
            hasManual: false,
            hasMedia: false,
            hasLoop: false,
            hasSchedule: false,
            hasHold: false,
            hasEquip: true,
            hasCheck: false,
            deviceIndex: 0,
            actionIndex: 0,
            setpoint: "",
            stopIndex: 0,
            durationSec: "60",
            requireConfirm: false,
            confirmMessage: ""
        })
        selectedTaskIndex = tasksModel.count - 1
        refreshStats()
    }

    function duplicateTask(index) {
        var t = tasksModel.get(index)
        tasksModel.insert(index + 1, {
            stageId: t.stageId,
            name: t.name + " (copy)",
            hasTimer: t.hasTimer,
            hasManual: t.hasManual,
            hasMedia: t.hasMedia,
            hasLoop: t.hasLoop,
            hasSchedule: t.hasSchedule,
            hasHold: t.hasHold,
            hasEquip: t.hasEquip,
            hasCheck: t.hasCheck,
            deviceIndex: t.deviceIndex,
            actionIndex: t.actionIndex,
            setpoint: t.setpoint,
            stopIndex: t.stopIndex,
            durationSec: t.durationSec,
            requireConfirm: t.requireConfirm,
            confirmMessage: t.confirmMessage
        })
        selectedTaskIndex = index + 1
        refreshStats()
    }

    function removeTasksForStage(stageId) {
        for (var i = tasksModel.count - 1; i >= 0; i--) {
            if (tasksModel.get(i).stageId === stageId)
                tasksModel.remove(i)
        }
    }

    function toggleTaskFlag(index, key) {
        var t = tasksModel.get(index)
        tasksModel.setProperty(index, key, !t[key])
        if (key === "hasHold" && tasksModel.get(index).hasHold)
            tasksModel.setProperty(index, "requireConfirm", true)
        refreshStats()
    }

    function refreshStats() {
        holdCount = countHolds()
        sequentialStageCount = countLocks()
        estDuration = formatDuration(sumDurations())
        rebuildParamView()
    }

    function currentTask() {
        if (selectedTaskIndex < 0 || selectedTaskIndex >= tasksModel.count)
            return null
        return tasksModel.get(selectedTaskIndex)
    }

    ListModel {
        id: stagesModel
        ListElement { stageId: 1; name: "Equipment Preparation"; sequentialLock: true }
        ListElement { stageId: 2; name: "Phase A — Aqueous Charge"; sequentialLock: true }
        ListElement { stageId: 3; name: "Phase B — Surfactant Induction"; sequentialLock: true }
        ListElement { stageId: 4; name: "Phase C — Heat & Emulsify"; sequentialLock: true }
        ListElement { stageId: 5; name: "Phase D–F — Cool, Actives, Finish"; sequentialLock: true }
    }

    ListModel {
        id: tasksModel
        ListElement { stageId: 1; name: "Confirm vessel clean, empty, lid seated"; hasTimer: false; hasManual: true; hasMedia: false; hasLoop: false; hasSchedule: false; hasHold: true; hasEquip: false; hasCheck: true; deviceIndex: 7; actionIndex: 0; setpoint: ""; stopIndex: 5; durationSec: "0"; requireConfirm: true; confirmMessage: "Confirm 1B1001 is clean, empty, and lid seated before charge." }
        ListElement { stageId: 1; name: "Verify jacket circuit and vacuum seal"; hasTimer: true; hasManual: false; hasMedia: false; hasLoop: false; hasSchedule: false; hasHold: false; hasEquip: true; hasCheck: true; deviceIndex: 2; actionIndex: 1; setpoint: "seal check"; stopIndex: 0; durationSec: "60"; requireConfirm: false; confirmMessage: "" }
        ListElement { stageId: 2; name: "Charge DI water via 1K1001 to 55%"; hasTimer: false; hasManual: false; hasMedia: false; hasLoop: false; hasSchedule: false; hasHold: false; hasEquip: true; hasCheck: false; deviceIndex: 4; actionIndex: 0; setpoint: "55%"; stopIndex: 2; durationSec: "180"; requireConfirm: false; confirmMessage: "" }
        ListElement { stageId: 2; name: "Heat aqueous phase to 45°C, 1M1501 25 rpm"; hasTimer: true; hasManual: false; hasMedia: false; hasLoop: false; hasSchedule: false; hasHold: false; hasEquip: true; hasCheck: false; deviceIndex: 3; actionIndex: 0; setpoint: "45.0°C"; stopIndex: 3; durationSec: "240"; requireConfirm: false; confirmMessage: "" }
        ListElement { stageId: 2; name: "Manual add EDTA and citric acid"; hasTimer: false; hasManual: true; hasMedia: false; hasLoop: false; hasSchedule: false; hasHold: true; hasEquip: false; hasCheck: true; deviceIndex: 7; actionIndex: 0; setpoint: ""; stopIndex: 5; durationSec: "120"; requireConfirm: true; confirmMessage: "Confirm chelating agents added via hatch." }
        ListElement { stageId: 3; name: "Pull vacuum to -300 mbar"; hasTimer: true; hasManual: false; hasMedia: false; hasLoop: false; hasSchedule: false; hasHold: false; hasEquip: true; hasCheck: false; deviceIndex: 2; actionIndex: 0; setpoint: "-300 mbar"; stopIndex: 0; durationSec: "90"; requireConfirm: false; confirmMessage: "" }
        ListElement { stageId: 3; name: "Charge SLES 28% through bottom suction"; hasTimer: false; hasManual: true; hasMedia: false; hasLoop: false; hasSchedule: false; hasHold: true; hasEquip: true; hasCheck: false; deviceIndex: 4; actionIndex: 0; setpoint: "18.0 kg"; stopIndex: 5; durationSec: "300"; requireConfirm: true; confirmMessage: "Confirm SLES charge complete before continuing." }
        ListElement { stageId: 4; name: "Heat to 70°C for pearlizer melt"; hasTimer: true; hasManual: false; hasMedia: false; hasLoop: false; hasSchedule: false; hasHold: false; hasEquip: true; hasCheck: false; deviceIndex: 3; actionIndex: 0; setpoint: "70.0°C"; stopIndex: 3; durationSec: "360"; requireConfirm: false; confirmMessage: "" }
        ListElement { stageId: 4; name: "Homogenizer ramp 600 → 3600 rpm under vacuum"; hasTimer: true; hasManual: false; hasMedia: false; hasLoop: false; hasSchedule: false; hasHold: false; hasEquip: true; hasCheck: false; deviceIndex: 1; actionIndex: 2; setpoint: "600-3600 rpm"; stopIndex: 0; durationSec: "480"; requireConfirm: false; confirmMessage: "" }
        ListElement { stageId: 5; name: "Jacket cool-down to 45°C"; hasTimer: true; hasManual: false; hasMedia: false; hasLoop: false; hasSchedule: false; hasHold: false; hasEquip: true; hasCheck: false; deviceIndex: 3; actionIndex: 0; setpoint: "45.0°C"; stopIndex: 4; durationSec: "420"; requireConfirm: false; confirmMessage: "" }
        ListElement { stageId: 5; name: "Add preservative and fragrance"; hasTimer: false; hasManual: true; hasMedia: false; hasLoop: false; hasSchedule: false; hasHold: true; hasEquip: false; hasCheck: true; deviceIndex: 7; actionIndex: 0; setpoint: "45.0°C"; stopIndex: 5; durationSec: "180"; requireConfirm: true; confirmMessage: "Confirm heat-sensitive actives added at ≤45°C." }
        ListElement { stageId: 5; name: "Salt trim and vacuum deaeration"; hasTimer: true; hasManual: true; hasMedia: false; hasLoop: false; hasSchedule: false; hasHold: true; hasEquip: true; hasCheck: false; deviceIndex: 2; actionIndex: 0; setpoint: "-300 mbar"; stopIndex: 5; durationSec: "240"; requireConfirm: true; confirmMessage: "Confirm viscosity in spec before discharge." }
    }

    ListModel {
        id: bomModel
        ListElement { phase: "A"; name: "Deionized Water"; qty: "45.0"; uom: "kg" }
        ListElement { phase: "A"; name: "EDTA Disodium"; qty: "0.10"; uom: "kg" }
        ListElement { phase: "A"; name: "Citric Acid (50% sol.)"; qty: "0.30"; uom: "kg" }
        ListElement { phase: "B"; name: "SLES 28% Surfactant"; qty: "18.0"; uom: "kg" }
        ListElement { phase: "B"; name: "CAPB Foam Booster"; qty: "4.00"; uom: "kg" }
        ListElement { phase: "B"; name: "Cocamide DEA"; qty: "2.00"; uom: "kg" }
        ListElement { phase: "C"; name: "Glycol Distearate"; qty: "3.00"; uom: "kg" }
        ListElement { phase: "C"; name: "Cetyl Alcohol"; qty: "1.50"; uom: "kg" }
        ListElement { phase: "C"; name: "Dimethicone Fluid"; qty: "1.00"; uom: "kg" }
        ListElement { phase: "D"; name: "Polyquaternium-7"; qty: "1.50"; uom: "kg" }
        ListElement { phase: "D"; name: "Panthenol (Pro-Vit B5)"; qty: "0.50"; uom: "kg" }
        ListElement { phase: "E"; name: "Fragrance Oil"; qty: "0.80"; uom: "kg" }
        ListElement { phase: "E"; name: "Preservative Blend"; qty: "0.15"; uom: "kg" }
        ListElement { phase: "F"; name: "Sodium Chloride"; qty: "2.50"; uom: "kg" }
        ListElement { phase: "F"; name: "Color D&C Yellow"; qty: "0.02"; uom: "kg" }
    }

    // Flattened labels for the Parameters tab
    ListModel { id: paramViewModel }

    function rebuildParamView() {
        paramViewModel.clear()
        for (var i = 0; i < tasksModel.count; i++) {
            var t = tasksModel.get(i)
            paramViewModel.append({
                label: "T" + stageNumberForId(t.stageId) + "." + taskOrdinal(t.stageId, i),
                name: t.name,
                tagSummary: workspace.deviceTags[t.deviceIndex] || "",
                setpoint: t.setpoint,
                stopSummary: workspace.stopLabels[t.stopIndex] || ""
            })
        }
    }

    Component.onCompleted: refreshStats()

    RowLayout {
        anchors.fill: parent
        spacing: 8
        visible: workspace.currentTab === 0

        Rectangle {
            Layout.preferredWidth: 300
            Layout.fillHeight: true
            color: "#06182c"
            border.color: "#184d7e"
            radius: 6

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6
                Text { text: "STAGES  (process architecture)"; color: "#38bdf8"; font.bold: true; font.pixelSize: 11 }
                ListView {
                    id: stageList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 8
                    model: stagesModel
                    delegate: RecipeStageCard {
                        width: stageList.width
                        stageNumber: index + 1
                        stageName: model.name
                        sequentialLock: model.sequentialLock
                        selected: workspace.selectedStageId === model.stageId
                        onClicked: {
                            workspace.selectedStageId = model.stageId
                            workspace.selectFirstTaskInStage(model.stageId)
                        }
                        onNameEdited: function(value) { stagesModel.setProperty(index, "name", value) }
                        onLockToggled: {
                            stagesModel.setProperty(index, "sequentialLock", !model.sequentialLock)
                            workspace.refreshStats()
                        }
                        onMoveUp: workspace.swapModel(stagesModel, index, index - 1)
                        onMoveDown: workspace.swapModel(stagesModel, index, index + 1)
                        onDuplicated: {
                            var newId = workspace.nextStageId()
                            stagesModel.insert(index + 1, { stageId: newId, name: model.name + " (copy)", sequentialLock: model.sequentialLock })
                            workspace.refreshStats()
                        }
                        onDeleted: {
                            if (stagesModel.count <= 1)
                                return
                            workspace.removeTasksForStage(model.stageId)
                            stagesModel.remove(index)
                            workspace.selectedStageId = stagesModel.get(0).stageId
                            workspace.selectFirstTaskInStage(workspace.selectedStageId)
                            workspace.refreshStats()
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    radius: 4
                    color: "#154d80"
                    border.color: "#38bdf8"
                    Text { anchors.centerIn: parent; text: "+ Add stage"; color: "#ffffff"; font.bold: true; font.pixelSize: 12 }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: workspace.addStage() }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#06182c"
            border.color: "#184d7e"
            radius: 6

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6
                Text {
                    text: "TASKS  in Stage " + workspace.stageNumberForId(workspace.selectedStageId)
                    color: "#38bdf8"
                    font.bold: true
                    font.pixelSize: 11
                }
                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentWidth: width
                    contentHeight: taskColumn.implicitHeight
                    Column {
                        id: taskColumn
                        width: parent.width
                        spacing: 8
                        Repeater {
                            model: tasksModel
                            delegate: RecipeTaskCard {
                                width: taskColumn.width
                                visible: model.stageId === workspace.selectedStageId
                                height: visible ? (selected ? 168 : 132) : 0
                                taskLabel: "Task " + workspace.stageNumberForId(model.stageId) + "." + workspace.taskOrdinal(model.stageId, index)
                                taskName: model.name
                                selected: workspace.selectedTaskIndex === index
                                hasTimer: model.hasTimer
                                hasManual: model.hasManual
                                hasMedia: model.hasMedia
                                hasLoop: model.hasLoop
                                hasSchedule: model.hasSchedule
                                hasHold: model.hasHold
                                hasEquip: model.hasEquip
                                hasCheck: model.hasCheck
                                tagSummary: workspace.deviceTags[model.deviceIndex] || ""
                                stopSummary: (model.requireConfirm ? "HOLD · " : "") + (workspace.stopLabels[model.stopIndex] || "") + (model.setpoint !== "" ? " · " + model.setpoint : "")
                                onClicked: workspace.selectedTaskIndex = index
                                onNameEdited: function(value) { tasksModel.setProperty(index, "name", value) }
                                onTypeToggled: function(typeKey) {
                                    workspace.toggleTaskFlag(index, "has" + typeKey.charAt(0).toUpperCase() + typeKey.slice(1))
                                }
                                onAddActivity: {
                                    workspace.selectedTaskIndex = index
                                    tasksModel.setProperty(index, "hasEquip", true)
                                    workspace.refreshStats()
                                }
                                onDuplicated: workspace.duplicateTask(index)
                                onDeleted: {
                                    if (tasksModel.count <= 1)
                                        return
                                    tasksModel.remove(index)
                                    workspace.selectedTaskIndex = Math.max(0, index - 1)
                                    workspace.refreshStats()
                                }
                                onMoveUp: workspace.swapModel(tasksModel, index, index - 1)
                                onMoveDown: workspace.swapModel(tasksModel, index, index + 1)
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    radius: 4
                    color: "#154d80"
                    border.color: "#38bdf8"
                    Text { anchors.centerIn: parent; text: "+ Add task"; color: "#ffffff"; font.bold: true; font.pixelSize: 12 }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: workspace.addTask() }
                }
            }
        }

        RecipeTaskInspector {
            Layout.preferredWidth: 280
            Layout.fillHeight: true
            emptySelection: workspace.currentTask() === null
            taskLabel: workspace.currentTask() ? ("Task " + workspace.stageNumberForId(workspace.currentTask().stageId) + "." + workspace.taskOrdinal(workspace.currentTask().stageId, workspace.selectedTaskIndex)) : "Select a task"
            taskName: workspace.currentTask() ? workspace.currentTask().name : ""
            deviceIndex: workspace.currentTask() ? workspace.currentTask().deviceIndex : 0
            actionIndex: workspace.currentTask() ? workspace.currentTask().actionIndex : 0
            setpoint: workspace.currentTask() ? workspace.currentTask().setpoint : ""
            stopIndex: workspace.currentTask() ? workspace.currentTask().stopIndex : 0
            durationSec: workspace.currentTask() ? workspace.currentTask().durationSec : "0"
            requireConfirm: workspace.currentTask() ? workspace.currentTask().requireConfirm : false
            confirmMessage: workspace.currentTask() ? workspace.currentTask().confirmMessage : ""
            onNameEdited: function(value) { if (workspace.selectedTaskIndex >= 0) tasksModel.setProperty(workspace.selectedTaskIndex, "name", value) }
            onDeviceChanged: function(i) { if (workspace.selectedTaskIndex >= 0) tasksModel.setProperty(workspace.selectedTaskIndex, "deviceIndex", i) }
            onActionChanged: function(i) { if (workspace.selectedTaskIndex >= 0) tasksModel.setProperty(workspace.selectedTaskIndex, "actionIndex", i) }
            onSetpointEdited: function(value) { if (workspace.selectedTaskIndex >= 0) tasksModel.setProperty(workspace.selectedTaskIndex, "setpoint", value) }
            onStopChanged: function(i) { if (workspace.selectedTaskIndex >= 0) tasksModel.setProperty(workspace.selectedTaskIndex, "stopIndex", i) }
            onDurationEdited: function(value) { if (workspace.selectedTaskIndex >= 0) tasksModel.setProperty(workspace.selectedTaskIndex, "durationSec", value) }
            onConfirmToggled: {
                if (workspace.selectedTaskIndex < 0)
                    return
                var now = !tasksModel.get(workspace.selectedTaskIndex).requireConfirm
                tasksModel.setProperty(workspace.selectedTaskIndex, "requireConfirm", now)
                tasksModel.setProperty(workspace.selectedTaskIndex, "hasHold", now)
                workspace.refreshStats()
            }
            onConfirmMessageEdited: function(value) { if (workspace.selectedTaskIndex >= 0) tasksModel.setProperty(workspace.selectedTaskIndex, "confirmMessage", value) }
        }
    }

    RecipeParameterPanel {
        anchors.fill: parent
        visible: workspace.currentTab === 1
        taskModel: paramViewModel
    }

    RecipeBomPanel {
        anchors.fill: parent
        visible: workspace.currentTab === 2
        bomModel: bomModel
    }

    RecipeInterlockPanel {
        anchors.fill: parent
        visible: workspace.currentTab === 3
        sequentialStages: workspace.sequentialStageCount
        holdPoints: workspace.holdCount
        vesselTag: workspace.vesselTag
    }

    RecipeGovernancePanel {
        anchors.fill: parent
        visible: workspace.currentTab === 4
        recipeStatus: workspace.recipeStatus
        authorName: workspace.authorName
        reviewerName: workspace.reviewerName
        approverName: workspace.approverName
        approvalDate: workspace.approvalDate
        recipeVersion: workspace.recipeVersion
    }
}
