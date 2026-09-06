// PVA_VPU50_SCADAContent/theme/Typography.qml
pragma Singleton
import QtQuick

Item {
    readonly property string fontDisplay: "Segoe UI"
    readonly property string fontMono:    "Consolas"

    // 5 Systematic Hierarchy Scale Levels
    readonly property int level1:         20 // Level 1 (H1): Screen Titles, Key Values
    readonly property int level2:         16 // Level 2 (H2): Section Headers, Modal Titles
    readonly property int level3:         14 // Level 3 (H3): Subsection Titles, Stepper Values
    readonly property int level4:         12 // Level 4 (Body): Labels, Form Inputs, Standard Text
    readonly property int level5:         10 // Level 5 (Caption/Badge): Status Tags, Micro Metadata

    // Hierarchy Scales (Sizes in Points - Aliases for compatibility)
    readonly property int sizeH1:         level1
    readonly property int sizeH2:         level2
    readonly property int sizeH3:         level3
    readonly property int sizeBody:       level4
    readonly property int sizeBadge:      level5
    readonly property int sizeMicro:      9  // Read-only metadata timestamps

    // Font Weights
    readonly property int weightBold:     Font.Bold
    readonly property int weightMedium:   Font.Medium
    readonly property int weightRegular:  Font.Normal
}
