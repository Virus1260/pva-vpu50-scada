// PVA_VPU50_SCADAContent/theme/Typography.qml
pragma Singleton
import QtQuick

Item {
    readonly property string fontDisplay: "Segoe UI"
    readonly property string fontMono:    "Consolas"

    // Hierarchy Scales (Sizes in Points)
    readonly property int sizeH1:         20 // Screen Titles, Main Process Values
    readonly property int sizeH2:         16 // Section Headers, Step Titles
    readonly property int sizeH3:         14 // Subsection Titles, Stepper Values
    readonly property int sizeBody:       12 // Labels, Form Inputs, Card Subtitles
    readonly property int sizeBadge:      10 // Monospace Status Tags (Minimum)
    readonly property int sizeMicro:      9  // Read-only metadata timestamps

    // Font Weights
    readonly property int weightBold:     Font.Bold
    readonly property int weightMedium:   Font.Medium
    readonly property int weightRegular:  Font.Normal
}
