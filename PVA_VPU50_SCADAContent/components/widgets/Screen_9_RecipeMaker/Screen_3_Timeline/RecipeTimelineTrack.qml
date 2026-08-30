pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "."
import "../.."

Rectangle {
    id: trackRoot
    implicitHeight: 52
    implicitWidth: 800
    Layout.fillWidth: true
    color: "#081d33"
    border.color: "#1d5b94"
    border.width: 1
    radius: 4

    property string trackId: "track_1"
    property string trackTitle: "1M1501 Agitator"
    property string trackIcon: "stirrer_anchor"
    property string trackType: "agitator"
    property bool isMuted: false
    property bool isLocked: false

    property var phaseAClipped: null
    property var phaseBClipped: null
    property var phaseCClipped: null
    property var phaseDClipped: null
    property var phaseEClipped: null

    signal addClipRequested(string phaseName, string resourceType)
    signal configureClipRequested(var clipData)
    signal deleteClipRequested(string phaseName)

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // 1. Left Track Header (MAGIX / Premiere multi-track style)
        Rectangle {
            Layout.preferredWidth: 150
            Layout.fillHeight: true
            color: "#0b2e52"
            border.color: "#1d5b94"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 6
                spacing: 6

                ScadaIcon {
                    Layout.preferredWidth: 18
                    Layout.preferredHeight: 18
                    iconName: trackRoot.trackIcon
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1
                    Text {
                        text: trackRoot.trackTitle
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 10
                        elide: Text.ElideRight
                    }
                    Text {
                        text: trackRoot.trackType.toUpperCase()
                        color: "#38bdf8"
                        font.pixelSize: 8
                    }
                }

                // Track Lock Button
                Rectangle {
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16
                    radius: 2
                    color: trackRoot.isLocked ? "#b45309" : "#081d33"
                    Text {
                        anchors.centerIn: parent
                        text: "🔒"
                        color: "#cbd5e1"
                        font.pixelSize: 9
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: trackRoot.isLocked = !trackRoot.isLocked
                    }
                }
            }
        }

        // 2. Timeline Phase Columns (Phase A, B, C, D, E)
        Repeater {
            model: [
                { phase: "Phase A", pIndex: 0, clip: trackRoot.phaseAClipped },
                { phase: "Phase B", pIndex: 1, clip: trackRoot.phaseBClipped },
                { phase: "Phase C", pIndex: 2, clip: trackRoot.phaseCClipped },
                { phase: "Phase D", pIndex: 3, clip: trackRoot.phaseDClipped },
                { phase: "Phase E", pIndex: 4, clip: trackRoot.phaseEClipped }
            ]
            delegate: Rectangle {
                id: phaseSlot
                required property var modelData
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: slotMouse.containsMouse ? "#124373" : (phaseSlot.modelData.pIndex % 2 === 0 ? "#071c32" : "#092440")
                border.color: "#163f68"
                border.width: 1

                // Drop Target / Add Trigger if Empty
                Item {
                    anchors.fill: parent
                    anchors.margins: 4
                    visible: !phaseSlot.modelData.clip

                    Rectangle {
                        anchors.fill: parent
                        radius: 3
                        color: slotMouse.containsMouse ? "#0f3a69" : "#00000000"
                        border.color: slotMouse.containsMouse ? "#38bdf8" : "#1a4670"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            visible: slotMouse.containsMouse
                            text: "+ Add " + trackRoot.trackTitle
                            color: "#38bdf8"
                            font.pixelSize: 9
                            font.bold: true
                        }
                    }
                }

                // Rendered Clip if present
                RecipeTimelineClip {
                    anchors.fill: parent
                    anchors.margins: 3
                    visible: !!phaseSlot.modelData.clip
                    stageId: phaseSlot.modelData.clip ? (phaseSlot.modelData.clip.stageId || "1.1") : ""
                    phase: phaseSlot.modelData.phase
                    resourceType: trackRoot.trackType
                    resourceName: trackRoot.trackTitle
                    setValue: phaseSlot.modelData.clip ? (phaseSlot.modelData.clip.setValue || 0) : 0
                    unit: phaseSlot.modelData.clip ? (phaseSlot.modelData.clip.unit || "") : ""
                    purpose: phaseSlot.modelData.clip ? (phaseSlot.modelData.clip.purpose || "") : ""
                    materials: phaseSlot.modelData.clip ? (phaseSlot.modelData.clip.materials || []) : []
                    requireConfirm: phaseSlot.modelData.clip ? (phaseSlot.modelData.clip.requireConfirm || false) : false
                    confirmMessage: phaseSlot.modelData.clip ? (phaseSlot.modelData.clip.confirmMessage || "") : ""
                    durationSec: phaseSlot.modelData.clip ? (phaseSlot.modelData.clip.durationSec || 180) : 180
                    stopCondition: phaseSlot.modelData.clip ? (phaseSlot.modelData.clip.stopCondition || "timer") : "timer"
                    actionRequired: phaseSlot.modelData.clip ? (phaseSlot.modelData.clip.actionRequired || "OPEN") : "OPEN"
                    actionTarget: phaseSlot.modelData.clip ? (phaseSlot.modelData.clip.actionTarget || "") : ""

                    onConfigureClicked: {
                        if (phaseSlot.modelData.clip) {
                            trackRoot.configureClipRequested(phaseSlot.modelData.clip);
                        }
                    }
                    onDeleteClicked: {
                        trackRoot.deleteClipRequested(phaseSlot.modelData.phase);
                    }
                }

                MouseArea {
                    id: slotMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: !phaseSlot.modelData.clip
                    onClicked: {
                        trackRoot.addClipRequested(phaseSlot.modelData.phase, trackRoot.trackType);
                    }
                }
            }
        }
    }
}
