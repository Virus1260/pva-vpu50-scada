
/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML.
*/
import QtQuick

Item {
    id: heaterRoot
    width: 40
    height: 64

    property string tag: "W 168 001"
    property bool isHeating: false
    property bool showTags: true

    property alias mouseArea: heaterMouseArea

    signal clicked

    // 1. INLINE ELECTRIC HEATER VECTOR (Bottom Inlet & Top Outlet - 100% Qt Design Studio Visible)
    Image {
        id: heaterVector
        anchors.fill: parent
        source: heaterRoot.isHeating ? "../../../assets/icons/pid/heater_inline_active.svg" : "../../../assets/icons/pid/heater_inline_idle.svg"
        sourceSize.width: 80
        sourceSize.height: 128
        fillMode: Image.PreserveAspectFit
    }

    // 2. TAG LABEL
    Text {
        visible: heaterRoot.showTags
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        anchors.topMargin: -38
        text: heaterRoot.tag
        color: heaterRoot.isHeating ? "#f97316" : "#8cb5dc"
        font.pixelSize: 8
        anchors.horizontalCenterOffset: 46
        font.bold: true
    }

    MouseArea {
        id: heaterMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
}
