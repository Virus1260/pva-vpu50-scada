import QtQuick
import "config"

Item {
    id: rootWindow
    width: 1280
    height: 720

    ScadaStateMiddleware { id: scadaMiddleware }

    // --- 21 CFR Part 11 User Authentication State ---
    property string activeUserId: "operator"
    property string activeUserName: "Line Operator"
    property string activeUserRole: "Operator (Level 1)"
    property int activeUserLevel: 1
    property int lastAuthorizedScreenIndex: 0

    // --- Industrial Process State Variables ---
    property bool isAutoMode: true
    property string currentRecipeName: "UNIMIX_BATCH_01"

    property double r1TargetSpeed: 25.0
    property double r1ActualSpeed: 0.0
    property double r1Power: 0.0
    property double r1Current: 0.0
    property int r1RuntimeSeconds: 0

    property double r2TargetSpeed: 600.0
    property double r2ActualSpeed: 0.0
    property double r2Power: 0.0
    property double r2Current: 0.0
    property int r2RuntimeSeconds: 0

    property string row3SelectedPreset: "discharge_circulation_pipe"
    property bool row3ValveConfirmed: false
    property int r3RuntimeSeconds: 0

    property double vacuumPressure: -209.8
    property double vacuumStartPressure: -400.0
    property double vacuumEndPressure: -450.0
    property int r4RuntimeSeconds: 0

    property string row5SelectedPreset: "suction_liquids"
    property bool row5ValveConfirmed: false
    property double suctionAngleOpen: 100.0
    property double suctionAngleClose: 100.0
    property double suctionTimeOpen: 0.0
    property double suctionTimeClose: 0.0
    property int r5RuntimeSeconds: 0

    property string activeConfirmTarget: ""

    property double productTemp: 40.1
    property double targetTemp: 89.0
    property double jacketDeltaT: 23.2
    property double tempDeviation: 48.9
    property double tempGradient: 12.1
    property int r6RuntimeSeconds: 0

    property var alarmList: [
        "SYSTEM READY - RECIPE [VPU_BATCH_01] STANDBY",
        "INFO: AGITATOR MOTOR [1M1501] READY FOR SEQUENCE",
        "NOTICE: VACUUM CHAMBER SEAL INTEGRITY VERIFIED",
        "STATUS: HEATING JACKET PROPORTIONAL REGULATION ACTIVE"
    ]
    property int alarmIndex: 0

    property var screenTitles: [
        "SYSTEM READY - CONTROL DASHBOARD",
        "P&ID VIEW - PVA SYSTEMS VPU-50 SKID & PROCESS VALVES",
        "PROCESS TRENDS - MULTI-CHANNEL HISTORICAL LOG",
        "ALARM ANNUNCIATOR - ACTIVE PROCESS NOTIFICATIONS",
        "RECIPES (RUN) - ISA-88 BATCH PROCESS EXECUTION MONITOR",
        "RECIPE MAKER - 21 CFR PART 11 MASTER RECIPE AUTHORING",
        "ELECTRONIC BATCH RECORD - 21 CFR PART 11 AUDIT LOG",
        "MAINTENANCE - HARDWARE I/O DIAGNOSTICS & OVERRIDE"
    ]

    function formatTime(totalSecs) {
        var hrs = Math.floor(totalSecs / 3600);
        var mins = Math.floor((totalSecs % 3600) / 60);
        var secs = totalSecs % 60;
        return String(hrs).padStart(2, '0') + ":" + String(mins).padStart(2, '0') + ":" + String(secs).padStart(2, '0');
    }

    // --- Direct UI Presentation Component ---
    Main_frame_screenView {
        id: ui
        anchors.fill: parent
    }

    // Bind sidebar role & level dynamically
    Binding {
        target: ui.sidebar
        property: "userRole"
        value: rootWindow.activeUserId
    }
    Binding {
        target: ui.sidebar
        property: "userLevel"
        value: rootWindow.activeUserLevel
    }

    // Bind Recipe Maker Screen author & role dynamically
    Binding {
        target: ui.recipeMakerScreen
        property: "activeUserName"
        value: rootWindow.activeUserName
    }
    Binding {
        target: ui.recipeMakerScreen
        property: "activeUserRole"
        value: rootWindow.activeUserRole
    }
    Binding {
        target: ui.recipeMakerScreen
        property: "activeUserLevel"
        value: rootWindow.activeUserLevel
    }

    // Bind Screen 1 Control Screen run-mode decoupling / recipe lockout
    Binding {
        target: ui.controlView
        property: "isLocked"
        value: typeof Scada !== "undefined" && Scada.recipeRunning
    }
    Binding {
        target: ui.controlView
        property: "lockoutBatchId"
        value: typeof Scada !== "undefined" ? Scada.activeBatchId : ""
    }
    Binding {
        target: ui.controlView
        property: "lockoutRecipeName"
        value: typeof Scada !== "undefined" ? Scada.activeRecipeName : ""
    }
    Binding {
        target: ui.controlView
        property: "lockoutStep"
        value: typeof Scada !== "undefined" ? Scada.currentStepIndex : 0
    }
    Binding {
        target: ui.controlView
        property: "lockoutTotalSteps"
        value: typeof Scada !== "undefined" ? Scada.totalSteps : 0
    }

    // --- Component Setup & Static Wiring ---
    Component.onCompleted: {
        var ctrl = ui.controlView;
        if (!ctrl) return;

        // --- RUN-MODE DECOUPLING & SAFETY INTERLOCK HELPERS ---
        function checkRecipeLockout() {
            if (typeof Scada !== "undefined" && Scada.recipeRunning) {
                if (ui.header) {
                    ui.header.alarmMessage = "SAFETY INTERLOCK: Automatic recipe active - manual controls locked out.";
                    ui.header.isAlarmActive = true;
                }
                return true;
            }
            return false;
        }

        function checkProcessRunning(equipmentName, isRunning) {
            if (checkRecipeLockout()) return true;
            if (isRunning) {
                if (ui.header) {
                    ui.header.alarmMessage = "SAFETY INTERLOCK: Stop " + equipmentName + " before modifying mode or setpoint parameters.";
                    ui.header.isAlarmActive = true;
                }
                return true;
            }
            return false;
        }

        // -------------------------------------------------------------
        // 1. ROW 1: AGITATOR SPEED & INTERACTIVE CONTROLS
        // -------------------------------------------------------------
        if (ctrl.row1MinusBtn) {
            ctrl.row1MinusBtn.clicked.connect(function() {
                if (checkProcessRunning("Agitator", ctrl.row1Media && ctrl.row1Media.isPlaying)) return;
                rootWindow.r1TargetSpeed = Math.max(25.0, rootWindow.r1TargetSpeed - 5.0);
                ctrl.row1SpeedControl.targetVal = rootWindow.r1TargetSpeed;
            });
        }

        if (ctrl.row1PlusBtn) {
            ctrl.row1PlusBtn.clicked.connect(function() {
                if (checkProcessRunning("Agitator", ctrl.row1Media && ctrl.row1Media.isPlaying)) return;
                rootWindow.r1TargetSpeed = Math.min(120.0, rootWindow.r1TargetSpeed + 5.0);
                ctrl.row1SpeedControl.targetVal = rootWindow.r1TargetSpeed;
            });
        }

        if (ctrl.row1SpeedControl) {
            ctrl.row1SpeedControl.targetValChangedByUser.connect(function(newVal) {
                if (checkProcessRunning("Agitator", ctrl.row1Media && ctrl.row1Media.isPlaying)) return;
                rootWindow.r1TargetSpeed = newVal;
            });

            ctrl.row1SpeedControl.setpointRequested.connect(function(title, tag, current, min, max, unit) {
                if (checkProcessRunning("Agitator", ctrl.row1Media && ctrl.row1Media.isPlaying)) return;
                if (ui.keypadModal) {
                    ui.keypadModal.title = title;
                    ui.keypadModal.targetTag = tag;
                    ui.keypadModal.minVal = min;
                    ui.keypadModal.maxVal = max;
                    ui.keypadModal.unit = unit;
                    ui.keypadModal.currentInput = current.toFixed(1);
                    ui.keypadModal.visible = true;
                }
            });
        }

        if (ctrl.row1Media) {
            ctrl.row1Media.playClicked.connect(function() {
                rootWindow.r1Power = 3.8;
                rootWindow.r1Current = 11.5;
                if (ctrl.row1SpeedControl) ctrl.row1SpeedControl.isLocked = true;
                if (ctrl.row1PowerCard) {
                    ctrl.row1PowerCard.powerVal = rootWindow.r1Power.toFixed(1);
                    ctrl.row1PowerCard.currentVal = rootWindow.r1Current.toFixed(1);
                }
            });

            ctrl.row1Media.stopClicked.connect(function() {
                rootWindow.r1Power = 0.0;
                rootWindow.r1Current = 0.0;
                rootWindow.r1RuntimeSeconds = 0;
                if (ctrl.row1SpeedControl) ctrl.row1SpeedControl.isLocked = false;
                if (ctrl.row1Runtime) ctrl.row1Runtime.timeText = "00:00:00";
                if (ctrl.row1PowerCard) {
                    ctrl.row1PowerCard.powerVal = "0.0";
                    ctrl.row1PowerCard.currentVal = "0.0";
                }
            });
        }

        if (ctrl.row1ModeSelector) {
            ctrl.row1ModeSelector.clicked.connect(function() {
                if (checkProcessRunning("Agitator", ctrl.row1Media && ctrl.row1Media.isPlaying)) return;
                if (ui.agitatorModal) {
                    ui.agitatorModal.currentMode = ctrl.row1ModeSelector.iconName || "agitator_cw";
                    ui.agitatorModal.visible = true;
                }
            });
        }

        // -------------------------------------------------------------
        // 2. ROW 2: HOMOGENIZER SPEED & INTERACTIVE CONTROLS
        // -------------------------------------------------------------
        if (ctrl.row2MinusBtn) {
            ctrl.row2MinusBtn.clicked.connect(function() {
                if (checkProcessRunning("Homogenizer", ctrl.row2Media && ctrl.row2Media.isPlaying)) return;
                rootWindow.r2TargetSpeed = Math.max(600.0, rootWindow.r2TargetSpeed - 100.0);
                ctrl.row2SpeedControl.targetVal = rootWindow.r2TargetSpeed;
            });
        }

        if (ctrl.row2PlusBtn) {
            ctrl.row2PlusBtn.clicked.connect(function() {
                if (checkProcessRunning("Homogenizer", ctrl.row2Media && ctrl.row2Media.isPlaying)) return;
                rootWindow.r2TargetSpeed = Math.min(4800.0, rootWindow.r2TargetSpeed + 100.0);
                ctrl.row2SpeedControl.targetVal = rootWindow.r2TargetSpeed;
            });
        }

        if (ctrl.row2SpeedControl) {
            ctrl.row2SpeedControl.targetValChangedByUser.connect(function(newVal) {
                if (checkProcessRunning("Homogenizer", ctrl.row2Media && ctrl.row2Media.isPlaying)) return;
                rootWindow.r2TargetSpeed = newVal;
            });

            ctrl.row2SpeedControl.setpointRequested.connect(function(title, tag, current, min, max, unit) {
                if (checkProcessRunning("Homogenizer", ctrl.row2Media && ctrl.row2Media.isPlaying)) return;
                if (ui.keypadModal) {
                    ui.keypadModal.title = title;
                    ui.keypadModal.targetTag = tag;
                    ui.keypadModal.minVal = min;
                    ui.keypadModal.maxVal = max;
                    ui.keypadModal.unit = unit;
                    ui.keypadModal.currentInput = current.toFixed(0);
                    ui.keypadModal.visible = true;
                }
            });
        }

        if (ctrl.row2Media) {
            ctrl.row2Media.playClicked.connect(function() {
                rootWindow.r2Power = 8.5;
                rootWindow.r2Current = 24.2;
                if (ctrl.row2SpeedControl) ctrl.row2SpeedControl.isLocked = true;
                if (ctrl.row2PowerCard) {
                    ctrl.row2PowerCard.powerVal = rootWindow.r2Power.toFixed(1);
                    ctrl.row2PowerCard.currentVal = rootWindow.r2Current.toFixed(1);
                }
            });

            ctrl.row2Media.stopClicked.connect(function() {
                rootWindow.r2Power = 0.0;
                rootWindow.r2Current = 0.0;
                rootWindow.r2RuntimeSeconds = 0;
                if (ctrl.row2SpeedControl) ctrl.row2SpeedControl.isLocked = false;
                if (ctrl.row2Runtime) ctrl.row2Runtime.timeText = "00:00:00";
                if (ctrl.row2PowerCard) {
                    ctrl.row2PowerCard.powerVal = "0.0";
                    ctrl.row2PowerCard.currentVal = "0.0";
                }
            });
        }

        if (ctrl.row2ModeSelector) {
            ctrl.row2ModeSelector.clicked.connect(function() {
                if (checkProcessRunning("Homogenizer", ctrl.row2Media && ctrl.row2Media.isPlaying)) return;
                if (ui.homoModal) {
                    ui.homoModal.currentMode = ctrl.row2ModeSelector.iconName || "homo_permanent";
                    ui.homoModal.visible = true;
                }
            });
        }

        // -------------------------------------------------------------
        // 3. ROW 3: CIRCULATION CONTROLS & VALVE SAFETY CONFIRMATION ON PLAY
        // -------------------------------------------------------------
        if (ctrl.row3Media) {
            ctrl.row3Media.playClicked.connect(function() {
                if (!rootWindow.row3ValveConfirmed) {
                    // Stop automatic start until manual valves are verified
                    ctrl.row3Media.isPlaying = false;
                    rootWindow.activeConfirmTarget = "row3";
                    if (ui.confirmModal) {
                        ui.confirmModal.loadPreset(rootWindow.row3SelectedPreset);
                    }
                } else {
                    if (ui.header) {
                        ui.header.alarmMessage = "CIRCULATION SEQUENCE RUNNING - 1M2001 ACTIVE";
                    }
                }
            });

            ctrl.row3Media.stopClicked.connect(function() {
                rootWindow.r3RuntimeSeconds = 0;
                rootWindow.row3ValveConfirmed = false;
                if (ctrl.row3Runtime) ctrl.row3Runtime.timeText = "00:00:00";
            });
        }

        if (ctrl.row3ModeSelector) {
            ctrl.row3ModeSelector.clicked.connect(function() {
                if (checkProcessRunning("External Line", ctrl.row3Media && ctrl.row3Media.isPlaying)) return;
                if (ui.extLineModal) ui.extLineModal.visible = true;
            });
        }

        // -------------------------------------------------------------
        // 4. ROW 4: VACUUM CONTROLS & SETPOINTS
        // -------------------------------------------------------------
        if (ctrl.row4Media) {
            ctrl.row4Media.stopClicked.connect(function() {
                rootWindow.r4RuntimeSeconds = 0;
                if (ctrl.row4Runtime) ctrl.row4Runtime.timeText = "00:00:00";
            });
        }

        if (ctrl.row4ModeSelector) {
            ctrl.row4ModeSelector.clicked.connect(function() {
                if (checkProcessRunning("Vacuum", ctrl.row4Media && ctrl.row4Media.isPlaying)) return;
                if (ui.vacuumModal) ui.vacuumModal.visible = true;
            });
        }

        if (ctrl.row4StartCard) {
            ctrl.row4StartCard.clicked.connect(function() {
                if (checkProcessRunning("Vacuum", ctrl.row4Media && ctrl.row4Media.isPlaying)) return;
                if (ui.keypadModal) {
                    ui.keypadModal.title = "Start Pressure";
                    ui.keypadModal.targetTag = "1P1001_START";
                    ui.keypadModal.minVal = -1000.0;
                    ui.keypadModal.maxVal = 0.0;
                    ui.keypadModal.unit = "mbar";
                    ui.keypadModal.currentInput = rootWindow.vacuumStartPressure.toFixed(1);
                    ui.keypadModal.visible = true;
                }
            });
        }

        if (ctrl.row4EndCard) {
            ctrl.row4EndCard.clicked.connect(function() {
                if (checkProcessRunning("Vacuum", ctrl.row4Media && ctrl.row4Media.isPlaying)) return;
                if (ui.keypadModal) {
                    ui.keypadModal.title = "End Pressure";
                    ui.keypadModal.targetTag = "1P1001_END";
                    ui.keypadModal.minVal = -1000.0;
                    ui.keypadModal.maxVal = 0.0;
                    ui.keypadModal.unit = "mbar";
                    ui.keypadModal.currentInput = rootWindow.vacuumEndPressure.toFixed(1);
                    ui.keypadModal.visible = true;
                }
            });
        }

        // -------------------------------------------------------------
        // 5. ROW 5: SUCTION LIQUIDS CONTROLS & VALVE SAFETY CONFIRMATION ON PLAY
        // -------------------------------------------------------------
        if (ctrl.row5Media) {
            ctrl.row5Media.playClicked.connect(function() {
                if (!rootWindow.row5ValveConfirmed) {
                    // Stop automatic start until manual valves are verified
                    ctrl.row5Media.isPlaying = false;
                    rootWindow.activeConfirmTarget = "row5";
                    if (ui.confirmModal) {
                        ui.confirmModal.loadPreset(rootWindow.row5SelectedPreset);
                    }
                } else {
                    if (ui.header) {
                        ui.header.alarmMessage = "SUCTION PORT CHARGING ACTIVE - 1V1001 REGULATING";
                    }
                }
            });

            ctrl.row5Media.stopClicked.connect(function() {
                rootWindow.r5RuntimeSeconds = 0;
                rootWindow.row5ValveConfirmed = false;
                if (ctrl.row5Runtime) ctrl.row5Runtime.timeText = "00:00:00";
            });
        }

        if (ctrl.row5ModeSelector) {
            ctrl.row5ModeSelector.clicked.connect(function() {
                if (checkProcessRunning("Suction", ctrl.row5Media && ctrl.row5Media.isPlaying)) return;
                if (ui.fillingModal) ui.fillingModal.visible = true;
            });
        }

        if (ctrl.row5AngleOpenCard) {
            ctrl.row5AngleOpenCard.setpointClicked.connect(function() {
                if (checkProcessRunning("Suction", ctrl.row5Media && ctrl.row5Media.isPlaying)) return;
                if (ui.keypadModal) {
                    ui.keypadModal.title = "Angle Open";
                    ui.keypadModal.targetTag = "1V1001_AO";
                    ui.keypadModal.minVal = 0.0;
                    ui.keypadModal.maxVal = 100.0;
                    ui.keypadModal.unit = "%";
                    ui.keypadModal.currentInput = rootWindow.suctionAngleOpen.toFixed(1);
                    ui.keypadModal.visible = true;
                }
            });
        }

        if (ctrl.row5AngleCloseCard) {
            ctrl.row5AngleCloseCard.setpointClicked.connect(function() {
                if (checkProcessRunning("Suction", ctrl.row5Media && ctrl.row5Media.isPlaying)) return;
                if (ui.keypadModal) {
                    ui.keypadModal.title = "Angle Closed";
                    ui.keypadModal.targetTag = "1V1001_AC";
                    ui.keypadModal.minVal = 0.0;
                    ui.keypadModal.maxVal = 100.0;
                    ui.keypadModal.unit = "%";
                    ui.keypadModal.currentInput = rootWindow.suctionAngleClose.toFixed(1);
                    ui.keypadModal.visible = true;
                }
            });
        }

        if (ctrl.row5TimeOpenCard) {
            ctrl.row5TimeOpenCard.setpointClicked.connect(function() {
                if (checkProcessRunning("Suction", ctrl.row5Media && ctrl.row5Media.isPlaying)) return;
                if (ui.keypadModal) {
                    ui.keypadModal.title = "Time Open";
                    ui.keypadModal.targetTag = "1V1001_TO";
                    ui.keypadModal.minVal = 0.0;
                    ui.keypadModal.maxVal = 999.0;
                    ui.keypadModal.unit = "s";
                    ui.keypadModal.currentInput = rootWindow.suctionTimeOpen.toFixed(1);
                    ui.keypadModal.visible = true;
                }
            });
        }

        if (ctrl.row5TimeCloseCard) {
            ctrl.row5TimeCloseCard.setpointClicked.connect(function() {
                if (checkProcessRunning("Suction", ctrl.row5Media && ctrl.row5Media.isPlaying)) return;
                if (ui.keypadModal) {
                    ui.keypadModal.title = "Time Closed";
                    ui.keypadModal.targetTag = "1V1001_TC";
                    ui.keypadModal.minVal = 0.0;
                    ui.keypadModal.maxVal = 999.0;
                    ui.keypadModal.unit = "s";
                    ui.keypadModal.currentInput = rootWindow.suctionTimeClose.toFixed(1);
                    ui.keypadModal.visible = true;
                }
            });
        }

        // -------------------------------------------------------------
        // 6. ROW 6: HEATING CONTROLS & SETPOINTS
        // -------------------------------------------------------------
        if (ctrl.row6Media) {
            ctrl.row6Media.stopClicked.connect(function() {
                rootWindow.r6RuntimeSeconds = 0;
                if (ctrl.row6Runtime) ctrl.row6Runtime.timeText = "00:00:00";
            });
        }

        if (ctrl.row6ModeSelector) {
            ctrl.row6ModeSelector.clicked.connect(function() {
                if (checkProcessRunning("Temperature Regulation", ctrl.row6Media && ctrl.row6Media.isPlaying)) return;
                if (ui.heatingModal) {
                    ui.heatingModal.targetSelector = "mode";
                    ui.heatingModal.selectedValue = ctrl.row6ModeSelector.modeText || "Heating";
                    ui.heatingModal.visible = true;
                }
            });
        }

        if (ctrl.row6RegSelector) {
            ctrl.row6RegSelector.clicked.connect(function() {
                if (checkProcessRunning("Temperature Regulation", ctrl.row6Media && ctrl.row6Media.isPlaying)) return;
                if (ui.heatingModal) {
                    ui.heatingModal.targetSelector = "regulation";
                    ui.heatingModal.selectedValue = ctrl.row6RegSelector.modeText || "Product";
                    ui.heatingModal.visible = true;
                }
            });
        }

        if (ctrl.row6TempSrcSelector) {
            ctrl.row6TempSrcSelector.clicked.connect(function() {
                if (checkProcessRunning("Temperature Regulation", ctrl.row6Media && ctrl.row6Media.isPlaying)) return;
                if (ui.heatingModal) {
                    ui.heatingModal.targetSelector = "temp_src";
                    ui.heatingModal.selectedValue = ctrl.row6TempSrcSelector.modeText || "Baffle";
                    ui.heatingModal.visible = true;
                }
            });
        }

        if (ctrl.row6DeltaTCard) {
            ctrl.row6DeltaTCard.setpointClicked.connect(function() {
                if (checkProcessRunning("Temperature Regulation", ctrl.row6Media && ctrl.row6Media.isPlaying)) return;
                if (ui.keypadModal) {
                    ui.keypadModal.title = "Delta T Jacket";
                    ui.keypadModal.targetTag = "1T1001_DT";
                    ui.keypadModal.minVal = 0.0;
                    ui.keypadModal.maxVal = 50.0;
                    ui.keypadModal.unit = "°C";
                    ui.keypadModal.currentInput = rootWindow.jacketDeltaT.toFixed(1);
                    ui.keypadModal.visible = true;
                }
            });
        }

        if (ctrl.row6TempCard) {
            ctrl.row6TempCard.setpointClicked.connect(function() {
                if (checkProcessRunning("Temperature Regulation", ctrl.row6Media && ctrl.row6Media.isPlaying)) return;
                if (ui.keypadModal) {
                    ui.keypadModal.title = "Temperature Setpoint";
                    ui.keypadModal.targetTag = "1T1001_TEMP";
                    ui.keypadModal.minVal = 20.0;
                    ui.keypadModal.maxVal = 130.0;
                    ui.keypadModal.unit = "°C";
                    ui.keypadModal.currentInput = rootWindow.targetTemp.toFixed(1);
                    ui.keypadModal.visible = true;
                }
            });
        }

        if (ctrl.row6DevCard) {
            ctrl.row6DevCard.setpointClicked.connect(function() {
                if (checkProcessRunning("Temperature Regulation", ctrl.row6Media && ctrl.row6Media.isPlaying)) return;
                if (ui.keypadModal) {
                    ui.keypadModal.title = "Temperature Deviation";
                    ui.keypadModal.targetTag = "1T1001_DEV";
                    ui.keypadModal.minVal = 0.1;
                    ui.keypadModal.maxVal = 10.0;
                    ui.keypadModal.unit = "°C";
                    ui.keypadModal.currentInput = rootWindow.tempDeviation.toFixed(1);
                    ui.keypadModal.visible = true;
                }
            });
        }

        // -------------------------------------------------------------
        // 7. HEADER & ALARMS SYNCHRONIZATION ENGINE
        // -------------------------------------------------------------
        var isUpdatingAlarms = false;
        function updateAlarmAnnunciator() {
            if (isUpdatingAlarms) return;
            isUpdatingAlarms = true;

            var alarmsScr = ui.alarmsScreen;
            if (alarmsScr) {
                var unack = alarmsScr.syncUnackCount();
                if (ui.sidebar) {
                    ui.sidebar.unackAlarmsCount = unack;
                }

                if (unack > 0) {
                    var latest = alarmsScr.getLatestUnacknowledgedAlarm();
                    if (latest) {
                        ui.header.isAlarmActive = true;
                        ui.header.alarmMessage = "[" + latest.severity + "] " + latest.tag + ": " + latest.title + " (" + latest.value + ") - ACTION: " + latest.resp;
                    }
                } else {
                    ui.header.isAlarmActive = false;
                    ui.header.alarmMessage = "SYSTEM NORMAL - ALL PROCESS ALARMS ACKNOWLEDGED";
                }
            }

            isUpdatingAlarms = false;
        }

        if (ui.alarmsScreen) {
            ui.alarmsScreen.alarmsSynchronized.connect(function(count) {
                updateAlarmAnnunciator();
            });
            ui.alarmsScreen.alarmAcknowledged.connect(function(tag, title) {
                updateAlarmAnnunciator();
            });
        }

        if (ui.ackButton) {
            ui.ackButton.clicked.connect(function() {
                if (ui.alarmsScreen) {
                    var acked = ui.alarmsScreen.acknowledgeLatestAlarm(rootWindow.activeUserName);
                    if (acked) {
                        updateAlarmAnnunciator();
                    } else {
                        ui.header.isAlarmActive = false;
                        ui.header.alarmMessage = "SYSTEM NORMAL - ALL PROCESS ALARMS ACKNOWLEDGED";
                    }
                }
            });
        }

        // Initialize header alarm state and bind alarmsScreen operator context
        updateAlarmAnnunciator();
        if (ui.alarmsScreen) {
            ui.alarmsScreen.operatorName = Qt.binding(function() { return rootWindow.activeUserName; });
            ui.alarmsScreen.operatorRole = Qt.binding(function() { return rootWindow.activeUserRole; });
            ui.alarmsScreen.operatorId = Qt.binding(function() { return rootWindow.activeUserId; });
        }

        if (ui.header) {
            ui.header.plantModeRequested.connect(function() {
                if (ui.plantModal) {
                    ui.plantModal.isAuto = rootWindow.isAutoMode;
                    ui.plantModal.visible = true;
                }
            });

            ui.header.userLoginRequested.connect(function() {
                if (ui.loginModal) {
                    ui.loginModal.currentUserId = rootWindow.activeUserId;
                    ui.loginModal.currentUserName = rootWindow.activeUserName;
                    ui.loginModal.currentUserRole = rootWindow.activeUserRole;
                    ui.loginModal.currentUserLevel = rootWindow.activeUserLevel;
                    ui.loginModal.targetUserId = rootWindow.activeUserId === "operator" ? "admin" : "operator";
                    ui.loginModal.enteredPin = "";
                    ui.loginModal.errorMessage = "";
                    ui.loginModal.visible = true;
                }
            });
        }

        // -------------------------------------------------------------
        // 7B. LOGIN & ROLE-BASED ACCESS CONTROL (RBAC) WIRING
        // -------------------------------------------------------------
        if (ui.loginModal) {
            ui.loginModal.loginSuccess.connect(function(uId, uName, uRole, uLevel) {
                rootWindow.activeUserId = uId;
                rootWindow.activeUserName = uName;
                rootWindow.activeUserRole = uRole;
                rootWindow.activeUserLevel = uLevel;
                if (ui.header) {
                    ui.header.operatorName = uName;
                    ui.header.operatorRole = uRole;
                    ui.header.alarmMessage = "USER AUTHENTICATED: [" + uName + "] ACCESS GRANTED (" + uRole + ")";
                }
                if (ui.sidebar && ui.sidebar.activeIndex === 7 && uLevel >= 4) {
                    rootWindow.lastAuthorizedScreenIndex = 7;
                }
            });

            ui.loginModal.userLoggedOut.connect(function() {
                var defUser = scadaMiddleware.config.getUser("operator");
                rootWindow.activeUserId = defUser.id;
                rootWindow.activeUserName = defUser.name;
                rootWindow.activeUserRole = defUser.role;
                rootWindow.activeUserLevel = defUser.level;
                if (ui.header) {
                    ui.header.operatorName = defUser.name;
                    ui.header.operatorRole = defUser.role;
                    ui.header.alarmMessage = "USER LOGGED OUT - REVERTED TO " + defUser.name.toUpperCase() + " (" + defUser.role.toUpperCase() + ")";
                }
                // If on restricted screen, revert immediately
                if (ui.sidebar && ui.sidebar.activeIndex === 7) {
                    ui.sidebar.activeIndex = 0;
                    rootWindow.lastAuthorizedScreenIndex = 0;
                }
            });

            ui.loginModal.closed.connect(function() {
                ui.loginModal.visible = false;
                // Strict Non-Bypass: If user was trying to access Screen 7 (Diagnostics) without Level 4+ authorization, revert back!
                if (ui.sidebar && ui.sidebar.activeIndex === 7 && rootWindow.activeUserLevel < 4) {
                    ui.sidebar.activeIndex = rootWindow.lastAuthorizedScreenIndex;
                    if (ui.header) ui.header.alarmMessage = "ACCESS DENIED: Maintenance / Diagnostics requires Level 4+ authorization.";
                }
            });
        }

        // -------------------------------------------------------------
        // 8. SIDEBAR SCREEN NAVIGATION HANDLER WITH RBAC ENFORCEMENT
        // -------------------------------------------------------------
        if (ui.sidebar) {
            ui.sidebar.activeIndexChanged.connect(function() {
                var idx = ui.sidebar.activeIndex;
                if (idx === 7 && rootWindow.activeUserLevel < 4) {
                    // Screen 7: Diagnostics & Hardware Overrides requires Maintenance (Level 4+) or Admin (Level 5)
                    if (ui.header) ui.header.alarmMessage = "ACCESS RESTRICTED: Maintenance / Diagnostics requires Level 4+ authorization.";
                    if (ui.loginModal) {
                        ui.loginModal.targetUserId = "engineer";
                        ui.loginModal.errorMessage = "Please login with Maintenance (Level 4) or Admin (Level 5) credentials.";
                        ui.loginModal.visible = true;
                    }
                } else if (idx === 5 && rootWindow.activeUserLevel < 3) {
                    // Screen 5: 21 CFR Part 11 Electronic Batch Record Review
                    rootWindow.lastAuthorizedScreenIndex = idx;
                    if (ui.header && !ui.header.isAlarmActive) ui.header.alarmMessage = "VIEWING 21 CFR BATCH RECORD (Sign-off requires QA Officer Level 3+)";
                } else {
                    rootWindow.lastAuthorizedScreenIndex = idx;
                    // Maintain true alarm annunciator state (active process alarm or soothing normal)
                    updateAlarmAnnunciator();
                }
            });
        }

        // -------------------------------------------------------------
        // 9. P&ID COMPONENT TAPPING HANDLER
        // -------------------------------------------------------------
        if (ui.pidScreen) {
            ui.pidScreen.componentTapped.connect(function(tagName) {
                if (ui.confirmModal) {
                    ui.confirmModal.title = "Confirm Device Action: " + tagName;
                    ui.confirmModal.instruction = "Please verify safety interlocks before toggling position of " + tagName + ".";
                    ui.confirmModal.visible = true;
                }
            });
        }

        // -------------------------------------------------------------
        // 10. MODAL SETPOINT ACCEPTANCE HANDLER (Universal Dispatcher)
        // -------------------------------------------------------------
        if (ui.keypadModal) {
            ui.keypadModal.accepted.connect(function(val) {
                var tag = ui.keypadModal.targetTag;
                if (tag.indexOf("1M1501") !== -1 && ctrl.row1SpeedControl) {
                    rootWindow.r1TargetSpeed = val;
                    ctrl.row1SpeedControl.targetVal = val;
                } else if (tag.indexOf("1M2003") !== -1 && ctrl.row2SpeedControl) {
                    rootWindow.r2TargetSpeed = val;
                    ctrl.row2SpeedControl.targetVal = val;
                } else if (tag.indexOf("1P1001_START") !== -1 && ctrl.row4StartCard) {
                    rootWindow.vacuumStartPressure = val;
                    ctrl.row4StartCard.primaryValue = val.toFixed(1);
                } else if (tag.indexOf("1P1001_END") !== -1 && ctrl.row4EndCard) {
                    rootWindow.vacuumEndPressure = val;
                    ctrl.row4EndCard.primaryValue = val.toFixed(1);
                } else if (tag.indexOf("1V1001_AO") !== -1 && ctrl.row5AngleOpenCard) {
                    rootWindow.suctionAngleOpen = val;
                    ctrl.row5AngleOpenCard.secondaryValue = val.toFixed(1) + "%";
                } else if (tag.indexOf("1V1001_AC") !== -1 && ctrl.row5AngleCloseCard) {
                    rootWindow.suctionAngleClose = val;
                    ctrl.row5AngleCloseCard.secondaryValue = val.toFixed(1) + "%";
                } else if (tag.indexOf("1V1001_TO") !== -1 && ctrl.row5TimeOpenCard) {
                    rootWindow.suctionTimeOpen = val;
                    ctrl.row5TimeOpenCard.secondaryValue = val.toFixed(1) + " s";
                } else if (tag.indexOf("1V1001_TC") !== -1 && ctrl.row5TimeCloseCard) {
                    rootWindow.suctionTimeClose = val;
                    ctrl.row5TimeCloseCard.secondaryValue = val.toFixed(1) + " s";
                } else if (tag.indexOf("1T1001_DT") !== -1 && ctrl.row6DeltaTCard) {
                    rootWindow.jacketDeltaT = val;
                    ctrl.row6DeltaTCard.secondaryValue = val.toFixed(1) + " °C";
                } else if (tag.indexOf("1T1001_TEMP") !== -1 && ctrl.row6TempCard) {
                    rootWindow.targetTemp = val;
                    ctrl.row6TempCard.secondaryValue = val.toFixed(1) + " °C";
                } else if (tag.indexOf("1T1001_DEV") !== -1 && ctrl.row6DevCard) {
                    rootWindow.tempDeviation = val;
                    ctrl.row6DevCard.secondaryValue = val.toFixed(1) + " °C";
                }
                ui.keypadModal.visible = false;
            });

            ui.keypadModal.closed.connect(function() { ui.keypadModal.visible = false; });
        }

        // -------------------------------------------------------------
        // 11. PLANTMODE MODAL WIRING
        // -------------------------------------------------------------
        if (ui.plantModal) {
            ui.plantModal.autoToggled.connect(function(isAuto) {
                rootWindow.isAutoMode = isAuto;
                if (ui.header) {
                    ui.header.plantModeText = isAuto ? "(A)" : "(M)";
                    ui.header.alarmMessage = isAuto ? "AUTOMATIC PRODUCTION MODE - RECIPE [" + rootWindow.currentRecipeName + "] ACTIVE" : "MANUAL OVERRIDE MODE - OPERATOR SETPOINTS ENABLED";
                }
            });

            ui.plantModal.modeSelected.connect(function(mode) {
                if (mode === "RECIPE" && ui.sidebar) {
                    ui.sidebar.activeIndex = 4; // Switch to Recipes Screen
                } else if (mode === "CIP" && ui.header) {
                    ui.header.alarmMessage = "CIP MODE - CLEANING IN PLACE SEQUENCE ACTIVE";
                } else if (mode === "PRODUCTION" && ui.header) {
                    ui.header.alarmMessage = "PRODUCTION MODE - VESSEL READY";
                }
            });

            ui.plantModal.closed.connect(function() { ui.plantModal.visible = false; });
        }

        // -------------------------------------------------------------
        // 12. DYNAMIC MODE MODALS
        // -------------------------------------------------------------
        // Agitator Modal
        if (ui.agitatorModal) {
            ui.agitatorModal.modeSelected.connect(function(modeKey) {
                if (ctrl.row1ModeSelector) ctrl.row1ModeSelector.iconName = modeKey;
                scadaMiddleware.agitatorMode = modeKey;
                if (ui.pidScreen && ui.pidScreen.scadaBridge) {
                    ui.pidScreen.scadaBridge.agitatorMode = modeKey;
                }
            });
            ui.agitatorModal.closed.connect(function() { ui.agitatorModal.visible = false; });
        }

        // Homogenizer Modal
        if (ui.homoModal) {
            ui.homoModal.modeSelected.connect(function(modeKey) {
                if (ctrl.row2ModeSelector) ctrl.row2ModeSelector.iconName = modeKey;
            });
            ui.homoModal.closed.connect(function() { ui.homoModal.visible = false; });
        }

        // External Line Modal (Row 3) - Applies configuration quietly without popping confirmation
        if (ui.extLineModal) {
            ui.extLineModal.modeApplied.connect(function(modeKey, modeTitle) {
                ui.extLineModal.visible = false;
                rootWindow.row3SelectedPreset = modeKey;
                rootWindow.row3ValveConfirmed = false;
                if (ctrl.row3ModeSelector) {
                    ctrl.row3ModeSelector.iconName = modeKey;
                }
                if (ui.header) {
                    ui.header.alarmMessage = "EXTERNAL LINE CONFIGURED: [" + modeTitle.toUpperCase() + "] - PRESS START TO CONFIRM VALVES";
                }
            });
            ui.extLineModal.closed.connect(function() { ui.extLineModal.visible = false; });
        }

        // Vacuum Modal (Row 4)
        if (ui.vacuumModal) {
            ui.vacuumModal.modeApplied.connect(function(modeKey, modeTitle, preset) {
                if (ctrl.row4ModeSelector) {
                    ctrl.row4ModeSelector.iconName = modeKey;
                    ctrl.row4ModeSelector.modeText = modeTitle;
                }
                if (ctrl.row4StartCard) ctrl.row4StartCard.primaryValue = preset.toFixed(1);
            });
            ui.vacuumModal.closed.connect(function() { ui.vacuumModal.visible = false; });
        }

        // Filling / Suction Modal (Row 5) - Applies configuration quietly without popping confirmation
        if (ui.fillingModal) {
            ui.fillingModal.modeApplied.connect(function(modeKey, modeTitle) {
                ui.fillingModal.visible = false;
                rootWindow.row5SelectedPreset = modeKey;
                rootWindow.row5ValveConfirmed = false;
                if (ctrl.row5ModeSelector) {
                    ctrl.row5ModeSelector.iconName = modeKey;
                }
                if (ui.header) {
                    ui.header.alarmMessage = "SUCTION PORT CONFIGURED: [" + modeTitle.toUpperCase() + "] - PRESS START TO CONFIRM VALVES";
                }
            });
            ui.fillingModal.closed.connect(function() { ui.fillingModal.visible = false; });
        }

        // Valve Status Matrix & Safety Interlock Modal (Triggers when Start is pressed)
        if (ui.confirmModal) {
            ui.confirmModal.confirmed.connect(function(opKey) {
                if (rootWindow.activeConfirmTarget === "row3") {
                    rootWindow.row3ValveConfirmed = true;
                    if (ctrl.row3Media) ctrl.row3Media.isPlaying = true;
                } else if (rootWindow.activeConfirmTarget === "row5") {
                    rootWindow.row5ValveConfirmed = true;
                    if (ctrl.row5Media) ctrl.row5Media.isPlaying = true;
                }
                if (ui.header) {
                    ui.header.alarmMessage = "VALVE POSITIONING CONFIRMED: [" + opKey.toUpperCase() + "] SEQUENCE RUNNING";
                }
            });

            ui.confirmModal.aborted.connect(function() {
                if (rootWindow.activeConfirmTarget === "row3") {
                    rootWindow.row3ValveConfirmed = false;
                    if (ctrl.row3Media) ctrl.row3Media.isPlaying = false;
                } else if (rootWindow.activeConfirmTarget === "row5") {
                    rootWindow.row5ValveConfirmed = false;
                    if (ctrl.row5Media) ctrl.row5Media.isPlaying = false;
                }
                if (ui.header) {
                    ui.header.alarmMessage = "SAFETY INTERLOCK: PROCESS START ABORTED - VALVES NOT CONFIRMED";
                    ui.header.isAlarmActive = true;
                }
            });

            ui.confirmModal.closed.connect(function() { ui.confirmModal.visible = false; });
        }

        // Heating Modal (Row 6)
        if (ui.heatingModal) {
            ui.heatingModal.optionSelected.connect(function(selector, val, iconKey) {
                if (selector === "mode" && ctrl.row6ModeSelector) {
                    ctrl.row6ModeSelector.iconName = iconKey;
                    ctrl.row6ModeSelector.modeText = val;
                } else if (selector === "regulation" && ctrl.row6RegSelector) {
                    ctrl.row6RegSelector.iconName = iconKey;
                    ctrl.row6RegSelector.modeText = val;
                } else if (selector === "temp_src" && ctrl.row6TempSrcSelector) {
                    ctrl.row6TempSrcSelector.iconName = iconKey;
                    ctrl.row6TempSrcSelector.modeText = val;
                }
            });
            ui.heatingModal.closed.connect(function() { ui.heatingModal.visible = false; });
        }
    }

    // --- Fast Process Simulation Loop (250ms) ---
    Timer {
        id: processSimulationTimer
        interval: 250
        running: true
        repeat: true
        onTriggered: {
            var ctrl = ui.controlView;
            if (!ctrl) return;

            // 1. Agitator 1 Speed Ramping
            if (ctrl.row1Media && ctrl.row1Media.isPlaying) {
                if (rootWindow.r1ActualSpeed < rootWindow.r1TargetSpeed) {
                    rootWindow.r1ActualSpeed = Math.min(rootWindow.r1TargetSpeed, rootWindow.r1ActualSpeed + 1.2);
                } else if (rootWindow.r1ActualSpeed > rootWindow.r1TargetSpeed) {
                    rootWindow.r1ActualSpeed = Math.max(rootWindow.r1TargetSpeed, rootWindow.r1ActualSpeed - 1.2);
                }
            } else {
                rootWindow.r1ActualSpeed = Math.max(0.0, rootWindow.r1ActualSpeed - 1.5);
            }
            if (ctrl.row1SpeedControl) ctrl.row1SpeedControl.currentVal = rootWindow.r1ActualSpeed;

            // 2. Homogenizer 2 Speed Ramping
            if (ctrl.row2Media && ctrl.row2Media.isPlaying) {
                if (rootWindow.r2ActualSpeed < rootWindow.r2TargetSpeed) {
                    rootWindow.r2ActualSpeed = Math.min(rootWindow.r2TargetSpeed, rootWindow.r2ActualSpeed + 45.0);
                } else if (rootWindow.r2ActualSpeed > rootWindow.r2TargetSpeed) {
                    rootWindow.r2ActualSpeed = Math.max(rootWindow.r2TargetSpeed, rootWindow.r2ActualSpeed - 45.0);
                }
            } else {
                rootWindow.r2ActualSpeed = Math.max(0.0, rootWindow.r2ActualSpeed - 60.0);
            }
            if (ctrl.row2SpeedControl) ctrl.row2SpeedControl.currentVal = rootWindow.r2ActualSpeed;

            // 3. Vacuum Chamber Evacuation Loop
            if (ctrl.row4Media && ctrl.row4Media.isPlaying) {
                if (rootWindow.vacuumPressure > -450.0) {
                    rootWindow.vacuumPressure -= 0.6;
                } else {
                    rootWindow.vacuumPressure = -450.0 + (Math.sin(Date.now() / 1000) * 0.4);
                }
                if (ctrl.row4PressureCard) {
                    ctrl.row4PressureCard.primaryValue = rootWindow.vacuumPressure.toFixed(1);
                    ctrl.row4PressureCard.progressValue = Math.abs(rootWindow.vacuumPressure) / 450.0;
                }
            }

            // 4. Heating Temperature Loop
            if (ctrl.row6Media && ctrl.row6Media.isPlaying) {
                if (rootWindow.productTemp < rootWindow.targetTemp) {
                    rootWindow.productTemp += 0.05;
                }
                var dev = Math.max(0.0, rootWindow.targetTemp - rootWindow.productTemp);
                if (ctrl.row6TempCard) ctrl.row6TempCard.primaryValue = rootWindow.productTemp.toFixed(1);
                if (ctrl.row6DevCard) ctrl.row6DevCard.primaryValue = dev.toFixed(1);
                if (ctrl.row6GradientCard) ctrl.row6GradientCard.progressValue = Math.min(1.0, rootWindow.productTemp / rootWindow.targetTemp);
            }

            // 5. Synchronize State with ScadaStateMiddleware for P&ID and other screens
            scadaMiddleware.isAgitatorRunning = (ctrl.row1Media && ctrl.row1Media.isPlaying);
            scadaMiddleware.agitatorSpeed = rootWindow.r1ActualSpeed;
            scadaMiddleware.agitatorMode = (ctrl.row1ModeSelector && ctrl.row1ModeSelector.iconName) ? ctrl.row1ModeSelector.iconName : "agitator_cw";
            scadaMiddleware.isHomogenizerRunning = (ctrl.row2Media && ctrl.row2Media.isPlaying);
            scadaMiddleware.homogenizerSpeed = rootWindow.r2ActualSpeed;
            scadaMiddleware.isCirculationRunning = (ctrl.row3Media && ctrl.row3Media.isPlaying);
            scadaMiddleware.isCipActive = (ctrl.row3Media && ctrl.row3Media.isPlaying && (rootWindow.row3SelectedPreset === "ext_cip_rinse" || rootWindow.row3SelectedPreset === "ext_cip_recirculation"));
            scadaMiddleware.isVacuumActive = (ctrl.row4Media && ctrl.row4Media.isPlaying);
            scadaMiddleware.vacuumPressure = rootWindow.vacuumPressure;
            scadaMiddleware.isHeating = (ctrl.row6Media && ctrl.row6Media.isPlaying);
            scadaMiddleware.vesselTemp = rootWindow.productTemp;
            scadaMiddleware.targetTemp = rootWindow.targetTemp;

            // Direct Real-time Sync to P&ID Screen Bridge
            if (ui.pidScreen && ui.pidScreen.scadaBridge) {
                ui.pidScreen.scadaBridge.isAgitatorRunning = scadaMiddleware.isAgitatorRunning;
                ui.pidScreen.scadaBridge.agitatorSpeed = scadaMiddleware.agitatorSpeed;
                ui.pidScreen.scadaBridge.agitatorMode = scadaMiddleware.agitatorMode;
                ui.pidScreen.scadaBridge.isHomogenizerRunning = scadaMiddleware.isHomogenizerRunning;
                ui.pidScreen.scadaBridge.homogenizerSpeed = scadaMiddleware.homogenizerSpeed;
                ui.pidScreen.scadaBridge.isCirculationRunning = scadaMiddleware.isCirculationRunning;
                ui.pidScreen.scadaBridge.isCipActive = scadaMiddleware.isCipActive;
                ui.pidScreen.scadaBridge.isVacuumActive = scadaMiddleware.isVacuumActive;
                ui.pidScreen.scadaBridge.vacuumPressure = scadaMiddleware.vacuumPressure;
                ui.pidScreen.scadaBridge.isHeating = scadaMiddleware.isHeating;
                ui.pidScreen.scadaBridge.vesselTemp = scadaMiddleware.vesselTemp;
                ui.pidScreen.scadaBridge.targetTemp = scadaMiddleware.targetTemp;
            }
        }
    }

    // --- 1-Second Independent Runtime Timers ---
    Timer {
        id: clockTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var ctrl = ui.controlView;
            if (!ctrl) return;

            // 1. Agitator Runtime
            if (ctrl.row1Media && ctrl.row1Media.isPlaying && ctrl.row1Runtime) {
                rootWindow.r1RuntimeSeconds++;
                ctrl.row1Runtime.timeText = rootWindow.formatTime(rootWindow.r1RuntimeSeconds);
            }

            // 2. Homogenizer Runtime
            if (ctrl.row2Media && ctrl.row2Media.isPlaying && ctrl.row2Runtime) {
                rootWindow.r2RuntimeSeconds++;
                ctrl.row2Runtime.timeText = rootWindow.formatTime(rootWindow.r2RuntimeSeconds);
            }

            // 3. Circulation Runtime
            if (ctrl.row3Media && ctrl.row3Media.isPlaying && ctrl.row3Runtime) {
                rootWindow.r3RuntimeSeconds++;
                ctrl.row3Runtime.timeText = rootWindow.formatTime(rootWindow.r3RuntimeSeconds);
            }

            // 4. Vacuum Runtime
            if (ctrl.row4Media && ctrl.row4Media.isPlaying && ctrl.row4Runtime) {
                rootWindow.r4RuntimeSeconds++;
                ctrl.row4Runtime.timeText = rootWindow.formatTime(rootWindow.r4RuntimeSeconds);
            }

            // 5. Suction Liquids Runtime
            if (ctrl.row5Media && ctrl.row5Media.isPlaying && ctrl.row5Runtime) {
                rootWindow.r5RuntimeSeconds++;
                ctrl.row5Runtime.timeText = rootWindow.formatTime(rootWindow.r5RuntimeSeconds);
            }

            // 6. Heating Runtime
            if (ctrl.row6Media && ctrl.row6Media.isPlaying && ctrl.row6Runtime) {
                rootWindow.r6RuntimeSeconds++;
                ctrl.row6Runtime.timeText = rootWindow.formatTime(rootWindow.r6RuntimeSeconds);
            }
        }
    }
}
