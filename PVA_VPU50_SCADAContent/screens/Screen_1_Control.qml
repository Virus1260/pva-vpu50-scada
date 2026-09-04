import QtQuick
import QtQuick.Layouts

Item {
    id: controlScreenContainer
    width: 1184
    height: 626
    implicitWidth: 1184
    implicitHeight: 626
    Layout.fillWidth: true
    Layout.fillHeight: true

    Screen_1_ControlView {
        id: ui
        anchors.fill: parent
    }

    // Property Aliases for Row 1 (Agitator / Mixing 1)
    property alias row1ModeSelector: ui.row1ModeSelector
    property alias row1PowerCard: ui.row1PowerCard
    property alias row1SpeedControl: ui.row1SpeedControl
    property alias row1MinusBtn: ui.row1MinusBtn
    property alias row1PlusBtn: ui.row1PlusBtn
    property alias row1Media: ui.row1Media
    property alias row1Runtime: ui.row1Runtime

    // Property Aliases for Row 2 (Homogenizer / Mixing 2)
    property alias row2ModeSelector: ui.row2ModeSelector
    property alias row2PowerCard: ui.row2PowerCard
    property alias row2SpeedControl: ui.row2SpeedControl
    property alias row2MinusBtn: ui.row2MinusBtn
    property alias row2PlusBtn: ui.row2PlusBtn
    property alias row2Media: ui.row2Media
    property alias row2Runtime: ui.row2Runtime

    // Property Aliases for Row 3 (Circulation)
    property alias row3ModeSelector: ui.row3ModeSelector
    property alias row3Media: ui.row3Media
    property alias row3Runtime: ui.row3Runtime

    // Property Aliases for Row 4 (Vacuum)
    property alias row4ModeSelector: ui.row4ModeSelector
    property alias row4PressureCard: ui.row4PressureCard
    property alias row4StartCard: ui.row4StartCard
    property alias row4EndCard: ui.row4EndCard
    property alias row4Media: ui.row4Media
    property alias row4Runtime: ui.row4Runtime

    // Property Aliases for Row 5 (Suction Liquids)
    property alias row5ModeSelector: ui.row5ModeSelector
    property alias row5AngleOpenCard: ui.row5AngleOpenCard
    property alias row5AngleCloseCard: ui.row5AngleCloseCard
    property alias row5TimeOpenCard: ui.row5TimeOpenCard
    property alias row5TimeCloseCard: ui.row5TimeCloseCard
    property alias row5Media: ui.row5Media
    property alias row5Runtime: ui.row5Runtime

    // Property Aliases for Row 6 (Heating / Temperature)
    property alias row6ModeSelector: ui.row6ModeSelector
    property alias row6RegSelector: ui.row6RegSelector
    property alias row6TempSrcSelector: ui.row6TempSrcSelector
    property alias row6GradientCard: ui.row6GradientCard
    property alias row6DeltaTCard: ui.row6DeltaTCard
    property alias row6TempCard: ui.row6TempCard
    property alias row6DevCard: ui.row6DevCard
    property alias row6Media: ui.row6Media
    property alias row6Runtime: ui.row6Runtime

    // --- Run-Mode Decoupling & Automatic Recipe Lockout Properties ---
    property alias isLocked: ui.isLocked
    property alias lockoutBatchId: ui.lockoutBatchId
    property alias lockoutRecipeName: ui.lockoutRecipeName
    property alias lockoutStep: ui.lockoutStep
    property alias lockoutTotalSteps: ui.lockoutTotalSteps
}
