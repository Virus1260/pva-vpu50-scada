/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML.
*/
import QtQuick
import QtQuick.Layouts
import "../components/widgets/Screen_2_PID"

Rectangle {
    id: pidViewRoot
    width: 1440
    height: 840
    color: "#0a2d52"
    clip: true

    // Visual State Properties (Exposed for Qt Design Studio Property Inspector)
    property bool showTags: true
    property real worldScale: 1.0
    property real worldX: 0
    property real worldY: 0

    // Live Recipe HUD Broadcast Properties
    property bool isRecipeRunning: false
    property string activeRecipeName: "Industrial Shampoo Formulation"
    property int currentRecipeStepIndex: 0
    property string currentRecipeStepName: "Phase A: Initial Water Charge"
    property int stepTimerRemaining: 180
    property int batchTimerElapsed: 0
    property string activeOpDevices: "Fill Valve (SP: 55%)"

    // =========================================================================
    // 3-LAYER P&ID ARCHITECTURAL ALIASES
    // =========================================================================
    property alias worldContainer: worldContainer
    property alias equipmentLayer: equipmentLayer
    property alias instrumentationLayer: equipmentLayer.instrumentationLayer
    property alias pipingLayer: equipmentLayer.pipingLayer
    property alias pidMinimap: pidMinimap

    // Direct Equipment Aliases (Layer 3)
    property alias mainVessel: equipmentLayer.mainVessel
    property alias heatingEffect: equipmentLayer.heatingEffect
    property alias agitator: equipmentLayer.agitator
    property alias circPump1: equipmentLayer.circPump1
    property alias inlineHeater: equipmentLayer.inlineHeater
    property alias sealPot: equipmentLayer.sealPot
    property alias bottomHomog: equipmentLayer.bottomHomog

    // Direct Instrumentation & Valve Aliases (Layer 2)
    property alias vK143002: equipmentLayer.vK143002
    property alias vK143001: equipmentLayer.vK143001
    property alias vK163002: equipmentLayer.vK163002
    property alias vK168201: equipmentLayer.vK168201
    property alias vK168202: equipmentLayer.vK168202
    property alias vK168204: equipmentLayer.vK168204
    property alias vK165001: equipmentLayer.vK165001
    property alias vK165002: equipmentLayer.vK165002
    property alias vK165003: equipmentLayer.vK165003
    property alias vK165004: equipmentLayer.vK165004
    property alias pressGauge1: equipmentLayer.pressGauge1
    property alias sprayBall1: equipmentLayer.sprayBall1
    property alias sprayBall2: equipmentLayer.sprayBall2
    property alias sprayBall3: equipmentLayer.sprayBall3
    property alias levelGauge: equipmentLayer.levelGauge
    property alias boxVesselJacket: equipmentLayer.boxVesselJacket
    property alias boxHeating: equipmentLayer.boxHeating
    property alias boxSealPot: equipmentLayer.boxSealPot

    // =========================================================================
    // ZOOMABLE & PANNABLE WORLD CANVAS (Interactive in Qt Design Studio Canvas)
    // =========================================================================
    Item {
        id: worldContainer
        width: 1440
        height: 840
        scale: pidViewRoot.worldScale
        x: pidViewRoot.worldX
        y: pidViewRoot.worldY
        transformOrigin: Item.TopLeft

        // ---------------------------------------------------------------------
        // P&ID LAYER 3 (Contains Layer 2 Instrumentation & Layer 1 Piping)
        // ---------------------------------------------------------------------
        P_ID_Layer_3_Equipments {
            id: equipmentLayer
            anchors.fill: parent
            showTags: pidViewRoot.showTags
        }
    }

    // =========================================================================
    // FLOATING OVERVIEW NAVIGATOR & RADAR MINIMAP (100% Qt Design Studio Visible)
    // =========================================================================
    PidMinimap {
        id: pidMinimap
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 14
        z: 100
        contentWidth: 1440
        contentHeight: 840
        viewWidth: 1440
        viewHeight: 840
        zoomScale: pidViewRoot.worldScale
        isLegendActive: pidViewRoot.showTags
    }

    // =========================================================================
    // FLOATING RECIPE LIVE EXECUTION HUD (Broadcasts live from Screen 5)
    // =========================================================================
    Rectangle {
        id: recipeLiveHud
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 14
        width: 320
        height: 84
        radius: 6
        color: pidViewRoot.isRecipeRunning ? "#08223f" : "#071c33"
        border.color: pidViewRoot.isRecipeRunning ? "#00d2ff" : "#1e3a8a"
        border.width: 1.4
        z: 100

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 3

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Rectangle {
                    Layout.preferredWidth: 8
                    Layout.preferredHeight: 8
                    radius: 4
                    color: pidViewRoot.isRecipeRunning ? "#22c55e" : "#f59e0b"
                }

                Text {
                    text: pidViewRoot.isRecipeRunning ? "RECIPE RUNNING" : "RECIPE STANDBY"
                    color: pidViewRoot.isRecipeRunning ? "#86efac" : "#fde68a"
                    font.bold: true
                    font.pixelSize: 9
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "Phase " + (pidViewRoot.currentRecipeStepIndex + 1) + "/5"
                    color: "#38bdf8"
                    font.bold: true
                    font.pixelSize: 10
                }
            }

            Text {
                text: pidViewRoot.currentRecipeStepName
                color: "#ffffff"
                font.bold: true
                font.pixelSize: 11
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Active: " + pidViewRoot.activeOpDevices
                    color: "#94a3b8"
                    font.pixelSize: 9
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: pidViewRoot.stepTimerRemaining + "s"
                    color: "#f5d033"
                    font.bold: true
                    font.pixelSize: 11
                }
            }
        }
    }
}
