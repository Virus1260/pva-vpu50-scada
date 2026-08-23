/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML.
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PVA_VPU50_SCADA
import "screens"
import "components/widgets"
import "components/widgets/Screen_1_Control"
import "components/modals"
import "components/modals/Screen_1_Control"

Rectangle {
    id: rootScreen
    width: 1280
    height: 720
    color: "#08213b"

    // Property Aliases for Top Header
    property alias header: scadaHeader
    property alias ackButton: scadaHeader.ackButton

    // Property Aliases for Control Screen View
    property alias controlView: controlScreenView

    // Property Aliases for Sidebar & Screens
    property alias sidebar: rightSidebar
    property alias screenStack: mainStack
    property alias pidScreen: pidView
    property alias trendsScreen: trendsView
    property alias alarmsScreen: alarmsView
    property alias recipesScreen: recipesView
    property alias recipeMakerScreen: makerView
    property alias auditScreen: auditView
    property alias playbackScreen: playbackView
    property alias maintenanceScreen: maintView

    // Property Aliases for Modals
    property alias keypadModal: numpadOverlay
    property alias agitatorModal: agitatorModeOverlay
    property alias homoModal: homoModeOverlay
    property alias vacuumModal: vacuumModeOverlay
    property alias extLineModal: extLineOverlay
    property alias fillingModal: fillingModeOverlay
    property alias heatingModal: heatModeOverlay
    property alias plantModal: plantModeOverlay
    property alias confirmModal: confirmDialogOverlay
    property alias loginModal: loginOverlay

    // 1. TOP PROCESS HEADER BAR (Anchored directly to top, 86px height matching process cards)
    ScadaHeader {
        id: scadaHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 86
        z: 10
        vesselName: "VPU 50"
        activeBatchId: "B1"
        alarmMessage: "SYSTEM READY - RECIPE [VPU_BATCH_01] STANDBY"
    }

    // 2. RIGHT-SIDE SCADA NAVIGATION DOCK (110px Width, Large Touch Ergonomics)
    ScadaSidebar {
        id: rightSidebar
        anchors.top: scadaHeader.bottom
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 110
        z: 10
    }

    // 3. CENTER DYNAMIC SCREEN CONTAINER (Anchored between header, sidebar & bounds)
    StackLayout {
        id: mainStack
        anchors.top: scadaHeader.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: rightSidebar.left
        anchors.margins: 4
        clip: true
        currentIndex: rightSidebar.activeIndex

        // SCREEN 0: 6-ROW PROCESS CONTROL DASHBOARD
        Screen_1_Control {
            id: controlScreenView
        }

        // SCREEN 1: P&ID VESSEL & PLANT SCHEMATIC
        Screen_2_P_ID {
            id: pidView
        }

        // SCREEN 2: PROCESS TRENDS & HISTORICAL ANALYTICS
        Screen_3_Trends {
            id: trendsView
        }

        // SCREEN 3: ALARMS & ANNUNCIATOR
        Screen_4_Alarms {
            id: alarmsView
        }

        // SCREEN 4: RECIPE EXECUTION (OPERATOR & RUN MONITORING)
        Screen_5_Recipes {
            id: recipesView
        }

        // SCREEN 5: RECIPE MAKER (AUTHORING - INCHARGE & ADMIN)
        Screen_9_RecipeMaker {
            id: makerView
        }

        // SCREEN 6: AUDIT TRAIL & 21 CFR PART 11 EBR
        Screen_6_Audit {
            id: auditView
        }

        // SCREEN 7: HARDWARE MAINTENANCE & I/O DIAGNOSTICS
        Screen_8_Diagnostics {
            id: maintView
        }
    }

    // =========================================================================
    // MODAL DIALOGS & OVERLAYS (Z: 100)
    // =========================================================================

    // 1. Numeric Keypad Setpoint Modal (Global)
    NumericKeypadModal {
        id: numpadOverlay
        anchors.fill: parent
        visible: false
        z: 100
    }

    // 2. Agitator Mode Selector Overlay (Screen 1 Control)
    AgitatorModeModal {
        id: agitatorModeOverlay
        anchors.fill: parent
        visible: false
        z: 100
    }

    // 3. Homogenizer Mode Selector Overlay (Screen 1 Control)
    HomogenizerModeModal {
        id: homoModeOverlay
        anchors.fill: parent
        visible: false
        z: 100
    }

    // 4. Vacuum Mode Selector Overlay (Screen 1 Control)
    VacuumModeModal {
        id: vacuumModeOverlay
        anchors.fill: parent
        visible: false
        z: 100
    }

    // 5. External Line Mode Selector Overlay (Screen 1 Control)
    ExternalLineModeModal {
        id: extLineOverlay
        anchors.fill: parent
        visible: false
        z: 100
    }

    // 6. Suction / Filling Mode Selector Overlay (Screen 1 Control)
    FillingModeModal {
        id: fillingModeOverlay
        anchors.fill: parent
        visible: false
        z: 100
    }

    // 7. Heating Mode Selector Overlay (Screen 1 Control)
    HeatingModeModal {
        id: heatModeOverlay
        anchors.fill: parent
        visible: false
        z: 100
    }

    // 8. Plant / Vessel Mode Selector Overlay (Global)
    PlantModeModal {
        id: plantModeOverlay
        anchors.fill: parent
        visible: false
        z: 100
    }

    // 9. Standard Confirm / Override Dialog Overlay (Global)
    ConfirmationModal {
        id: confirmDialogOverlay
        anchors.fill: parent
        visible: false
        z: 100
    }

    // 10. 21 CFR Part 11 User Authentication & Access Control Modal (Global)
    LoginModal {
        id: loginOverlay
        anchors.fill: parent
        visible: false
        z: 100
    }
}
