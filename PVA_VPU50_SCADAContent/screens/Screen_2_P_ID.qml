import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../components/widgets/Screen_2_PID"
import "../config"

Rectangle {
    id: pidScreenRoot
    width: 1440
    height: 840
    implicitWidth: 1440
    implicitHeight: 840
    color: "#0a2d52"
    clip: true

    ScadaConfig { id: scadaConfig }
    ScadaStateMiddleware { id: scadaBridge }
    property alias scadaBridge: scadaBridge

    // Base Coordinate Canvas Dimensions (Full P&ID System Canvas)
    readonly property real worldWidth: 1440
    readonly property real worldHeight: 840

    // Dynamic Viewport Fit Ratio (Fits entire P&ID comfortably without empty void)
    readonly property real fitZoom: Math.max(0.68, Math.min(width / worldWidth, height / worldHeight))

    // Zoom & Pan State
    property real zoomScale: fitZoom
    readonly property real minZoom: fitZoom
    property real maxZoom: 2.5
    property real rawPanX: (width - worldWidth * fitZoom) / 2
    property real rawPanY: (height - worldHeight * fitZoom) / 2
    property bool showTags: true

    readonly property real actualContentWidth: worldWidth * zoomScale
    readonly property real actualContentHeight: worldHeight * zoomScale

    // Padding Margins for Panning (Allows reaching all outer pipes & valves comfortably)
    readonly property real edgeMarginX: 80
    readonly property real edgeMarginY: 60

    // Intelligent Centering & Strict Viewport Boundary Clamping
    readonly property real minAllowedPanX: actualContentWidth <= width ? (width - actualContentWidth) / 2 : (width - actualContentWidth - edgeMarginX)
    readonly property real maxAllowedPanX: actualContentWidth <= width ? (width - actualContentWidth) / 2 : edgeMarginX

    readonly property real minAllowedPanY: actualContentHeight <= height ? (height - actualContentHeight) / 2 : (height - actualContentHeight - edgeMarginY)
    readonly property real maxAllowedPanY: actualContentHeight <= height ? (height - actualContentHeight) / 2 : edgeMarginY

    readonly property real displayX: actualContentWidth <= width ? (width - actualContentWidth) / 2 : Math.max(minAllowedPanX, Math.min(maxAllowedPanX, rawPanX))
    readonly property real displayY: actualContentHeight <= height ? (height - actualContentHeight) / 2 : Math.max(minAllowedPanY, Math.min(maxAllowedPanY, rawPanY))

    onWidthChanged: {
        if (zoomScale < fitZoom) zoomScale = fitZoom;
        if (actualContentWidth <= width) rawPanX = (width - actualContentWidth) / 2;
    }
    onHeightChanged: {
        if (zoomScale < fitZoom) zoomScale = fitZoom;
        if (actualContentHeight <= height) rawPanY = (height - actualContentHeight) / 2;
    }

    Component.onCompleted: {
        zoomScale = fitZoom;
        rawPanX = (width - actualContentWidth) / 2;
        rawPanY = (height - actualContentHeight) / 2;
    }

    signal componentTapped(string tagName)

    // =========================================================================
    // 1. SYNCHRONIZE UI FORM MINIMAP WITH RUNTIME PAN, ZOOM, AND SIGNALS
    // =========================================================================
    Binding { target: ui.pidMinimap; property: "viewX"; value: pidScreenRoot.displayX }
    Binding { target: ui.pidMinimap; property: "viewY"; value: pidScreenRoot.displayY }
    Binding { target: ui.pidMinimap; property: "viewWidth"; value: pidScreenRoot.width }
    Binding { target: ui.pidMinimap; property: "viewHeight"; value: pidScreenRoot.height }
    Binding { target: ui.pidMinimap; property: "zoomScale"; value: pidScreenRoot.zoomScale }
    Binding { target: ui.pidMinimap; property: "fitZoom"; value: pidScreenRoot.fitZoom }
    Binding { target: ui.pidMinimap; property: "isLegendActive"; value: pidScreenRoot.showTags }

    Connections {
        target: ui.pidMinimap
        function onLegendToggled() {
            pidScreenRoot.showTags = !pidScreenRoot.showTags;
        }
        function onFitRequested() {
            pidScreenRoot.zoomScale = pidScreenRoot.fitZoom;
            pidScreenRoot.rawPanX = (pidScreenRoot.width - pidScreenRoot.actualContentWidth) / 2;
            pidScreenRoot.rawPanY = (pidScreenRoot.height - pidScreenRoot.actualContentHeight) / 2;
        }
        function onZoomInRequested() {
            var newZoom = Math.min(pidScreenRoot.maxZoom, pidScreenRoot.zoomScale * 1.2);
            var centerWorldX = (pidScreenRoot.width / 2 - pidScreenRoot.displayX) / pidScreenRoot.zoomScale;
            var centerWorldY = (pidScreenRoot.height / 2 - pidScreenRoot.displayY) / pidScreenRoot.zoomScale;
            pidScreenRoot.zoomScale = newZoom;
            pidScreenRoot.rawPanX = pidScreenRoot.width / 2 - centerWorldX * newZoom;
            pidScreenRoot.rawPanY = pidScreenRoot.height / 2 - centerWorldY * newZoom;
        }
        function onZoomOutRequested() {
            var newZoom = Math.max(pidScreenRoot.minZoom, pidScreenRoot.zoomScale / 1.2);
            var centerWorldX = (pidScreenRoot.width / 2 - pidScreenRoot.displayX) / pidScreenRoot.zoomScale;
            var centerWorldY = (pidScreenRoot.height / 2 - pidScreenRoot.displayY) / pidScreenRoot.zoomScale;
            pidScreenRoot.zoomScale = newZoom;
            pidScreenRoot.rawPanX = pidScreenRoot.width / 2 - centerWorldX * newZoom;
            pidScreenRoot.rawPanY = pidScreenRoot.height / 2 - centerWorldY * newZoom;
        }
        function onPanRequested(tx, ty) {
            pidScreenRoot.rawPanX = Math.max(pidScreenRoot.minAllowedPanX, Math.min(pidScreenRoot.maxAllowedPanX, tx));
            pidScreenRoot.rawPanY = Math.max(pidScreenRoot.minAllowedPanY, Math.min(pidScreenRoot.maxAllowedPanY, ty));
        }
    }

    // =========================================================================
    // 2. TOUCHSCREEN & MOUSE MULTI-TOUCH PAN & ZOOM ENGINE
    // =========================================================================
    PinchArea {
        id: pinchArea
        anchors.fill: parent

        property real initialZoom: 1.0

        onPinchStarted: {
            initialZoom = pidScreenRoot.zoomScale;
        }

        onPinchUpdated: function(pinch) {
            var newZoom = Math.max(pidScreenRoot.minZoom, Math.min(pidScreenRoot.maxZoom, initialZoom * pinch.scale));
            pidScreenRoot.zoomScale = newZoom;
            pidScreenRoot.rawPanX += pinch.previousCenter.x - pinch.center.x;
            pidScreenRoot.rawPanY += pinch.previousCenter.y - pinch.center.y;
        }

        MouseArea {
            id: dragMouseArea
            anchors.fill: parent
            hoverEnabled: true

            property real lastX: 0
            property real lastY: 0
            property bool isDragging: false

            onPressed: function(mouse) {
                lastX = mouse.x;
                lastY = mouse.y;
                isDragging = true;
            }

            onPositionChanged: function(mouse) {
                if (isDragging && (mouse.buttons & Qt.LeftButton)) {
                    var dx = mouse.x - lastX;
                    var dy = mouse.y - lastY;
                    lastX = mouse.x;
                    lastY = mouse.y;

                    pidScreenRoot.rawPanX = Math.max(pidScreenRoot.minAllowedPanX, Math.min(pidScreenRoot.maxAllowedPanX, pidScreenRoot.rawPanX + dx));
                    pidScreenRoot.rawPanY = Math.max(pidScreenRoot.minAllowedPanY, Math.min(pidScreenRoot.maxAllowedPanY, pidScreenRoot.rawPanY + dy));
                }
            }

            onReleased: {
                isDragging = false;
            }

            onWheel: function(wheel) {
                var factor = wheel.angleDelta.y > 0 ? 1.12 : 0.88;
                var oldZoom = pidScreenRoot.zoomScale;
                var newZoom = Math.max(pidScreenRoot.minZoom, Math.min(pidScreenRoot.maxZoom, oldZoom * factor));

                if (newZoom !== oldZoom) {
                    var curX = pidScreenRoot.displayX;
                    var curY = pidScreenRoot.displayY;
                    var mouseWorldX = (wheel.x - curX) / oldZoom;
                    var mouseWorldY = (wheel.y - curY) / oldZoom;

                    pidScreenRoot.zoomScale = newZoom;
                    pidScreenRoot.rawPanX = wheel.x - mouseWorldX * newZoom;
                    pidScreenRoot.rawPanY = wheel.y - mouseWorldY * newZoom;
                }
            }
        }
    }

    // =========================================================================
    // 3. DECLARATIVE QT DESIGNER FORM VIEW INSTANCE & RUNTIME BINDINGS
    // =========================================================================
    Screen_2_P_IDView {
        id: ui
        anchors.fill: parent
        showTags: pidScreenRoot.showTags
        worldScale: pidScreenRoot.zoomScale
        worldX: pidScreenRoot.displayX
        worldY: pidScreenRoot.displayY

        // Process Vessel Live Telemetry
        mainVessel.levelPercent: scadaBridge.vesselLevelPercent
        mainVessel.vesselTemp: scadaBridge.vesselTemp
        mainVessel.jacketTemp: scadaBridge.jacketTemp
        mainVessel.vacuumPressure: scadaBridge.vacuumPressure
        mainVessel.weightKg: scadaBridge.vesselWeightKg
        mainVessel.isHeating: scadaBridge.isHeating
        mainVessel.isCooling: scadaBridge.isCooling

        // Thermal Jacket Effects
        heatingEffect.isHeating: scadaBridge.isHeating
        heatingEffect.isCooling: scadaBridge.isCooling
        heatingEffect.levelPercent: scadaBridge.vesselLevelPercent

        // Agitator State & Direction Linkage
        agitator.speedRpm: scadaBridge.agitatorSpeed
        agitator.isRunning: scadaBridge.isAgitatorRunning
        agitator.rotationMode: scadaBridge.agitatorMode

        // Elevated Level Gauge
        levelGauge.levelPercent: scadaBridge.vesselLevelPercent

        // CIP Spray Balls (Dynamic Green during CIP)
        sprayBall1.isSpraying: scadaBridge.isCipActive
        sprayBall2.isSpraying: scadaBridge.isCipActive
        sprayBall3.isSpraying: scadaBridge.isCipActive

        // Unified Dedicated Piping Layer Flow Dynamics
        pipingLayer.isRecirculating: scadaBridge.isRecirculating
        pipingLayer.isHeating: scadaBridge.isHeating
        pipingLayer.isCooling: scadaBridge.isCooling
        pipingLayer.isSprayingCIP: scadaBridge.isCipActive
        pipingLayer.isHomogRunning: scadaBridge.isHomogenizerRunning

        // Bottom Homogenizer
        bottomHomog.speedRpm: scadaBridge.homogenizerSpeed
        bottomHomog.isRunning: scadaBridge.isHomogenizerRunning
        bottomHomog.onMotorClicked: pidScreenRoot.componentTapped("M 163 001")

        // Inline Heater, Circulation Pump & Seal Pot
        inlineHeater.isHeating: scadaBridge.isHeating
        circPump1.isRunning: scadaBridge.isHeating || scadaBridge.isCooling
        pressGauge1.pressureBar: (scadaBridge.isHeating || scadaBridge.isCooling) ? 2.4 : 0.0
        sealPot.isHeating: scadaBridge.isHeating
        sealPot.currentTemp: scadaBridge.jacketTemp

        // Dynamic Telemetry & Diagnostic Boxes Live Bindings
        boxVesselJacket.row1Value: scadaBridge.vesselTemp.toFixed(1)
        boxVesselJacket.row2Value: scadaBridge.jacketTemp.toFixed(1)
        boxVesselJacket.row3Value: scadaBridge.vacuumPressure.toFixed(1)
        boxVesselJacket.row4Value: scadaBridge.vesselWeightKg.toFixed(1)
        boxVesselJacket.row5Value: scadaBridge.vesselLevelPercent.toFixed(1)
        boxVesselJacket.row6Value: "1.2"

        boxHeating.row1Value: scadaBridge.targetTemp.toFixed(1)
        boxHeating.row2Value: scadaBridge.jacketTemp.toFixed(1)
        boxHeating.row3Value: "2.4"
        boxHeating.row4Value: scadaBridge.isHeating ? "45.0" : "0.0"
        boxHeating.row5Value: (scadaBridge.isHeating || scadaBridge.isCooling) ? "14.2" : "0.0"
        boxHeating.row6Value: scadaBridge.isHeating ? "Heating" : (scadaBridge.isCooling ? "Cooling" : "Standby")

        boxSealPot.row1Value: (scadaBridge.jacketTemp * 0.85 + 5.0).toFixed(1)
        boxSealPot.row2Value: "1.8"
        boxSealPot.row3Value: "85.0"
        boxSealPot.row4Value: scadaBridge.isHomogenizerRunning ? "Active" : "Normal"

        // Valve Runtime State & Click Handlers
        vK163002.isOpen: scadaBridge.isHomogenizerRunning
        vK165001.isOpen: scadaBridge.isCipActive
        vK165002.isOpen: scadaBridge.isRecirculating || scadaBridge.isCipActive
        vK165003.isOpen: scadaBridge.isRecirculating
        vK168201.isOpen: false
        vK168202.isOpen: false
        vK168204.isOpen: scadaBridge.isHeating || scadaBridge.isCooling || scadaBridge.isCirculationRunning

        vK143002.mouseArea.onClicked: pidScreenRoot.componentTapped("K 143 002")
        vK143001.mouseArea.onClicked: pidScreenRoot.componentTapped("K 143 001")
        vK163002.mouseArea.onClicked: pidScreenRoot.componentTapped("K 163 002")
        vK165001.mouseArea.onClicked: pidScreenRoot.componentTapped("K 165 001")
        vK165002.mouseArea.onClicked: pidScreenRoot.componentTapped("K 165 002")
        vK165003.mouseArea.onClicked: pidScreenRoot.componentTapped("K 165 003")
        vK165004.mouseArea.onClicked: pidScreenRoot.componentTapped("K 165 004")
        vK168201.mouseArea.onClicked: pidScreenRoot.componentTapped("K 168 201")
        vK168202.mouseArea.onClicked: pidScreenRoot.componentTapped("K 168 202")
        vK168204.mouseArea.onClicked: pidScreenRoot.componentTapped("K 168 204")

        isRecipeRunning: scadaBridge.isRecipeRunning
        activeRecipeName: scadaBridge.activeRecipeName
        currentRecipeStepIndex: scadaBridge.currentRecipeStepIndex
        currentRecipeStepName: scadaBridge.currentRecipeStepName
        stepTimerRemaining: scadaBridge.stepTimerSec
        batchTimerElapsed: scadaBridge.batchTimerSec
        activeOpDevices: scadaBridge.activeOpDevices
    }
}
