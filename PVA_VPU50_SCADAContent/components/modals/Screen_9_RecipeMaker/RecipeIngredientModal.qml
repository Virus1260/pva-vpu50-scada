pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../../widgets"

Rectangle {
    id: ingModalRoot
    implicitWidth: 1024
    implicitHeight: 600
    color: "#bb000000"
    visible: false
    z: 100

    property string mode: "ADD" // "ADD", "EDIT", or "DUPLICATE"
    property int srNo: 1
    property string ingredientName: ""
    property string phase: "A"
    property string qtyValue: "1.0"
    property string qtyUnit: "kg"
    property string formulaText: ""
    property string isaParameters: "Take in vessel and agitate."
    property string targetTemp: "80.0"
    property bool isVariableQty: false

    signal accepted(var data)
    signal cancelled

    MouseArea {
        anchors.fill: parent
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: 680
        height: 510
        color: "#0b2e52"
        border.color: ingModalRoot.mode === "DUPLICATE" ? "#f59e0b" : "#38bdf8"
        border.width: 2
        radius: 8

        // Top-Right Corner Close Button
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 14
            anchors.rightMargin: 14
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
                onClicked: ingModalRoot.cancelled()
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            // Header Row
            RowLayout {
                Layout.fillWidth: true
                Layout.rightMargin: 36 // Reserve space for top-right close button
                spacing: 10

                ScadaIcon {
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22
                    iconName: ingModalRoot.mode === "DUPLICATE" ? "duplicate" : "recipes_checklist"
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: ingModalRoot.mode === "DUPLICATE" ? "DUPLICATE INGREDIENT SPECIFICATION" : (ingModalRoot.mode === "EDIT" ? "EDIT FORMULATION INGREDIENT" : "ADD FORMULATION INGREDIENT")
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 13
                    }
                    Text {
                        text: "Formulation Sheet & ISA-88 Phase Tagging (21 CFR Part 11)"
                        color: "#94a3b8"
                        font.pixelSize: 11
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#1d5b94"
            }

            // Form Inputs
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 12
                rowSpacing: 10

                // Field 1: Ingredient Name
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                    spacing: 4
                    Text {
                        text: "INGREDIENT NAME (RAW MATERIAL) *"
                        color: "#38bdf8"
                        font.pixelSize: 11
                        font.bold: true
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        color: "#081d33"
                        border.color: nameInput.activeFocus ? "#38bdf8" : "#1d5b94"
                        border.width: 1
                        radius: 4

                        TextInput {
                            id: nameInput
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            verticalAlignment: TextInput.AlignVCenter
                            text: ingModalRoot.ingredientName
                            color: "#ffffff"
                            font.pixelSize: 12
                            font.bold: true
                            font.family: "Segoe UI"
                            selectByMouse: true
                            onTextChanged: ingModalRoot.ingredientName = text
                        }
                    }
                }

                // Field 2: Target Phase Selection
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text {
                        text: "FORMULATION PHASE *"
                        color: "#cbd5e1"
                        font.pixelSize: 11
                        font.bold: true
                        font.family: "Segoe UI"
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Repeater {
                            model: ["Phase A", "Phase B", "Phase C", "Phase D", "Phase E"]
                            delegate: Rectangle {
                                id: phaseBtn
                                required property string modelData
                                readonly property string pCode: phaseBtn.modelData.replace("Phase ", "")

                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                radius: 4
                                color: ingModalRoot.phase === phaseBtn.pCode ? "#164e85" : "#081d33"
                                border.color: ingModalRoot.phase === phaseBtn.pCode ? "#38bdf8" : "#1d5b94"
                                border.width: ingModalRoot.phase === phaseBtn.pCode ? 2 : 1

                                Text {
                                    anchors.centerIn: parent
                                    text: phaseBtn.pCode
                                    color: ingModalRoot.phase === phaseBtn.pCode ? "#ffffff" : "#94a3b8"
                                    font.pixelSize: 11
                                    font.bold: true
                                    font.family: "Segoe UI"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: ingModalRoot.phase = phaseBtn.pCode
                                }
                            }
                        }
                    }
                }

                // Field 3: Quantity & Units
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text {
                        text: ingModalRoot.isVariableQty ? "FORMULA / VARIABLE RATIO *" : "QUANTITY (ABSOLUTE) *"
                        color: "#38bdf8"
                        font.pixelSize: 11
                        font.bold: true
                        font.family: "Segoe UI"
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            color: "#081d33"
                            border.color: qtyInput.activeFocus ? "#38bdf8" : "#1d5b94"
                            border.width: 1
                            radius: 4

                            TextInput {
                                id: qtyInput
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                verticalAlignment: TextInput.AlignVCenter
                                text: ingModalRoot.isVariableQty ? ingModalRoot.formulaText : ingModalRoot.qtyValue
                                color: "#ffffff"
                                font.pixelSize: 12
                                font.family: "Segoe UI"
                                selectByMouse: true
                                onTextChanged: {
                                    if (ingModalRoot.isVariableQty) {
                                        ingModalRoot.formulaText = text;
                                    } else {
                                        ingModalRoot.qtyValue = text;
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 34
                            color: "#0c2847"
                            border.color: "#1d5b94"
                            border.width: 1
                            radius: 4

                            Text {
                                anchors.centerIn: parent
                                text: ingModalRoot.isVariableQty ? "% / Rel" : ingModalRoot.qtyUnit
                                color: "#cbd5e1"
                                font.bold: true
                                font.pixelSize: 11
                                font.family: "Segoe UI"
                            }
                        }
                    }
                }

                // Field 4: ISA Process Parameters / Temperature Note
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                    spacing: 4
                    Text {
                        text: "ISA PARAMETERS & CHARGING INSTRUCTIONS"
                        color: "#cbd5e1"
                        font.pixelSize: 11
                        font.bold: true
                        font.family: "Segoe UI"
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        color: "#081d33"
                        border.color: isaInput.activeFocus ? "#38bdf8" : "#1d5b94"
                        border.width: 1
                        radius: 4

                        TextInput {
                            id: isaInput
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            verticalAlignment: TextInput.AlignVCenter
                            text: ingModalRoot.isaParameters
                            color: "#ffffff"
                            font.pixelSize: 11
                            font.family: "Segoe UI"
                            selectByMouse: true
                            onTextChanged: ingModalRoot.isaParameters = text
                        }
                    }
                }
            }

            // Quick Preset Suggestions (From Body Lotion Formulation image_cf2be0.jpg)
            Text {
                text: "Quick Presets from Standard SOP Formulation Sheet:"
                color: "#94a3b8"
                font.pixelSize: 10
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: [
                        { label: "Heat till 80-85°C", text: "Take one by one in vessel. Heat till 80-85°C with anchor agitation." },
                        { label: "Add B in A @ 85°C", text: "Maintain temp at 80-85°C & add Phase B into Phase A. Continuous stirring." },
                        { label: "At 55°C Add C", text: "Cool batch to 55°C and charge Phase C slowly under vacuum." },
                        { label: "At 50°C Add D", text: "At 50°C add Phase D (Neutralizer Triethanolamine)." },
                        { label: "At 40-45°C Add E", text: "At 40-45°C add Phase E (Preservatives & Active fragrance)." }
                    ]
                    delegate: Rectangle {
                        id: presetChip
                        required property var modelData
                        Layout.preferredHeight: 24
                        Layout.preferredWidth: pTxt.implicitWidth + 12
                        radius: 12
                        color: chipMouse.containsMouse ? "#1e3a8a" : "#0d2b4d"
                        border.color: "#3b82f6"
                        border.width: 1

                        Text {
                            id: pTxt
                            anchors.centerIn: parent
                            text: presetChip.modelData.label
                            color: "#93c5fd"
                            font.pixelSize: 9
                        }

                        MouseArea {
                            id: chipMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ingModalRoot.isaParameters = presetChip.modelData.text
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // Bottom Buttons: Cancel & Confirm (Confirm text must say "COPY" if Duplicate mode!)
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Item { Layout.fillWidth: true }

                Rectangle {
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 36
                    radius: 4
                    color: cancelMouse.containsMouse ? "#334155" : "#1e293b"
                    border.color: "#475569"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 11
                    }

                    MouseArea {
                        id: cancelMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ingModalRoot.cancelled()
                    }
                }

                Rectangle {
                    id: confirmBtn
                    Layout.preferredWidth: 130
                    Layout.preferredHeight: 36
                    radius: 4
                    color: ingModalRoot.mode === "DUPLICATE" ? "#d97706" : (ingModalRoot.mode === "EDIT" ? "#0284c7" : "#059669")
                    border.color: ingModalRoot.mode === "DUPLICATE" ? "#fcd34d" : (ingModalRoot.mode === "EDIT" ? "#38bdf8" : "#34d399")
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            // Strictly per user directive: "Clicking Duplicate opens the ingredient popup, but the confirm button must say COPY instead of OK."
                            text: ingModalRoot.mode === "DUPLICATE" ? "COPY" : (ingModalRoot.mode === "EDIT" ? "SAVE CHANGES" : "ADD INGREDIENT")
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var data = {
                                srNo: ingModalRoot.srNo,
                                name: ingModalRoot.ingredientName.trim() || "New Ingredient",
                                phase: ingModalRoot.phase,
                                qty: ingModalRoot.isVariableQty ? (ingModalRoot.formulaText || "1.0%") : (ingModalRoot.qtyValue + " " + ingModalRoot.qtyUnit),
                                isa: ingModalRoot.isaParameters
                            };
                            ingModalRoot.accepted(data);
                        }
                    }
                }
            }
        }
    }
}
