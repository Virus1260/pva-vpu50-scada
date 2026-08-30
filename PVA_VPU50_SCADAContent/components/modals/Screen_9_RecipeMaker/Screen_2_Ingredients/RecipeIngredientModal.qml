pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../../../widgets"
import "../../../widgets/ScadaKeyboard"
import "../.."

Rectangle {
    id: ingModalRoot
    implicitWidth: 1024
    implicitHeight: 600
    color: "#cc000000"
    visible: false
    z: 100

    property string mode: "ADD" // "ADD", "EDIT", or "DUPLICATE"
    property int srNo: 1
    property string ingredientName: ""
    property string phase: "1"
    property string qtyValue: "1.0"
    property string qtyUnit: "kg"
    property string formulaText: ""
    property string isaParameters: "Take in main vessel and agitate."
    property bool isVariableQty: false

    signal accepted(var data)
    signal cancelled

    onVisibleChanged: {
        if (visible) {
            nameInput.text = ingModalRoot.ingredientName;
            var cleanPhase = ingModalRoot.phase.replace(/^Phase\s*/i, "").trim();
            phaseInput.text = cleanPhase || "1";
            qtyInput.text = ingModalRoot.isVariableQty ? ingModalRoot.formulaText : ingModalRoot.qtyValue;
            isaInput.text = ingModalRoot.isaParameters;
        } else {
            if (numpadModal.visible) numpadModal.visible = false;
            if (textKeyboard.visible) textKeyboard.visible = false;
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (numpadModal.visible) numpadModal.visible = false;
            if (textKeyboard.visible) textKeyboard.visible = false;
        }
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: 720
        height: 420
        color: "#0b2e52"
        border.color: ingModalRoot.mode === "DUPLICATE" ? "#f59e0b" : "#38bdf8"
        border.width: 2
        radius: 8

        // Top-Right Corner Close Button
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 12
            anchors.rightMargin: 12
            width: 28
            height: 28
            radius: 4
            z: 10
            color: closeMouse.containsMouse ? "#ef4444" : "#0d365e"
            border.color: closeMouse.containsMouse ? "#f87171" : "#1d5b94"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "✕"
                color: closeMouse.containsMouse ? "#ffffff" : "#94a3b8"
                font.pixelSize: 13
                font.bold: true
                font.family: "Segoe UI"
            }

            MouseArea {
                id: closeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    numpadModal.visible = false;
                    textKeyboard.visible = false;
                    ingModalRoot.cancelled();
                }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            // =================================================================
            // HEADER BAR
            // =================================================================
            RowLayout {
                Layout.fillWidth: true
                Layout.rightMargin: 36 // Space for close button
                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: 5
                    color: "#081d33"
                    border.color: ingModalRoot.mode === "DUPLICATE" ? "#f59e0b" : "#38bdf8"
                    border.width: 1

                    ScadaIcon {
                        anchors.centerIn: parent
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        iconName: ingModalRoot.mode === "DUPLICATE" ? "duplicate" : "recipes_checklist"
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: ingModalRoot.mode === "DUPLICATE" ? "DUPLICATE INGREDIENT SPECIFICATION" : (ingModalRoot.mode === "EDIT" ? "EDIT FORMULATION INGREDIENT" : "ADD FORMULATION INGREDIENT")
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 14
                        font.family: "Segoe UI"
                    }
                    Text {
                        text: "Raw Material Specification & ISA-88 Phase Allocation"
                        color: "#94a3b8"
                        font.pixelSize: 11
                        font.family: "Segoe UI"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#1d5b94"
            }

            // =================================================================
            // ROW 1: INGREDIENT RAW MATERIAL NAME
            // =================================================================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "INGREDIENT NAME (RAW MATERIAL) *"
                    color: "#38bdf8"
                    font.pixelSize: 11
                    font.bold: true
                    font.family: "Segoe UI"
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    color: "#081d33"
                    border.color: nameInput.activeFocus ? "#38bdf8" : "#1d5b94"
                    border.width: 1
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 8

                        Text {
                            text: "🧪"
                            font.pixelSize: 14
                        }

                        TextInput {
                            id: nameInput
                            Layout.fillWidth: true
                            verticalAlignment: TextInput.AlignVCenter
                            text: ingModalRoot.ingredientName
                            color: "#ffffff"
                            font.pixelSize: 13
                            font.bold: true
                            font.family: "Segoe UI"
                            selectByMouse: true
                            inputMethodHints: Qt.ImhNone
                            onTextChanged: ingModalRoot.ingredientName = text
                            onActiveFocusChanged: {
                                if (activeFocus) {
                                    numpadModal.visible = false;
                                    textKeyboard.openFor(nameInput, "INGREDIENT RAW MATERIAL");
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.IBeamCursor
                        onClicked: {
                            numpadModal.visible = false;
                            nameInput.forceActiveFocus();
                            textKeyboard.openFor(nameInput, "INGREDIENT RAW MATERIAL");
                        }
                    }
                }
            }

            // =================================================================
            // ROW 2: PHASE NUMBER & QUANTITY (2 Equal 50% Columns)
            // =================================================================
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // Left: Phase Number / Code
                ColumnLayout {
                    Layout.preferredWidth: 335
                    Layout.fillWidth: true
                    spacing: 4

                    RowLayout {
                        spacing: 6
                        Text {
                            text: "PHASE NUMBER / CODE *"
                            color: "#38bdf8"
                            font.pixelSize: 11
                            font.bold: true
                            font.family: "Segoe UI"
                        }
                        Text {
                            text: "(e.g. 1, 2, 3, 12)"
                            color: "#94a3b8"
                            font.pixelSize: 10
                            font.family: "Segoe UI"
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        color: "#081d33"
                        border.color: phaseInput.activeFocus ? "#38bdf8" : "#1d5b94"
                        border.width: 1
                        radius: 4

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 8

                            Text {
                                text: "Phase"
                                color: "#38bdf8"
                                font.pixelSize: 12
                                font.bold: true
                                font.family: "Segoe UI"
                            }

                            TextInput {
                                id: phaseInput
                                Layout.fillWidth: true
                                verticalAlignment: TextInput.AlignVCenter
                                text: ingModalRoot.phase
                                color: "#ffffff"
                                font.pixelSize: 13
                                font.bold: true
                                font.family: "Segoe UI"
                                selectByMouse: true
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                onTextChanged: {
                                    var clean = text.replace(/^Phase\s*/i, "").trim();
                                    ingModalRoot.phase = clean || text.trim();
                                }
                                onActiveFocusChanged: {
                                    if (activeFocus) {
                                        textKeyboard.visible = false;
                                        numpadModal.openForInput(phaseInput, "PHASE NUMBER", "", null, null);
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.IBeamCursor
                            onClicked: {
                                textKeyboard.visible = false;
                                phaseInput.forceActiveFocus();
                                numpadModal.openForInput(phaseInput, "PHASE NUMBER", "", null, null);
                            }
                        }
                    }
                }

                // Right: Quantity & Units
                ColumnLayout {
                    Layout.preferredWidth: 335
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: ingModalRoot.isVariableQty ? "FORMULA / VARIABLE RATIO *" : "QUANTITY (ABSOLUTE) *"
                        color: "#38bdf8"
                        font.pixelSize: 11
                        font.bold: true
                        font.family: "Segoe UI"
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        color: "#081d33"
                        border.color: qtyInput.activeFocus ? "#38bdf8" : "#1d5b94"
                        border.width: 1
                        radius: 4

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 8
                            spacing: 8

                            TextInput {
                                id: qtyInput
                                Layout.fillWidth: true
                                verticalAlignment: TextInput.AlignVCenter
                                text: ingModalRoot.isVariableQty ? ingModalRoot.formulaText : ingModalRoot.qtyValue
                                color: "#ffffff"
                                font.pixelSize: 13
                                font.bold: true
                                font.family: "Segoe UI"
                                selectByMouse: true
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                onTextChanged: {
                                    if (ingModalRoot.isVariableQty) {
                                        ingModalRoot.formulaText = text;
                                    } else {
                                        ingModalRoot.qtyValue = text;
                                    }
                                }
                                onActiveFocusChanged: {
                                    if (activeFocus) {
                                        textKeyboard.visible = false;
                                        numpadModal.openForInput(qtyInput, "QUANTITY", ingModalRoot.isVariableQty ? "%" : ingModalRoot.qtyUnit, null, null);
                                    }
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 54
                                Layout.preferredHeight: 24
                                color: "#0c2847"
                                border.color: "#1d5b94"
                                border.width: 1
                                radius: 3

                                Text {
                                    anchors.centerIn: parent
                                    text: ingModalRoot.isVariableQty ? "% / Rel" : ingModalRoot.qtyUnit
                                    color: "#38bdf8"
                                    font.bold: true
                                    font.pixelSize: 11
                                    font.family: "Segoe UI"
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.IBeamCursor
                            onClicked: {
                                textKeyboard.visible = false;
                                qtyInput.forceActiveFocus();
                                numpadModal.openForInput(qtyInput, "QUANTITY", ingModalRoot.isVariableQty ? "%" : ingModalRoot.qtyUnit, null, null);
                            }
                        }
                    }
                }
            }

            // =================================================================
            // ROW 3: CHARGING & DISPERSION INSTRUCTIONS
            // =================================================================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "CHARGING / DISPERSION INSTRUCTIONS"
                    color: "#cbd5e1"
                    font.pixelSize: 11
                    font.bold: true
                    font.family: "Segoe UI"
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    color: "#081d33"
                    border.color: isaInput.activeFocus ? "#38bdf8" : "#1d5b94"
                    border.width: 1
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 8

                        Text {
                            text: "📝"
                            font.pixelSize: 13
                        }

                        TextInput {
                            id: isaInput
                            Layout.fillWidth: true
                            verticalAlignment: TextInput.AlignVCenter
                            text: ingModalRoot.isaParameters
                            color: "#ffffff"
                            font.pixelSize: 12
                            font.family: "Segoe UI"
                            selectByMouse: true
                            inputMethodHints: Qt.ImhNone
                            onTextChanged: ingModalRoot.isaParameters = text
                            onActiveFocusChanged: {
                                if (activeFocus) {
                                    numpadModal.visible = false;
                                    textKeyboard.openFor(isaInput, "CHARGING INSTRUCTIONS");
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.IBeamCursor
                        onClicked: {
                            numpadModal.visible = false;
                            isaInput.forceActiveFocus();
                            textKeyboard.openFor(isaInput, "CHARGING INSTRUCTIONS");
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // =================================================================
            // BOTTOM ACTION BUTTONS
            // =================================================================
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Item { Layout.fillWidth: true }

                Rectangle {
                    Layout.preferredWidth: 110
                    Layout.preferredHeight: 38
                    radius: 4
                    color: cancelMouse.containsMouse ? "#334155" : "#1e293b"
                    border.color: "#475569"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 13
                        font.family: "Segoe UI"
                    }

                    MouseArea {
                        id: cancelMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            numpadModal.visible = false;
                            textKeyboard.visible = false;
                            ingModalRoot.cancelled();
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 170
                    Layout.preferredHeight: 38
                    radius: 4
                    color: confirmMouse.containsMouse ? "#16a34a" : "#15803d"
                    border.color: "#4ade80"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: ingModalRoot.mode === "DUPLICATE" ? "DUPLICATE ROW" : (ingModalRoot.mode === "EDIT" ? "SAVE CHANGES" : "ADD INGREDIENT")
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 13
                            font.family: "Segoe UI"
                        }
                        Text {
                            text: "✓"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 14
                        }
                    }

                    MouseArea {
                        id: confirmMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            numpadModal.visible = false;
                            textKeyboard.visible = false;
                            var cleanPhase = ingModalRoot.phase.trim() || "1";
                            var rawQty = parseFloat(ingModalRoot.qtyValue) || 1.0;
                            var unit = ingModalRoot.qtyUnit || "kg";
                            var formattedQty = ingModalRoot.isVariableQty
                                ? (ingModalRoot.formulaText.trim() || (rawQty + "%"))
                                : (rawQty + " " + unit);
                            var formattedIsa = ingModalRoot.isaParameters.trim() || "Take in vessel and agitate.";

                            var data = {
                                srNo: ingModalRoot.srNo,
                                name: ingModalRoot.ingredientName.trim() || "Raw Material",
                                phase: "Phase " + cleanPhase.replace(/^Phase\s*/i, ""),
                                phaseCode: cleanPhase.replace(/^Phase\s*/i, ""),
                                qty: formattedQty,
                                qtyValue: rawQty,
                                qtyUnit: unit,
                                isVariable: ingModalRoot.isVariableQty,
                                formulaText: ingModalRoot.formulaText,
                                isa: formattedIsa,
                                isaParameters: formattedIsa
                            };
                            ingModalRoot.accepted(data);
                        }
                    }
                }
            }
        }
    }

    // Modular Numeric Value Putter
    NumericKeypadModal {
        id: numpadModal
        anchors.fill: parent
        z: 9999
        visible: false
    }

    // Modular Full-Size QWERTY Text Keyboard
    ScadaTextKeyboard {
        id: textKeyboard
        z: 9999
        visible: false
    }
}
