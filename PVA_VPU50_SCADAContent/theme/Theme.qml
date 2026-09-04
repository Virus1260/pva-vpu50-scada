// PVA_VPU50_SCADAContent/theme/Theme.qml
pragma Singleton
import QtQuick

Item {
    // Surface & Background Colors
    readonly property color bgApp:         "#071321" // Deep industrial navy
    readonly property color bgSurface:     "#0d1f35" // Panel surface
    readonly property color bgCard:        "#132b47" // Elevated card
    readonly property color bgCardHover:   "#1a3759" // Interactive card hover
    readonly property color bgInput:       "#091727" // Input field recessed base

    // Primary Accents & Focus
    readonly property color primary:       "#0ea5e9" // Bright cyan-blue
    readonly property color primaryGlow:   "#38bdf8" // Focus indicator
    readonly property color accentHover:   "#0284c7" // Active pressed state
    readonly property color borderDim:     "#1e3a5f" // Subdued card divider
    readonly property color borderBright:  "#2563eb" // Active step border

    // Semantic Industrial Alarm / Status Colors
    readonly property color statusDraft:   "#64748b" // Slate grey
    readonly property color statusReview:  "#f59e0b" // Industrial amber
    readonly property color statusApprove: "#10b981" // Safe emerald green
    readonly property color statusError:   "#ef4444" // E-Stop / Fault red
    readonly property color statusManual:  "#d97706" // Operator intervention yellow

    // Typography Colors
    readonly property color textPrimary:   "#f8fafc" // High-contrast white (100%)
    readonly property color textSecondary: "#94a3b8" // Subdued labels (70%)
    readonly property color textTertiary:  "#64748b" // Units, placeholders (50%)
    readonly property color textHighlight: "#38bdf8" // Key values, active tags

    // Standardized Gradients
    readonly property Gradient buttonGradient: Gradient {
        GradientStop { position: 0.0; color: "#1e40af" }
        GradientStop { position: 1.0; color: "#1d4ed8" }
    }
}
