// PVA_VPU50_SCADAContent/theme/Dimensions.qml
pragma Singleton
import QtQuick

Item {
    // Touch Target Standards (ISO 9241-9 / DIN EN ISO 9241)
    readonly property int minTouchTarget:    52 // Minimum touchable height/width
    readonly property int buttonHeightLg:    56 // Primary action buttons
    readonly property int buttonHeightMd:    48 // Secondary table buttons
    readonly property int iconBoxSmall:      48 // Step reordering [↑] [↓]
    readonly property int iconBoxLarge:      64 // Main navigation bar items

    // Card & Layout Sizing
    readonly property int cornerRadiusSm:    4
    readonly property int cornerRadiusMd:    8
    readonly property int cornerRadiusLg:    12
    readonly property int borderWidthThin:   1
    readonly property int borderWidthThick:  2

    // Layout Paddings & Gaps
    readonly property int spaceXs:           4
    readonly property int spaceSm:           8
    readonly property int spaceMd:           14
    readonly property int spaceLg:           20
    readonly property int spaceXl:           28

    // Fixed Structure Widths
    readonly property int navRailWidth:      84 // Vertical right navigation bar
    readonly property int toolboxWidth:      260 // Left ISA-88 step palette
    readonly property int inspectorWidth:    380 // Right step inspector panel
}
