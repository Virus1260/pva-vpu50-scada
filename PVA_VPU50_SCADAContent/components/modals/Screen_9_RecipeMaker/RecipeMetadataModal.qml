pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../../widgets"

Rectangle {
    id: metaModalRoot
    implicitWidth: 1024
    implicitHeight: 600
    color: "#bb000000"
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
    property string author: "Process Incharge"
    property int version: 1

    signal saveAndNext(var metadata)
    signal cancelled

    MouseArea {
        anchors.fill: parent
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: 620
        height: 520
        color: "#0b2e52"
        border.color: "#38bdf8"
        border.width: 2
        radius: 8

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            // Top Header Bar
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                ScadaIcon {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    iconName: "recipe_maker"
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: metaModalRoot.mode === "NEW" ? "NEW MASTER RECIPE - METADATA CONFIGURATION" : "EDIT RECIPE METADATA & COMPLIANCE"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 14
                    }
                    Text {
                        text: "ISA-88 Batch Model & 21 CFR Part 11 / GAMP-5 Lifecycle Engine"
                        color: "#94a3b8"
                        font.pixelSize: 11
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    radius: 4
                    color: closeMouse.containsMouse ? "#ef4444" : "#0d365e"
                    border.color: "#1d5b94"
                    border.width: 1

                    ScadaIcon {
                        anchors.centerIn: parent
                        Layout.preferredWidth: 14
                        Layout.preferredHeight: 14
                        iconName: "close_x"
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: metaModalRoot.cancelled()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#1d5b94"
            }

            // Form Fields Grid
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 14
                rowSpacing: 10

                // Field 1: Recipe Title
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text {
                        text: "RECIPE TITLE *"
                        color: "#38bdf8"
                        font.pixelSize: 11
                        font.bold: true
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
                            anchors.margins: 8
                            text: metaModalRoot.recipeTitle
                            color: "#ffffff"
                            font.pixelSize: 12
                            font.bold: true
                            selectByMouse: true
                            onTextChanged: metaModalRoot.recipeTitle = text
                        }
                    }
                }

                // Field 2: Product Name
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text {
                        text: "PRODUCT NAME *"
                        color: "#38bdf8"
                        font.pixelSize: 11
                        font.bold: true
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
                            anchors.margins: 8
                            text: metaModalRoot.productName
                            color: "#ffffff"
                            font.pixelSize: 12
                            selectByMouse: true
                            onTextChanged: metaModalRoot.productName = text
                        }
                    }
                }

                // Field 3: Product Type
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text {
                        text: "PRODUCT TYPE / DOSAGE FORM"
                        color: "#cbd5e1"
                        font.pixelSize: 11
                        font.bold: true
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Repeater {
                            model: ["Emulsion / Cream", "Ointment", "Gel", "Solution"]
                            delegate: Rectangle {
                                id: typeBtn
                                required property string modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: 32
                                radius: 4
                                color: metaModalRoot.productType === typeBtn.modelData ? "#164e85" : "#081d33"
                                border.color: metaModalRoot.productType === typeBtn.modelData ? "#38bdf8" : "#1d5b94"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: typeBtn.modelData
                                    color: metaModalRoot.productType === typeBtn.modelData ? "#ffffff" : "#94a3b8"
                                    font.pixelSize: 10
                                    font.bold: metaModalRoot.productType === typeBtn.modelData
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: metaModalRoot.productType = typeBtn.modelData
                                }
                            }
                        }
                    }
                }

                // Field 4: Shelf Life / Expiry (Mandatory for Pharma / Cosmetic compliance)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text {
                        text: "SHELF LIFE / EXPIRY (21 CFR COMPLIANT) *"
                        color: "#cbd5e1"
                        font.pixelSize: 11
                        font.bold: true
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Repeater {
                            model: ["12 Months", "24 Months", "36 Months", "48 Months"]
                            delegate: Rectangle {
                                id: shelfBtn
                                required property string modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: 32
                                radius: 4
                                color: metaModalRoot.shelfLifeMonths === shelfBtn.modelData ? "#065f46" : "#081d33"
                                border.color: metaModalRoot.shelfLifeMonths === shelfBtn.modelData ? "#34d399" : "#1d5b94"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: shelfBtn.modelData
                                    color: metaModalRoot.shelfLifeMonths === shelfBtn.modelData ? "#ffffff" : "#94a3b8"
                                    font.pixelSize: 10
                                    font.bold: metaModalRoot.shelfLifeMonths === shelfBtn.modelData
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: metaModalRoot.shelfLifeMonths = shelfBtn.modelData
                                }
                            }
                        }
                    }
                }

                // Field 5: Quantity Type Toggle (Fixed vs Variable)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text {
                        text: "QUANTITY TYPE TOGGLE *"
                        color: "#38bdf8"
                        font.pixelSize: 11
                        font.bold: true
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Rectangle {
                            id: fixedToggle
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            radius: 4
                            color: metaModalRoot.qtyType === "Fixed" ? "#0284c7" : "#081d33"
                            border.color: metaModalRoot.qtyType === "Fixed" ? "#38bdf8" : "#1d5b94"
                            border.width: 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 4
                                Text {
                                    text: "● Fixed (Absolute kg/L)"
                                    color: "#ffffff"
                                    font.pixelSize: 11
                                    font.bold: metaModalRoot.qtyType === "Fixed"
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
                            border.width: 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 4
                                Text {
                                    text: "● Variable (Formulas & %)"
                                    color: "#ffffff"
                                    font.pixelSize: 11
                                    font.bold: metaModalRoot.qtyType === "Variable"
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

                // Field 6: Batch Size & Target Density
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Text {
                            text: "BATCH SIZE (kg)"
                            color: "#cbd5e1"
                            font.pixelSize: 11
                            font.bold: true
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            color: "#081d33"
                            border.color: "#1d5b94"
                            border.width: 1
                            radius: 4
                            TextInput {
                                anchors.fill: parent
                                anchors.margins: 8
                                text: metaModalRoot.batchSizeKg
                                color: "#ffffff"
                                font.pixelSize: 12
                                selectByMouse: true
                                onTextChanged: metaModalRoot.batchSizeKg = text
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Text {
                            text: "DENSITY (g/mL)"
                            color: "#cbd5e1"
                            font.pixelSize: 11
                            font.bold: true
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            color: "#081d33"
                            border.color: "#1d5b94"
                            border.width: 1
                            radius: 4
                            TextInput {
                                anchors.fill: parent
                                anchors.margins: 8
                                text: metaModalRoot.targetDensity
                                color: "#ffffff"
                                font.pixelSize: 12
                                selectByMouse: true
                                onTextChanged: metaModalRoot.targetDensity = text
                            }
                        }
                    }
                }
            }

            // Explanatory Note on Quantity Type Logic
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: metaModalRoot.qtyType === "Fixed" ? "#082f49" : "#2e1065"
                border.color: metaModalRoot.qtyType === "Fixed" ? "#0284c7" : "#7c3aed"
                border.width: 1
                radius: 4

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 8
                    Text {
                        text: metaModalRoot.qtyType === "Fixed"
                              ? "ℹ FIXED MODE: All formulation rows will accept absolute weights (e.g. 50.0 kg, 9.2 kg)."
                              : "ℹ VARIABLE MODE: Formulation allows relational formulas (e.g. '3.45% of Phase A Glycerine' or dynamic RPMs based on total weight)."
                        color: metaModalRoot.qtyType === "Fixed" ? "#7dd3fc" : "#e9d5ff"
                        font.pixelSize: 11
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // Bottom Right Action Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

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
                        font.pixelSize: 12
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
                    Layout.preferredHeight: 38
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
