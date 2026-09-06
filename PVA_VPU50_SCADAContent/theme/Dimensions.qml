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

    // 5 Systematic Box Sizes (Tiers 1-5)
    readonly property int boxSizeXs:                28 // Level 1: Micro badges, status chips, tags
    readonly property int boxSizeSm:                36 // Level 2: Compact inputs, context buttons
    readonly property int boxSizeMd:                44 // Level 3: Standard buttons, touch input fields
    readonly property int boxSizeLg:                56 // Level 4: Primary action buttons, dialog headers
    readonly property int boxSizeXl:                86 // Level 5: Standard SCADA process cards, timeline rows

    // 5 Systematic Corner Radii (Tiers 1-5)
    readonly property int radiusXs:                 2  // Subdued tags
    readonly property int radiusSm:                 4  // SCADA cards & buttons
    readonly property int radiusMd:                 8  // Floating dialogs & modals
    readonly property int radiusLg:                 12 // Elevated panels
    readonly property int radiusFull:               999 // Pills & circular badges

    readonly property int cornerRadiusSm:    4
    readonly property int cornerRadiusMd:    8
    readonly property int cornerRadiusLg:    12
    readonly property int borderWidthThin:   1
    readonly property int borderWidthThick:  2

    // 5 Systematic Layout Spacings & Paddings (Tiers 1-5)
    readonly property int spaceXs:           4  // Level 1: Tight grouping
    readonly property int spaceSm:           8  // Level 2: Item padding
    readonly property int spaceMd:           14 // Level 3: Standard card padding
    readonly property int spaceLg:           20 // Level 4: Section margins
    readonly property int spaceXl:           28 // Level 5: Container margins

    // Touch Magnifying Loupe & Text Selection Dimensions
    readonly property int loupeDiameter:            84 // Circular magnifying bubble diameter
    readonly property int loupeRadius:              42 // Circular radius
    readonly property real loupeZoomScale:          1.75 // Magnification factor
    readonly property int loupeOffsetY:             -64 // Float distance above operator finger
    readonly property int selectionHandleRadius:    6  // Teardrop pin radius
    readonly property int selectionHandleHeight:    24 // Teardrop handle height
    readonly property int contextMenuHeight:        36 // Floating action pill height

    // Fixed Structure Widths
    readonly property int navRailWidth:      84 // Vertical right navigation bar
    readonly property int toolboxWidth:      260 // Left ISA-88 step palette
    readonly property int inspectorWidth:    380 // Right step inspector panel
}
