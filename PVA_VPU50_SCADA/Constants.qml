pragma Singleton
import QtQuick

QtObject {
    readonly property int width: 1280
    readonly property int height: 720

    property string relativeFontDirectory: "fonts"

    readonly property font font: Qt.font({
                                             family: "Segoe UI",
                                             pixelSize: 12
                                         })
    readonly property font largeFont: Qt.font({
                                                  family: "Segoe UI",
                                                  pixelSize: 18
                                              })

    readonly property color backgroundColor: "#08213b"
}
