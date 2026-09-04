import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../config"

Item {
    id: trendsContainer
    width: 1184
    height: 626
    implicitWidth: 1184
    implicitHeight: 626
    Layout.fillWidth: true
    Layout.fillHeight: true

    ScadaStateMiddleware { id: stateMiddleware }

    property var persistentHistory: []
    property real inspectX: -1
    property real inspectY: -1
    property real zoomStartRatio: 0.0
    property real zoomEndRatio: 1.0
    property bool isZoomed: false
    property int windowDurationSec: 300 // Default: 5 minutes = 300 seconds
    property real scrubRatio: 1.0 // 1.0 = live edge

    Screen_3_TrendsView {
        id: ui
        anchors.fill: parent
        activeMode: "chart"
        isZoomed: trendsContainer.isZoomed
        isLiveStreaming: true
        activeTimePreset: "5min"
    }

    function formatTimeOnly(epochMs) {
        var d = new Date(epochMs);
        var hrs = String(d.getHours()).padStart(2, '0');
        var mins = String(d.getMinutes()).padStart(2, '0');
        var secs = String(d.getSeconds()).padStart(2, '0');
        return hrs + ":" + mins + ":" + secs;
    }

    function formatDateOnly(epochMs) {
        var d = new Date(epochMs);
        var day = String(d.getDate()).padStart(2, '0');
        var month = String(d.getMonth() + 1).padStart(2, '0');
        var year = d.getFullYear();
        return day + "/" + month + "/" + year;
    }

    function formatFullDateTime(epochMs) {
        var d = new Date(epochMs);
        var day = String(d.getDate()).padStart(2, '0');
        var month = String(d.getMonth() + 1).padStart(2, '0');
        var year = d.getFullYear();
        var hrs = String(d.getHours()).padStart(2, '0');
        var mins = String(d.getMinutes()).padStart(2, '0');
        var secs = String(d.getSeconds()).padStart(2, '0');
        return day + "/" + month + "/" + year + " " + hrs + ":" + mins + ":" + secs + " UTC";
    }

    // Helper: Build Multi-Column Telemetry Table Rows
    function refreshTableView() {
        var visibleData = getVisibleDataSlice();
        var sensorModel = ui.sensorListViewItem.model;
        if (!sensorModel) return;

        // 1. Gather active sensors list
        var activeSensors = [];
        for (var s = 0; s < sensorModel.count; s++) {
            var ch = sensorModel.get(s);
            if (ch.active) {
                activeSensors.push(ch);
            }
        }

        // 2. Build rows with individual column values
        var tableRows = [];
        for (var i = visibleData.length - 1; i >= 0; i--) {
            var pt = visibleData[i];
            var cols = [];
            for (var a = 0; a < activeSensors.length; a++) {
                var sItem = activeSensors[a];
                var valNum = pt[sItem.field] !== undefined ? pt[sItem.field] : 0.0;
                cols.push({
                    val: (valNum % 1 === 0 ? valNum.toFixed(0) : valNum.toFixed(1)) + " " + sItem.unit,
                    color: sItem.color
                });
            }
            tableRows.push({
                time: pt.time,
                sensorCols: cols
            });
        }
        ui.telemetryList.model = tableRows;
    }

    // Helper: Get Current Visible Slice from History (Starts strictly at oldest available real data)
    function getVisibleDataSlice() {
        var total = trendsContainer.persistentHistory.length;
        if (total === 0) return [];

        var oldestEpoch = trendsContainer.persistentHistory[0].epoch;
        var liveEpoch = trendsContainer.persistentHistory[total - 1].epoch;
        var reqDurationMs = trendsContainer.windowDurationSec * 1000;

        var endEpoch = liveEpoch;
        if (!ui.isLiveStreaming) {
            var minEnd = oldestEpoch + Math.min(reqDurationMs, liveEpoch - oldestEpoch);
            endEpoch = Math.max(minEnd, oldestEpoch + (liveEpoch - oldestEpoch) * trendsContainer.scrubRatio);
        }
        
        // Start strictly at the oldest real data if requested window exceeds available logging history
        var startEpoch = Math.max(oldestEpoch, endEpoch - reqDurationMs);

        ui.startTimeLabel = formatTimeOnly(startEpoch);
        ui.endTimeLabel = formatTimeOnly(endEpoch);

        var slice = [];
        for (var i = 0; i < total; i++) {
            var p = trendsContainer.persistentHistory[i];
            if (p.epoch >= startEpoch && p.epoch <= endEpoch) {
                slice.push(p);
            }
        }

        if (slice.length < 2 && total >= 2) {
            slice = trendsContainer.persistentHistory.slice(Math.max(0, total - 60));
        }

        if (trendsContainer.isZoomed && slice.length > 2) {
            var zStart = Math.floor(slice.length * trendsContainer.zoomStartRatio);
            var zEnd = Math.min(slice.length, Math.ceil(slice.length * trendsContainer.zoomEndRatio));
            slice = slice.slice(zStart, Math.max(zStart + 2, zEnd));
        }
        return slice;
    }

    // Dynamic Unit Title & Table Header Column Calculation
    function updateYAxisTitle() {
        var activeCount = 0;
        var activeUnits = [];
        var sensorModel = ui.sensorListViewItem.model;
        if (!sensorModel) return;

        // Synchronize Multi-Column Table Header Model
        ui.tableHeaderModelItem.clear();

        for (var i = 0; i < sensorModel.count; i++) {
            var item = sensorModel.get(i);
            if (item.active) {
                activeCount++;
                if (activeUnits.indexOf(item.unit) === -1) {
                    activeUnits.push(item.unit);
                }
                ui.tableHeaderModelItem.append({
                    tag: item.tag,
                    desc: item.desc,
                    unit: item.unit,
                    color: item.color,
                    field: item.field
                });
            }
        }

        if (activeCount === 0) {
            ui.yAxisTitle = "No Sensors Selected (Select from Left Panel)";
        } else if (activeCount === 1) {
            var singleItem = null;
            for (var j = 0; j < sensorModel.count; j++) {
                if (sensorModel.get(j).active) { singleItem = sensorModel.get(j); break; }
            }
            if (singleItem) {
                ui.yAxisTitle = singleItem.tag + " (" + singleItem.unit + ") [Range: " + singleItem.rangeMin + " to " + singleItem.rangeMax + " " + singleItem.unit + "]";
            }
        } else if (activeUnits.length === 1) {
            ui.yAxisTitle = "All Selected Channels (" + activeUnits[0] + ")";
        } else {
            ui.yAxisTitle = "Multi-Variable Process View (% Engineering Scale)";
        }

        ui.trendCanvasItem.requestPaint();
        refreshTableView();
    }

    // Interactive Resizer for Left Sensor Panel
    MouseArea {
        parent: ui.panelSplitterHandle
        anchors.fill: parent
        cursorShape: Qt.SizeHorCursor
        property real startX: 0
        property real startWidth: 0

        onPressed: function(mouse) {
            startX = mouse.x;
            startWidth = ui.sensorPanelWidth;
        }

        onPositionChanged: function(mouse) {
            if (pressed) {
                var newW = Math.max(280, Math.min(480, startWidth + (mouse.x - startX)));
                ui.sensorPanelWidth = newW;
            }
        }
    }

    // Mode Toggle (Graph vs Table)
    MouseArea { parent: ui.chartModeBtn; anchors.fill: parent; onClicked: { ui.activeMode = "chart"; refreshTableView(); } }
    MouseArea { parent: ui.tableModeBtn; anchors.fill: parent; onClicked: { ui.activeMode = "table"; refreshTableView(); } }

    // Live Streaming Toggle (Pause vs Resume Live)
    MouseArea {
        parent: ui.liveStreamBtn
        anchors.fill: parent
        onClicked: {
            ui.isLiveStreaming = !ui.isLiveStreaming;
            if (ui.isLiveStreaming) {
                trendsContainer.scrubRatio = 1.0;
                trendsContainer.zoomStartRatio = 0.0;
                trendsContainer.zoomEndRatio = 1.0;
                trendsContainer.isZoomed = false;
                ui.timeSliderItem.value = 100;
                ui.trendCanvasItem.requestPaint();
                refreshTableView();
            }
        }
    }

    // Reset Zoom
    MouseArea {
        parent: ui.resetZoomBtn
        anchors.fill: parent
        onClicked: {
            trendsContainer.zoomStartRatio = 0.0;
            trendsContainer.zoomEndRatio = 1.0;
            trendsContainer.isZoomed = false;
            ui.dragBoxOverlay.visible = false;
            ui.trendCanvasItem.requestPaint();
            refreshTableView();
        }
    }

    // Time Preset Selectors (1m, 5m, 15m, 1h, 8h, 24h)
    MouseArea { parent: ui.t1MinBtn; anchors.fill: parent; onClicked: { ui.activeTimePreset = "1min"; trendsContainer.windowDurationSec = stateMiddleware.config.getPresetDuration("1min"); updateYAxisTitle(); } }
    MouseArea { parent: ui.t5MinBtn; anchors.fill: parent; onClicked: { ui.activeTimePreset = "5min"; trendsContainer.windowDurationSec = stateMiddleware.config.getPresetDuration("5min"); updateYAxisTitle(); } }
    MouseArea { parent: ui.t15MinBtn; anchors.fill: parent; onClicked: { ui.activeTimePreset = "15min"; trendsContainer.windowDurationSec = stateMiddleware.config.getPresetDuration("15min"); updateYAxisTitle(); } }
    MouseArea { parent: ui.t1HourBtn; anchors.fill: parent; onClicked: { ui.activeTimePreset = "1h"; trendsContainer.windowDurationSec = stateMiddleware.config.getPresetDuration("1h"); updateYAxisTitle(); } }
    MouseArea { parent: ui.t8HourBtn; anchors.fill: parent; onClicked: { ui.activeTimePreset = "8h"; trendsContainer.windowDurationSec = stateMiddleware.config.getPresetDuration("8h"); updateYAxisTitle(); } }
    MouseArea { parent: ui.t24HourBtn; anchors.fill: parent; onClicked: { ui.activeTimePreset = "24h"; trendsContainer.windowDurationSec = stateMiddleware.config.getPresetDuration("24h"); updateYAxisTitle(); } }

    // Timeline History Steppers & Slider (Free X-Axis Panning When Paused)
    MouseArea {
        parent: ui.panStartBtn
        anchors.fill: parent
        onClicked: {
            ui.isLiveStreaming = false;
            trendsContainer.scrubRatio = 0.0;
            ui.timeSliderItem.value = 0;
            ui.trendCanvasItem.requestPaint();
            refreshTableView();
        }
    }

    MouseArea {
        parent: ui.panLiveBtn
        anchors.fill: parent
        onClicked: {
            ui.isLiveStreaming = true;
            trendsContainer.scrubRatio = 1.0;
            trendsContainer.zoomStartRatio = 0.0;
            trendsContainer.zoomEndRatio = 1.0;
            trendsContainer.isZoomed = false;
            ui.timeSliderItem.value = 100;
            ui.trendCanvasItem.requestPaint();
            refreshTableView();
        }
    }

    // Timeline Slider Drag
    Connections {
        target: ui.timeSliderItem
        function onMoved() {
            var val = ui.timeSliderItem.value; // 0 to 100
            trendsContainer.scrubRatio = val / 100.0;
            if (val < 98) {
                ui.isLiveStreaming = false;
            } else {
                ui.isLiveStreaming = true;
            }
            ui.trendCanvasItem.requestPaint();
            refreshTableView();
        }
    }

    // Full Sized "Select All" / "Clear All" Buttons
    MouseArea {
        parent: ui.selectAllBtnItem
        anchors.fill: parent
        onClicked: {
            var model = ui.sensorListViewItem.model;
            for (var i = 0; i < model.count; i++) {
                model.setProperty(i, "active", true);
            }
            updateYAxisTitle();
        }
    }

    MouseArea {
        parent: ui.clearAllBtnItem
        anchors.fill: parent
        onClicked: {
            var model = ui.sensorListViewItem.model;
            for (var i = 0; i < model.count; i++) {
                model.setProperty(i, "active", false);
            }
            updateYAxisTitle();
        }
    }

    // Sensor Item Click Toggling via MouseArea
    MouseArea {
        parent: ui.sensorListViewItem
        anchors.fill: parent
        onClicked: function(mouse) {
            var idx = ui.sensorListViewItem.indexAt(mouse.x, mouse.y + ui.sensorListViewItem.contentY);
            var model = ui.sensorListViewItem.model;
            if (model && idx >= 0 && idx < model.count) {
                var cur = model.get(idx).active;
                model.setProperty(idx, "active", !cur);
                updateYAxisTitle();
            }
        }
    }

    // Real-Time Sampler (Appends continuously to persistent buffer)
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var now = new Date();
            var nowEpoch = now.getTime();
            var timeStr = trendsContainer.formatTimeOnly(nowEpoch);

            var t_vessel = stateMiddleware.vesselTemp + (Math.random() * 0.3 - 0.15);
            var t_jacket = t_vessel + 12.0 + (Math.random() * 0.4 - 0.2);
            var vac = stateMiddleware.vacuumPressure + (Math.random() * 1.5 - 0.75);
            var sp_agitator = stateMiddleware.agitatorSpeed + (Math.random() * 0.3 - 0.15);
            var sp_homo = stateMiddleware.homogenizerSpeed + (Math.random() * 8.0 - 4.0);

            var sample = {
                epoch: nowEpoch,
                time: timeStr,
                temp_vessel: t_vessel,
                temp_jacket: t_jacket,
                temp_heater1: t_jacket - 3.5 + (Math.random() * 0.2),
                temp_heater2: t_jacket - 4.0 + (Math.random() * 0.2),
                temp_lid: t_vessel - 6.0 + (Math.random() * 0.2),
                temp_coolwater: 21.5 + (Math.random() * 0.2),
                temp_condensate: 88.2 + (Math.random() * 0.4),
                vacuum_pressure: vac,
                press_steam: 1.8 + (Math.random() * 0.03 - 0.015),
                press_air: 5.5 + (Math.random() * 0.05 - 0.025),
                press_nitrogen: 1.2 + (Math.random() * 0.02 - 0.01),
                press_hydraulic: 120.0 + (Math.random() * 0.5 - 0.25),
                speed_agitator: sp_agitator,
                speed_scraper: sp_agitator > 0 ? (sp_agitator * 0.5) : 0.0,
                speed_homo: sp_homo,
                speed_pump: sp_homo > 0 ? 350.0 : 0.0,
                speed_cip: 0.0,
                weight_product: 42.5 + (Math.random() * 0.05 - 0.025),
                ph_value: 6.8 + (Math.random() * 0.02 - 0.01),
                viscosity_cp: 12400.0 + (Math.random() * 50.0 - 25.0),
                power_kw: (sp_agitator * 0.08) + (sp_homo * 0.003) + 3.5,
                curr_agitator: sp_agitator * 0.03 + 0.5,
                curr_homo: sp_homo * 0.002 + 0.5,
                curr_hydraulic: 0.0
            };

            // Maintain up to 3000 historical samples
            trendsContainer.persistentHistory.push(sample);
            if (trendsContainer.persistentHistory.length > 3000) {
                trendsContainer.persistentHistory.shift();
            }

            // Update live readouts on sensor cards
            var model = ui.sensorListViewItem.model;
            if (model) {
                for (var s = 0; s < model.count; s++) {
                    var f = model.get(s).field;
                    if (sample[f] !== undefined) {
                        var valStr = (sample[f] % 1 === 0 ? sample[f].toFixed(0) : sample[f].toFixed(1)) + " " + model.get(s).unit;
                        model.setProperty(s, "val", valStr);
                    }
                }
            }

            // If in LIVE mode, automatically stay glued to the live edge
            if (ui.isLiveStreaming) {
                ui.timeSliderItem.value = 100;
                ui.trendCanvasItem.requestPaint();
                if (ui.activeMode === "table") {
                    refreshTableView();
                }
            }
        }
    }

    Component.onCompleted: {
        var initial = [];
        var nowEpoch = Date.now();
        
        // Realistic continuous active batch run (15 minutes of real data starting at batch start):
        var totalSteps = 90;
        var batchHistorySec = 900; // 15 minutes of authentic active batch run

        for (var i = 0; i <= totalSteps; i++) {
            var stepOffsetSec = (1.0 - (i / totalSteps)) * batchHistorySec;
            var pointEpoch = nowEpoch - (stepOffsetSec * 1000);
            var timeStr = trendsContainer.formatTimeOnly(pointEpoch);

            var progress = i / totalSteps;
            
            // Authentic batch progression up to current live state:
            var tv = 25.0 + progress * 9.4; // 25.0°C to 34.4°C
            var tj = tv + 12.5; // Jacket tracks above vessel
            var vp = -20.0 - progress * 430.0; // 0 to -450 mbar
            var sa = progress > 0.1 ? 35.0 : (progress * 350.0); // Agitator ramps to 35 rpm
            var sh = 0.0;

            initial.push({
                epoch: pointEpoch,
                time: timeStr,
                temp_vessel: tv, temp_jacket: tj, temp_heater1: tj - 3.5, temp_heater2: tj - 4.0, temp_lid: tv - 6.0,
                temp_coolwater: 21.5, temp_condensate: 88.2,
                vacuum_pressure: vp, press_steam: 1.8, press_air: 5.5, press_nitrogen: 1.2, press_hydraulic: 120.0,
                speed_agitator: sa, speed_scraper: sa * 0.5, speed_homo: sh, speed_pump: 0.0, speed_cip: 0.0,
                weight_product: 42.5, ph_value: 6.8, viscosity_cp: 12400.0,
                power_kw: 3.5 + (sa * 0.08), curr_agitator: 1.2, curr_homo: 0.5, curr_hydraulic: 0.0
            });
        }
        persistentHistory = initial;
        updateYAxisTitle();

        // Canvas Paint Routine
        ui.trendCanvasItem.paint.connect(function() {
            var ctx = ui.trendCanvasItem.getContext("2d");
            ctx.clearRect(0, 0, ui.trendCanvasItem.width, ui.trendCanvasItem.height);

            var w = ui.trendCanvasItem.width - 90;
            var h = ui.trendCanvasItem.height - 58;
            var ox = 70;
            var oy = 15;

            // Grid Lines & Dynamic Y-Axis Labels
            ctx.strokeStyle = "#0d2f52";
            ctx.lineWidth = 1;

            var sensorModel = ui.sensorListViewItem.model;
            var activeCount = 0;
            var singleItem = null;
            if (sensorModel) {
                for (var s = 0; s < sensorModel.count; s++) {
                    if (sensorModel.get(s).active) {
                        activeCount++;
                        singleItem = sensorModel.get(s);
                    }
                }
            }

            for (var i = 0; i <= 5; i++) {
                var y = oy + (h / 5) * i;
                ctx.beginPath();
                ctx.moveTo(ox, y);
                ctx.lineTo(ox + w, y);
                ctx.stroke();

                ctx.fillStyle = "#94a3b8";
                ctx.font = "bold 11px sans-serif";

                var label = "";
                if (activeCount === 1 && singleItem) {
                    var rMin = singleItem.rangeMin;
                    var rMax = singleItem.rangeMax;
                    var v = rMax - (i / 5.0) * (rMax - rMin);
                    label = (v % 1 === 0 ? v.toFixed(0) : v.toFixed(1)) + " " + singleItem.unit;
                } else if (ui.yAxisTitle.indexOf("All Selected Channels (°C)") !== -1) {
                    label = String(100 - i * 20) + "°C";
                } else {
                    label = String(100 - i * 20) + "%";
                }
                ctx.fillText(label, 8, y + 4);
            }

            var visibleData = getVisibleDataSlice();
            if (visibleData.length < 2) return;
            var count = visibleData.length;

            var firstEpoch = visibleData[0].epoch;
            var lastEpoch = visibleData[count - 1].epoch;
            var spanEpoch = Math.max(1000, lastEpoch - firstEpoch);

            // Draw 5 Equidistant X-axis timestamps (Line 1: Time, Line 2: Date directly below)
            for (var k = 0; k <= 4; k++) {
                var labelEpoch = firstEpoch + (spanEpoch * (k / 4.0));
                var timeStr = trendsContainer.formatTimeOnly(labelEpoch);
                var dateStr = trendsContainer.formatDateOnly(labelEpoch);
                var pxTime = ox + (w * (k / 4.0));

                // Row 1: Time in bold
                ctx.fillStyle = "#94a3b8";
                ctx.font = "bold 10px sans-serif";
                ctx.fillText(timeStr, pxTime - 20, oy + h + 16);

                // Row 2: Date directly below
                ctx.fillStyle = "#475569";
                ctx.font = "9px sans-serif";
                ctx.fillText(dateStr, pxTime - 22, oy + h + 28);
            }

            // Save and Clip Canvas to Plot Area
            ctx.save();
            ctx.beginPath();
            ctx.rect(ox, oy, w, h);
            ctx.clip();

            // Generic Curve Drawing Function
            function drawDynamicCurve(field, color, minV, maxV) {
                ctx.strokeStyle = color;
                ctx.lineWidth = 2.4;
                ctx.beginPath();
                for (var j = 0; j < count; j++) {
                    var pt = visibleData[j];
                    var val = pt[field];
                    if (val === undefined) val = minV;
                    var normY = 1.0 - Math.max(0.0, Math.min(1.0, (val - minV) / (maxV - minV)));
                    var ratioX = Math.max(0.0, Math.min(1.0, (pt.epoch - firstEpoch) / spanEpoch));
                    var px = ox + ratioX * w;
                    var py = oy + normY * h;
                    if (j === 0) ctx.moveTo(px, py);
                    else ctx.lineTo(px, py);
                }
                ctx.stroke();
            }

            // Draw all active sensors
            if (sensorModel) {
                for (var c = 0; c < sensorModel.count; c++) {
                    var ch = sensorModel.get(c);
                    if (ch.active) {
                        drawDynamicCurve(ch.field, ch.color, ch.rangeMin, ch.rangeMax);
                    }
                }
            }

            ctx.restore();

            // Inspection Crosshair
            if (trendsContainer.inspectX >= ox && trendsContainer.inspectX <= ox + w) {
                ctx.strokeStyle = "#f59e0b";
                ctx.lineWidth = 1.6;
                ctx.setLineDash([4, 2]);
                ctx.beginPath();
                ctx.moveTo(trendsContainer.inspectX, oy);
                ctx.lineTo(trendsContainer.inspectX, oy + h);
                ctx.stroke();
                ctx.setLineDash([]);
            }
        });
    }

    // MouseArea on Canvas for Hover Inspection & Free-Size 2D Selection Box
    MouseArea {
        parent: ui.trendCanvasItem
        anchors.fill: parent
        hoverEnabled: true
        property real dragStartX: 0
        property real dragStartY: 0
        property bool isDragging: false

        onPositionChanged: function(mouse) {
            trendsContainer.inspectX = mouse.x;
            trendsContainer.inspectY = mouse.y;
            var w = parent.width - 90;
            var ox = 70;
            var oy = 15;
            var h = parent.height - 58;

            if (isDragging) {
                // Free-size 2D selection rectangle anywhere on canvas
                ui.dragBoxOverlay.visible = true;
                ui.dragBoxOverlay.x = Math.min(dragStartX, mouse.x);
                ui.dragBoxOverlay.y = Math.min(dragStartY, mouse.y);
                ui.dragBoxOverlay.width = Math.abs(mouse.x - dragStartX);
                ui.dragBoxOverlay.height = Math.abs(mouse.y - dragStartY);
                ui.inspectCardItem.visible = false;
            } else if (mouse.x >= ox && mouse.x <= ox + w) {
                var visibleData = getVisibleDataSlice();
                if (visibleData.length > 0) {
                    var ratio = (mouse.x - ox) / w;
                    var idx = Math.floor(visibleData.length * ratio);
                    idx = Math.max(0, Math.min(visibleData.length - 1, idx));
                    var pt = visibleData[idx];

                    if (pt) {
                        ui.inspectionTime = trendsContainer.formatFullDateTime(pt.epoch);
                        var sensorModel = ui.sensorListViewItem.model;
                        var inspectItems = [];

                        if (sensorModel) {
                            for (var s = 0; s < sensorModel.count; s++) {
                                var ch = sensorModel.get(s);
                                if (ch.active) {
                                    var valNum = pt[ch.field] !== undefined ? pt[ch.field] : 0.0;
                                    inspectItems.push({
                                        tag: ch.tag,
                                        val: (valNum % 1 === 0 ? valNum.toFixed(0) : valNum.toFixed(1)) + " " + ch.unit,
                                        color: ch.color
                                    });
                                }
                            }
                        }

                        // Populate dynamic inspection tooltip
                        ui.inspectRepeaterItem.clear();
                        for (var k = 0; k < inspectItems.length; k++) {
                            ui.inspectRepeaterItem.append(inspectItems[k]);
                        }

                        ui.inspectCardItem.visible = inspectItems.length > 0;
                        ui.inspectCardItem.height = Math.max(70, Math.min(220, 36 + inspectItems.length * 20));
                        ui.inspectCardItem.x = Math.min(parent.width - ui.inspectCardItem.width - 10, Math.max(ox, mouse.x + 12));
                        ui.inspectCardItem.y = Math.min(parent.height - ui.inspectCardItem.height - 10, Math.max(oy, mouse.y - 20));
                    }
                }
            } else {
                ui.inspectCardItem.visible = false;
            }
            ui.trendCanvasItem.requestPaint();
        }

        onExited: {
            trendsContainer.inspectX = -1;
            ui.inspectCardItem.visible = false;
            ui.trendCanvasItem.requestPaint();
        }

        onPressed: function(mouse) {
            dragStartX = mouse.x;
            dragStartY = mouse.y;
            isDragging = true;
        }

        onReleased: function(mouse) {
            if (isDragging) {
                isDragging = false;
                var minX = Math.min(dragStartX, mouse.x);
                var maxX = Math.max(dragStartX, mouse.x);
                var dragDist = maxX - minX;

                var w = parent.width - 90;
                var ox = 70;

                if (dragDist > 15 && maxX >= ox && minX <= ox + w) {
                    var rStart = Math.max(0.0, Math.min(1.0, (minX - ox) / w));
                    var rEnd = Math.max(0.0, Math.min(1.0, (maxX - ox) / w));
                    trendsContainer.zoomStartRatio = rStart;
                    trendsContainer.zoomEndRatio = rEnd;
                    trendsContainer.isZoomed = true;
                }
                ui.dragBoxOverlay.visible = false;
                ui.trendCanvasItem.requestPaint();
                refreshTableView();
            }
        }
    }
}
