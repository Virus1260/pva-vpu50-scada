pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../../widgets"

Rectangle {
    id: metaModalRoot
    implicitWidth: 1024
    implicitHeight: 600
    color: "#cc000000"
    visible: false
    z: 100

    property string mode: "NEW" // "NEW" or "EDIT"
    property string recipeId: "REC-VPU50-NEW"
    property string recipeTitle: "Body Lotion Formulation"
    property string productName: "Cosmetic Intensive Body Lotion"
    property string productType: "Emulsion / Cream"
    property string shelfLifeMonths: "24 Months"
    property string qtyType: "Fixed" // "Fixed" or "Variable"
    property string batchSizeKg: "100.0"
    property string targetDensity: "1.02"
    property string description: "High-shear de-aerated barrier formulation with vacuum homogenization."
    property string author: "QA Tech Leader (Level 2 - Supervisor)"
    property int version: 1

    signal saveAndNext(var metadata)
    signal cancelled

    MouseArea {
        anchors.fill: parent
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: 820
        height: 560
        color: "#0b2e52"
        border.color: "#38bdf8"
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
                onClicked: metaModalRoot.cancelled()
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8

            // =================================================================
            // 1. TOP HEADER BAR
            // =================================================================
            RowLayout {
                Layout.fillWidth: true
                Layout.rightMargin: 36 // Reserve space for top-right close button
                spacing: 12

                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: 6
                    color: "#081d33"
                    border.color: "#38bdf8"
                    border.width: 1

                    ScadaIcon {
                        anchors.centerIn: parent
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        iconName: "recipe_maker"
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: metaModalRoot.mode === "NEW" ? "NEW MASTER RECIPE - METADATA CONFIGURATION" : "EDIT RECIPE METADATA & COMPLIANCE"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 14
                        font.family: "Segoe UI"
                    }
                    Text {
                        text: "ISA-88 Batch Model & 21 CFR Part 11 / GAMP-5 Lifecycle Engine"
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
            // 2. FORM FIELDS
            // =================================================================

            // Row 1: Recipe Title & Product Name (2 Equal Columns)
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // Recipe Title
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3
                    Text {
                        text: "RECIPE TITLE *"
                        color: "#38bdf8"
                        font.pixelSize: 10
                        font.bold: true
                        font.family: "Segoe UI"
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        color: "#081d33"
                        border.color: titleInput.activeFocus ? "#38bdf8" : "#1d5b94"
                        border.width: 1
                        radius: 4

                        TextInput {
                            id: titleInput
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            verticalAlignment: TextInput.AlignVCenter
                            text: metaModalRoot.recipeTitle
                            color: "#ffffff"
                            font.pixelSize: 12
                            font.bold: true
                            font.family: "Segoe UI"
                            selectByMouse: true
                            onTextChanged: metaModalRoot.recipeTitle = text
                        }
                    }
                }

                // Product Name
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3
                    Text {
                        text: "PRODUCT NAME *"
                        color: "#38bdf8"
                        font.pixelSize: 10
                        font.bold: true
                        font.family: "Segoe UI"
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        color: "#081d33"
                        border.color: prodInput.activeFocus ? "#38bdf8" : "#1d5b94"
                        border.width: 1
                        radius: 4

                        TextInput {
                            id: prodInput
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            verticalAlignment: TextInput.AlignVCenter
                            text: metaModalRoot.productName
                            color: "#ffffff"
                            font.pixelSize: 12
                            font.family: "Segoe UI"
                            selectByMouse: true
                            onTextChanged: metaModalRoot.productName = text
                        }
                    }
                }
            }

            // Row 2: Product Type / Dosage Form (Full Width Row of 4 Spacious Pills)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                Text {
                    text: "PRODUCT TYPE / DOSAGE FORM *"
                    color: "#cbd5e1"
                    font.pixelSize: 10
                    font.bold: true
                    font.family: "Segoe UI"
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: [
                            { name: "Emulsion / Cream", icon: "🧪" },
                            { name: "Ointment", icon: "🧴" },
                            { name: "Gel", icon: "💧" },
                            { name: "Solution", icon: "🍶" }
                        ]
                        delegate: Rectangle {
                            id: typeBtn
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            radius: 4
                            color: metaModalRoot.productType === typeBtn.modelData.name ? "#164e85" : (typeMouse.containsMouse ? "#0f365d" : "#081d33")
                            border.color: metaModalRoot.productType === typeBtn.modelData.name ? "#38bdf8" : (typeMouse.containsMouse ? "#2563eb" : "#1d5b94")
                            border.width: metaModalRoot.productType === typeBtn.modelData.name ? 2 : 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Text {
                                    text: typeBtn.modelData.icon
                                    font.pixelSize: 12
                                }
                                Text {
                                    text: typeBtn.modelData.name
                                    color: metaModalRoot.productType === typeBtn.modelData.name ? "#ffffff" : "#cbd5e1"
                                    font.pixelSize: 11
                                    font.bold: metaModalRoot.productType === typeBtn.modelData.name
                                    font.family: "Segoe UI"
                                }
                            }

                            MouseArea {
                                id: typeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: metaModalRoot.productType = typeBtn.modelData.name
                            }
                        }
                    }
                }
            }

            // Row 3: Shelf Life / Expiry Duration (Full Width Row of 4 Compliant Pills)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                RowLayout {
                    spacing: 6
                    Text {
                        text: "SHELF LIFE / EXPIRY DURATION *"
                        color: "#cbd5e1"
                        font.pixelSize: 10
                        font.bold: true
                        font.family: "Segoe UI"
                    }
                    Rectangle {
                        Layout.preferredHeight: 16
                        Layout.preferredWidth: 100
                        radius: 2
                        color: "#064e3b"
                        Text {
                            anchors.centerIn: parent
                            text: "21 CFR COMPLIANT"
                            color: "#34d399"
                            font.bold: true
                            font.pixelSize: 8
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: ["12 Months", "24 Months", "36 Months", "48 Months"]
                        delegate: Rectangle {
                            id: shelfBtn
                            required property string modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            radius: 4
                            color: metaModalRoot.shelfLifeMonths === shelfBtn.modelData ? "#065f46" : (shelfMouse.containsMouse ? "#0f365d" : "#081d33")
                            border.color: metaModalRoot.shelfLifeMonths === shelfBtn.modelData ? "#34d399" : (shelfMouse.containsMouse ? "#059669" : "#1d5b94")
                            border.width: metaModalRoot.shelfLifeMonths === shelfBtn.modelData ? 2 : 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Text {
                                    text: metaModalRoot.shelfLifeMonths === shelfBtn.modelData ? "✓" : "⏱"
                                    color: metaModalRoot.shelfLifeMonths === shelfBtn.modelData ? "#34d399" : "#94a3b8"
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                                Text {
                                    text: shelfBtn.modelData
                                    color: metaModalRoot.shelfLifeMonths === shelfBtn.modelData ? "#ffffff" : "#cbd5e1"
                                    font.pixelSize: 11
                                    font.bold: metaModalRoot.shelfLifeMonths === shelfBtn.modelData
                                    font.family: "Segoe UI"
                                }
                            }

                            MouseArea {
                                id: shelfMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: metaModalRoot.shelfLifeMonths = shelfBtn.modelData
                            }
                        }
                    }
                }
            }

            // Row 4: Quantity Type Toggle & Batch Size & Density (3 Structured Columns)
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // Column 1: Quantity Mode Toggle (46% width)
                ColumnLayout {
                    Layout.preferredWidth: 340
                    Layout.fillWidth: true
                    spacing: 3
                    Text {
                        text: "QUANTITY CALCULATION MODE *"
                        color: "#38bdf8"
                        font.pixelSize: 10
                        font.bold: true
                        font.family: "Segoe UI"
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Rectangle {
                            id: fixedToggle
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            radius: 4
                            color: metaModalRoot.qtyType === "Fixed" ? "#0284c7" : "#081d33"
                            border.color: metaModalRoot.qtyType === "Fixed" ? "#38bdf8" : "#1d5b94"
                            border.width: metaModalRoot.qtyType === "Fixed" ? 2 : 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Text {
                                    text: metaModalRoot.qtyType === "Fixed" ? "●" : "○"
                                    color: metaModalRoot.qtyType === "Fixed" ? "#ffffff" : "#64748b"
                                    font.pixelSize: 10
                                }
                                Text {
                                    text: "Fixed (kg / L)"
                                    color: "#ffffff"
                                    font.pixelSize: 11
                                    font.bold: metaModalRoot.qtyType === "Fixed"
                                    font.family: "Segoe UI"
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: metaModalRoot.qtyType = "Fixed"
                            }
                        }

                        Rectangle {
                            id: varToggle
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            radius: 4
                            color: metaModalRoot.qtyType === "Variable" ? "#7c3aed" : "#081d33"
                            border.color: metaModalRoot.qtyType === "Variable" ? "#c084fc" : "#1d5b94"
                            border.width: metaModalRoot.qtyType === "Variable" ? 2 : 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Text {
                                    text: metaModalRoot.qtyType === "Variable" ? "●" : "○"
                                    color: metaModalRoot.qtyType === "Variable" ? "#ffffff" : "#64748b"
                                    font.pixelSize: 10
                                }
                                Text {
                                    text: "Variable (% / Form.)"
                                    color: "#ffffff"
                                    font.pixelSize: 11
                                    font.bold: metaModalRoot.qtyType === "Variable"
                                    font.family: "Segoe UI"
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: metaModalRoot.qtyType = "Variable"
                            }
                        }
                    }
                }

                // Column 2: Batch Size (27% width)
                ColumnLayout {
                    Layout.preferredWidth: 190
                    Layout.fillWidth: true
                    spacing: 3
                    Text {
                        text: "BATCH SIZE (kg) *"
                        color: "#cbd5e1"
                        font.pixelSize: 10
                        font.bold: true
                        font.family: "Segoe UI"
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        color: "#081d33"
                        border.color: batchInput.activeFocus ? "#38bdf8" : "#1d5b94"
                        border.width: 1
                        radius: 4
                        TextInput {
                            id: batchInput
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            verticalAlignment: TextInput.AlignVCenter
                            text: metaModalRoot.batchSizeKg
                            color: "#ffffff"
                            font.pixelSize: 12
                            font.bold: true
                            font.family: "Segoe UI"
                            selectByMouse: true
                            onTextChanged: metaModalRoot.batchSizeKg = text
                        }
                    }
                }

                // Column 3: Density (27% width)
                ColumnLayout {
                    Layout.preferredWidth: 190
                    Layout.fillWidth: true
                    spacing: 3
                    Text {
                        text: "DENSITY (g/mL) *"
                        color: "#cbd5e1"
                        font.pixelSize: 10
                        font.bold: true
                        font.family: "Segoe UI"
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        color: "#081d33"
                        border.color: densityInput.activeFocus ? "#38bdf8" : "#1d5b94"
                        border.width: 1
                        radius: 4
                        TextInput {
                            id: densityInput
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            verticalAlignment: TextInput.AlignVCenter
                            text: metaModalRoot.targetDensity
                            color: "#ffffff"
                            font.pixelSize: 12
                            font.family: "Segoe UI"
                            selectByMouse: true
                            onTextChanged: metaModalRoot.targetDensity = text
                        }
                    }
                }
            }

            // Row 5: Recipe Description & Author/Creator with User Role/Level in brackets
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // Description Input (58% width)
                ColumnLayout {
                    Layout.preferredWidth: 440
                    Layout.fillWidth: true
                    spacing: 3
                    Text {
                        text: "RECIPE DESCRIPTION / PROCESS SUMMARY *"
                        color: "#38bdf8"
                        font.pixelSize: 10
                        font.bold: true
                        font.family: "Segoe UI"
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        color: "#081d33"
                        border.color: descInput.activeFocus ? "#38bdf8" : "#1d5b94"
                        border.width: 1
                        radius: 4

                        TextInput {
                            id: descInput
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            verticalAlignment: TextInput.AlignVCenter
                            text: metaModalRoot.description
                            color: "#ffffff"
                            font.pixelSize: 11
                            font.family: "Segoe UI"
                            selectByMouse: true
                            onTextChanged: metaModalRoot.description = text
                        }
                    }
                }

                // Author / Creator with Logged-in Level in Brackets (42% width)
                ColumnLayout {
                    Layout.preferredWidth: 320
                    Layout.fillWidth: true
                    spacing: 3
                    Text {
                        text: "AUTHOR / CREATOR (LOGGED-IN LEVEL) *"
                        color: "#fbbf24"
                        font.pixelSize: 10
                        font.bold: true
                        font.family: "Segoe UI"
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        color: "#081d33"
                        border.color: authorInput.activeFocus ? "#fbbf24" : "#1d5b94"
                        border.width: 1
                        radius: 4

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 6

                            Text {
                                text: "👤"
                                font.pixelSize: 12
                            }

                            TextInput {
                                id: authorInput
                                Layout.fillWidth: true
                                verticalAlignment: TextInput.AlignVCenter
                                text: metaModalRoot.author
                                color: "#ffffff"
                                font.pixelSize: 11
                                font.bold: true
                                font.family: "Segoe UI"
                                selectByMouse: true
                                onTextChanged: metaModalRoot.author = text
                            }
                        }
                    }
                }
            }

            // Row 6: Explanatory Context Box for Quantity Mode
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                color: metaModalRoot.qtyType === "Fixed" ? "#082f49" : "#2e1065"
                border.color: metaModalRoot.qtyType === "Fixed" ? "#0284c7" : "#7c3aed"
                border.width: 1
                radius: 4

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8
                    Text {
                        text: "ℹ"
                        color: metaModalRoot.qtyType === "Fixed" ? "#38bdf8" : "#c084fc"
                        font.bold: true
                        font.pixelSize: 13
                    }
                    Text {
                        text: metaModalRoot.qtyType === "Fixed"
                              ? "FIXED MODE: All formulation rows will accept absolute weights (e.g. 50.0 kg, 9.2 kg)."
                              : "VARIABLE MODE: Formulation allows relational formulas (e.g. '3.45% of Phase A Glycerine' or dynamic speeds)."
                        color: metaModalRoot.qtyType === "Fixed" ? "#7dd3fc" : "#e9d5ff"
                        font.pixelSize: 10
                        font.family: "Segoe UI"
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // =================================================================
            // 3. BOTTOM ACTION BUTTONS
            // =================================================================
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: "🔒 21 CFR Part 11 Audit Trail & Version Control Enabled"
                    color: "#64748b"
                    font.pixelSize: 10
                    font.family: "Segoe UI"
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    Layout.preferredWidth: 110
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
                        font.pixelSize: 12
                        font.family: "Segoe UI"
                    }

                    MouseArea {
                        id: cancelMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: metaModalRoot.cancelled()
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 160
                    Layout.preferredHeight: 36
                    radius: 4
                    color: nextMouse.containsMouse ? "#0284c7" : "#0284c7"
                    border.color: "#38bdf8"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "Save & Next"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 13
                            font.family: "Segoe UI"
                        }
                        Text {
                            text: "→"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 15
                        }
                    }

                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var data = {
                                id: metaModalRoot.recipeId,
                                title: metaModalRoot.recipeTitle,
                                productName: metaModalRoot.productName,
                                productType: metaModalRoot.productType,
                                shelfLife: metaModalRoot.shelfLifeMonths,
                                qtyType: metaModalRoot.qtyType,
                                batchSizeKg: parseFloat(metaModalRoot.batchSizeKg) || 100.0,
                                targetDensity: parseFloat(metaModalRoot.targetDensity) || 1.0,
                                description: metaModalRoot.description,
                                author: metaModalRoot.author,
                                version: metaModalRoot.version
                            };
                            metaModalRoot.saveAndNext(data);
                        }
                    }
                }
            }
        }
    }
}
