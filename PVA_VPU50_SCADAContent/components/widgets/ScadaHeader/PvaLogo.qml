import QtQuick
import QtQuick.Shapes

Item {
    id: pvaLogoRoot
    implicitWidth: 84
    implicitHeight: 28
    width: 84
    height: 28

    property real scaleRatio: Math.min(width / 101.5, height / 35.0)

    Shape {
        id: shape
        anchors.centerIn: parent
        width: 101.5
        height: 35
        scale: pvaLogoRoot.scaleRatio

        // -------------------------------------------------------------
        // 'P' in PVA Crimson Red (#F32B47)
        // -------------------------------------------------------------
        ShapePath {
            fillColor: "#F32B47"
            strokeColor: "transparent"
            strokeWidth: 0
            fillRule: ShapePath.WindingFill
            PathSvg {
                path: "M15.55 15.55Q17.10 15.55 18.13 15.07Q19.15 14.60 19.68 13.65Q20.20 12.70 20.20 11.40 Q20.20 9.50 19.05 8.40Q17.90 7.30 15.55 7.30 L8.70 7.30L8.70 15.55L15.55 15.55 M29.05 11.40Q29.05 13.50 28.28 15.55Q27.50 17.60 25.93 19.25 Q24.35 20.90 21.90 21.88Q19.45 22.85 16.10 22.85 L8.70 22.85L8.70 35.00L0 35.00L0 0.00L16.10 0.00 Q20.45 0.00 23.33 1.57Q26.20 3.15 27.63 5.75 Q29.05 8.35 29.05 11.40Z"
            }
        }

        // -------------------------------------------------------------
        // 'V' in PVA Teal / Turquoise (#00A296)
        // -------------------------------------------------------------
        ShapePath {
            fillColor: "#00A296"
            strokeColor: "transparent"
            strokeWidth: 0
            fillRule: ShapePath.WindingFill
            PathSvg {
                path: "M57.85 0.00L67.20 0.00L54.80 35.00 L43.75 35.00L31.35 0.00L40.70 0.00 L49.30 26.20L57.85 0.00Z"
            }
        }

        // -------------------------------------------------------------
        // 'A' Main Legs in PVA Teal / Turquoise (#00A296)
        // -------------------------------------------------------------
        ShapePath {
            fillColor: "#00A296"
            strokeColor: "transparent"
            strokeWidth: 0
            fillRule: ShapePath.WindingFill
            PathSvg {
                path: "M82.65 7.30 L80.90 7.30 L71.20 35.00 L62.20 35.00 L75.00 0.00 L88.80 0.00 L101.50 35.00 L92.50 35.00 L82.65 7.30 Z"
            }
        }

        // -------------------------------------------------------------
        // 'A' Crossbar in PVA Teal / Turquoise (#00A296) - Solid bridge
        // -------------------------------------------------------------
        ShapePath {
            fillColor: "#00A296"
            strokeColor: "transparent"
            strokeWidth: 0
            fillRule: ShapePath.WindingFill
            PathSvg {
                path: "M70.00 20.70 L93.50 20.70 L93.50 28.00 L70.00 28.00 Z"
            }
        }
    }
}
