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

    // Card & Layout Sizing (SCADA Standard Presets matching Screen 1 Control Screen)
    readonly property int cardHeightStandard:       86 // Primary SCADA card row height (Screen 1 & Timeline)
    readonly property int cardHeightCompact:        68 // Compact card row height
    readonly property int cardHeightExtended:       106 // Multi-line detailed card height
    readonly property int cardBorderRadius:         4  // Standard SCADA card corner radius

    // SCADA Button Standards (Matching Screen 1 Control Screen Media Buttons)
    readonly property int controlButtonSize:        44 // Standard 44x44px touch button
    readonly property int controlButtonRadius:      4  // 4px corner radius
    readonly property int controlButtonIconSize:    22 // Standard 22px icon inside 44px button
    readonly property int controlButtonSpacing:     6  // Standard 6px spacing between buttons

    // Phase Tile / Badge Standards
    readonly property int phaseBadgeWidth:          176 // Uniform width for ISA-88 phase badge tiles
    readonly property int phaseBadgeHeight:         38  // Uniform height for phase badge tiles

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
