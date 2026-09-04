import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
    id: root
    property string title: "Target Speed"
    property real value: 600.0
    property real minValue: 600.0
    property real maxValue: 4800.0
    property real stepSize: 50.0
    property string unit: AppConstants.unitRpm
    property int decimals: 0
    property bool readOnly: false
    property bool isLocked: false
    property string parameterTitle: "Target Speed"
    property string parameterTag: ""

    signal valueModified(real newValue)
    signal setpointRequested(string title, string tag, double current, double min, double max, string unit)

    implicitWidth: parent ? parent.width : 360
    implicitHeight: 110
    Layout.fillWidth: true
    Layout.preferredHeight: 110
    color: Theme.bgInput
    radius: Dimensions.cornerRadiusMd
    border.color: Theme.borderDim
    border.width: Dimensions.borderWidthThin

    function applyValue(newVal) {
        if (readOnly || isLocked) return;
        var clamped = Math.max(minValue, Math.min(maxValue, newVal));
        if (decimals === 0) {
            clamped = Math.round(clamped);
        } else {
            clamped = Math.round(clamped * 10.0) / 10.0;
        }
        root.value = clamped;
        root.valueModified(clamped);
    }

    // Auto-repeat timers for continuous hold on increment/decrement
    Timer {
        id: decRepeatTimer
        interval: 100
        repeat: true
        running: false
        onTriggered: root.applyValue(root.value - root.stepSize)
    }

    Timer {
        id: decInitialTimer
        interval: 400
        repeat: false
        onTriggered: {
            if (decArea.pressed) decRepeatTimer.start();
        }
    }

    Timer {
        id: incRepeatTimer
        interval: 100
        repeat: true
        running: false
        onTriggered: root.applyValue(root.value + root.stepSize)
    }

    Timer {
        id: incInitialTimer
        interval: 400
        repeat: false
        onTriggered: {
            if (incArea.pressed) incRepeatTimer.start();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Dimensions.spaceSm
        spacing: Dimensions.spaceXs

        // Header Row: Label + Large Live Digital Readout
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: root.title
                color: Theme.textSecondary
                font.pointSize: Typography.sizeBody
                font.family: Typography.fontDisplay
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
            Text {
                text: root.value.toFixed(root.decimals) + " " + root.unit
                color: Theme.textHighlight
                font.pointSize: Typography.sizeH2
                font.family: Typography.fontMono
                font.weight: Typography.weightBold
            }
        }

        // Tactile Control Bar: [SET MIN] [-] [Slider Track] [+] [SET MAX]
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Dimensions.minTouchTarget
            spacing: Dimensions.spaceSm

            // Set Min Quick-Button (64px wide, 52px high)
            Rectangle {
                Layout.preferredWidth: 64
                Layout.fillHeight: true
                radius: Dimensions.cornerRadiusSm
                color: minArea.pressed ? Theme.accentHover : (minArea.containsMouse ? Theme.bgCardHover : Theme.bgCard)
                border.color: Theme.borderDim
                enabled: !root.readOnly && !root.isLocked

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 2
                    Text {
                        text: "MIN"
                        color: Theme.textSecondary
                        font.pointSize: Typography.sizeBadge
                        font.weight: Typography.weightBold
                        font.family: Typography.fontDisplay
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: root.minValue.toFixed(root.decimals)
                        color: Theme.textPrimary
                        font.pointSize: Typography.sizeBadge
                        font.weight: Typography.weightBold
                        font.family: Typography.fontMono
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                MouseArea {
                    id: minArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: root.applyValue(root.minValue)
                }
            }

            // Decrement Button [-] (52px wide, 52px high)
            Rectangle {
                Layout.preferredWidth: Dimensions.minTouchTarget
                Layout.fillHeight: true
                radius: Dimensions.cornerRadiusSm
                color: decArea.pressed ? Theme.accentHover : (decArea.containsMouse ? Theme.bgCardHover : Theme.bgCard)
                border.color: Theme.borderBright
                border.width: Dimensions.borderWidthThin
                enabled: !root.readOnly && !root.isLocked && root.value > root.minValue
                opacity: enabled ? 1.0 : 0.4

                Text {
                    anchors.centerIn: parent
                    text: "–"
                    color: Theme.textPrimary
                    font.pointSize: Typography.sizeH1
                    font.weight: Typography.weightBold
                }

                MouseArea {
                    id: decArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onPressed: {
                        root.applyValue(root.value - root.stepSize);
                        decInitialTimer.start();
                    }
                    onReleased: {
                        decInitialTimer.stop();
                        decRepeatTimer.stop();
                    }
                    onCanceled: {
                        decInitialTimer.stop();
                        decRepeatTimer.stop();
                    }
                }
            }

            // Central Progress / Fill Indicator (Clickable to open virtual keypad)
            Rectangle {
                id: progressContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: channelArea.containsMouse ? Theme.bgCardHover : Theme.bgApp
                radius: Dimensions.cornerRadiusSm
                border.color: channelArea.containsMouse ? Theme.primaryGlow : Theme.borderDim
                border.width: Dimensions.borderWidthThin
                clip: true

                // Dynamic progress fill
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: {
                        var range = Math.max(0.001, root.maxValue - root.minValue);
                        var fraction = Math.max(0.0, Math.min(1.0, (root.value - root.minValue) / range));
                        return Math.max(0, parent.width * fraction);
                    }
                    color: Theme.primary
                    opacity: 0.35
                }

                // Center position indicator needle
                Rectangle {
                    x: {
                        var range = Math.max(0.001, root.maxValue - root.minValue);
                        var fraction = Math.max(0.0, Math.min(1.0, (root.value - root.minValue) / range));
                        return Math.max(0, Math.min(parent.width - 3, (parent.width - 3) * fraction));
                    }
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 3
                    color: Theme.textPrimary
                    border.color: Theme.primaryGlow
                    border.width: 1
                    radius: 1.5
                }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Dimensions.spaceXs

                    // Keypad prompt icon badge
                    Rectangle {
                        width: 16
                        height: 14
                        radius: 2
                        color: Theme.bgApp
                        border.color: channelArea.containsMouse ? Theme.primaryGlow : Theme.primary
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "⌨"
                            color: Theme.textHighlight
                            font.pixelSize: 10
                        }
                    }

                    Text {
                        text: {
                            var range = Math.max(0.001, root.maxValue - root.minValue);
                            var pct = Math.round(((root.value - root.minValue) / range) * 100);
                            return pct + "% (" + root.value.toFixed(root.decimals) + " " + root.unit + ")";
                        }
                        color: Theme.textPrimary
                        font.pointSize: Typography.sizeBody
                        font.weight: Typography.weightBold
                        font.family: Typography.fontMono
                    }
                }

                MouseArea {
                    id: channelArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: (!root.readOnly && !root.isLocked) ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        root.setpointRequested(
                            root.parameterTitle || root.title,
                            root.parameterTag,
                            root.value,
                            root.minValue,
                            root.maxValue,
                            root.unit
                        );
                    }
                }
            }

            // Increment Button [+] (52px wide, 52px high)
            Rectangle {
                Layout.preferredWidth: Dimensions.minTouchTarget
                Layout.fillHeight: true
                radius: Dimensions.cornerRadiusSm
                color: incArea.pressed ? Theme.accentHover : (incArea.containsMouse ? Theme.bgCardHover : Theme.bgCard)
                border.color: Theme.borderBright
                border.width: Dimensions.borderWidthThin
                enabled: !root.readOnly && !root.isLocked && root.value < root.maxValue
                opacity: enabled ? 1.0 : 0.4

                Text {
                    anchors.centerIn: parent
                    text: "+"
                    color: Theme.textPrimary
                    font.pointSize: Typography.sizeH1
                    font.weight: Typography.weightBold
                }

                MouseArea {
                    id: incArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onPressed: {
                        root.applyValue(root.value + root.stepSize);
                        incInitialTimer.start();
                    }
                    onReleased: {
                        incInitialTimer.stop();
                        incRepeatTimer.stop();
                    }
                    onCanceled: {
                        incInitialTimer.stop();
                        incRepeatTimer.stop();
                    }
                }
            }

            // Set Max Quick-Button (64px wide, 52px high)
            Rectangle {
                Layout.preferredWidth: 64
                Layout.fillHeight: true
                radius: Dimensions.cornerRadiusSm
                color: maxArea.pressed ? Theme.accentHover : (maxArea.containsMouse ? Theme.bgCardHover : Theme.bgCard)
                border.color: Theme.borderDim
                enabled: !root.readOnly && !root.isLocked

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 2
                    Text {
                        text: "MAX"
                        color: Theme.textSecondary
                        font.pointSize: Typography.sizeBadge
                        font.weight: Typography.weightBold
                        font.family: Typography.fontDisplay
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: root.maxValue.toFixed(root.decimals)
                        color: Theme.textPrimary
                        font.pointSize: Typography.sizeBadge
                        font.weight: Typography.weightBold
                        font.family: Typography.fontMono
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                MouseArea {
                    id: maxArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: root.applyValue(root.maxValue)
                }
            }
        }
    }
}
