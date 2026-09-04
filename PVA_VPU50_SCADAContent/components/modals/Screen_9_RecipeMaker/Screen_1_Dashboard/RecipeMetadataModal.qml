pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../../../widgets"
import "../../../widgets/ScadaKeyboard"
import "../.."

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
    property string shelfLifeMonths: "24"
    property string qtyType: "Fixed" // "Fixed" or "Variable"
    property string batchSizeKg: "100.0"
    property string targetDensity: "1020"
    property string description: "High-shear de-aerated barrier formulation with vacuum homogenization."
    property string authorName: "Suresh"
    property string currentUserRole: "Supervisor (Level 2)"
    property int currentUserLevel: 2
    property int version: 1

    signal saveAndNext(var metadata)
    signal cancelled

    onVisibleChanged: {
        if (visible) {
            // Clean shelfLife string to numeric value for input
            var cleanShelf = metaModalRoot.shelfLifeMonths.replace(/\s*Months?/i, "").trim();
            if (cleanShelf === "") cleanShelf = "24";

            titleInput.text = metaModalRoot.recipeTitle;
            prodNameInput.text = metaModalRoot.productName;
            shelfInput.text = cleanShelf;
            batchInput.text = metaModalRoot.batchSizeKg;
            densityInput.text = metaModalRoot.targetDensity;
            descInput.text = metaModalRoot.description;
            authorInput.text = metaModalRoot.authorName;
        } else {
            if (numpadModal.visible) numpadModal.visible = false;
            if (textKeyboard.visible) textKeyboard.visible = false;
        }
    }

    function loadMetadata(data, isEdit) {
        mode = isEdit ? "EDIT" : "NEW";
        recipeId = data.recipeId || (isEdit ? "REC-VPU50-EDIT" : "REC-VPU50-NEW");
        recipeTitle = data.title || (isEdit ? "" : "New Formulation Recipe");
        productName = data.productName || (isEdit ? "" : "Product Batch");
        productType = data.productType || "Emulsion / Cream";
        
        var rawShelf = data.shelfLife || "24";
        var cleanShelf = String(rawShelf).replace(/\s*Months?/i, "").trim();
        shelfLifeMonths = cleanShelf || "24";

        qtyType = data.qtyType || "Fixed";
        batchSizeKg = data.batchSizeKg !== undefined ? String(data.batchSizeKg) : "100.0";
        targetDensity = data.density !== undefined ? String(data.density) : (data.targetDensity !== undefined ? String(data.targetDensity) : "1020");
        description = data.description || "";
        
        var cleanAuthor = data.author ? data.author.replace(/\s*\(.*?\)\s*$/, "").trim() : "";
        authorName = cleanAuthor || "Formulation Chemist";
        version = data.version || 1;

        titleInput.text = recipeTitle;
        prodNameInput.text = productName;
        shelfInput.text = shelfLifeMonths;
        batchInput.text = batchSizeKg;
        densityInput.text = targetDensity;
        descInput.text = description;
        authorInput.text = authorName;

        visible = true;
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
        width: 840
        height: 550
        color: "#0b2e52"
        border.color: "#38bdf8"
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
                text: "X"
                color: closeMouse.containsMouse ? "#ffffff" : "#94a3b8"
                font.pixelSize: 12
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
                    metaModalRoot.cancelled();
                }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8

            // =================================================================
            // HEADER BAR
            // =================================================================
            RowLayout {
                Layout.fillWidth: true
                Layout.rightMargin: 36 // Space for close button
                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 34
                    Layout.preferredHeight: 34
                    radius: 5
                    color: "#081d33"
                    border.color: "#38bdf8"
                    border.width: 1

                    ScadaIcon {
                        anchors.centerIn: parent
                        Layout.preferredWidth: 18
                        Layout.preferredHeight: 18
                        iconName: "recipe_maker"
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1
                    Text {
                        text: metaModalRoot.mode === "NEW" ? "NEW MASTER RECIPE - SPECIFICATION CONFIGURATION" : "EDIT RECIPE SPECIFICATION & METADATA"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 13
                        font.family: "Segoe UI"
                    }
                    Text {
                        text: "ISA-88 Batch Master Recipe Authoring & Process Standards Engine"
                        color: "#94a3b8"
                        font.pixelSize: 10
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
            // ROW 1: RECIPE TITLE & PRODUCT NAME (50% / 50% Symmetry)
            // =================================================================
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // Recipe Title (50% Width)
                ColumnLayout {
                    Layout.preferredWidth: 395
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
                        Layout.preferredHeight: 32
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
                            inputMethodHints: Qt.ImhNone
                            onTextChanged: metaModalRoot.recipeTitle = text
                            onActiveFocusChanged: if (activeFocus) textKeyboard.openFor(titleInput, "RECIPE TITLE")
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.IBeamCursor
                            onClicked: {
                                titleInput.forceActiveFocus();
                                textKeyboard.openFor(titleInput, "RECIPE TITLE");
                            }
                        }
                    }
                }

                // Product Name (50% Width)
                ColumnLayout {
                    Layout.preferredWidth: 395
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
                        Layout.preferredHeight: 32
                        color: "#081d33"
                        border.color: prodNameInput.activeFocus ? "#38bdf8" : "#1d5b94"
                        border.width: 1
                        radius: 4

                        TextInput {
                            id: prodNameInput
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            verticalAlignment: TextInput.AlignVCenter
                            text: metaModalRoot.productName
                            color: "#ffffff"
                            font.pixelSize: 12
                            font.bold: true
                            font.family: "Segoe UI"
                            selectByMouse: true
                            inputMethodHints: Qt.ImhNone
                            onTextChanged: metaModalRoot.productName = text
                            onActiveFocusChanged: if (activeFocus) textKeyboard.openFor(prodNameInput, "PRODUCT NAME")
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.IBeamCursor
                            onClicked: {
                                prodNameInput.forceActiveFocus();
                                textKeyboard.openFor(prodNameInput, "PRODUCT NAME");
                            }
                        }
                    }
                }
            }

            // =================================================================
            // ROW 2A (TOP SECTOR): Product Type Row 1 (Left) & Shelf Life (Right)
            // Height of Left and Right is IDENTICAL (32px), perfectly aligned!
            // =================================================================
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // Left: Product Type Label + Buttons [Emulsion / Cream] & [Ointment]
                ColumnLayout {
                    Layout.preferredWidth: 395
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
                        spacing: 6

                        Rectangle {
                            id: btnEmulsion
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            radius: 4
                            color: metaModalRoot.productType === "Emulsion / Cream" ? "#0284c7" : (mEmulsion.containsMouse ? "#0f365d" : "#081d33")
                            border.color: metaModalRoot.productType === "Emulsion / Cream" ? "#38bdf8" : (mEmulsion.containsMouse ? "#2563eb" : "#1d5b94")
                            border.width: metaModalRoot.productType === "Emulsion / Cream" ? 2 : 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Text { text: "🧴"; font.pixelSize: 12 }
                                Text {
                                    text: "Emulsion / Cream"
                                    color: metaModalRoot.productType === "Emulsion / Cream" ? "#ffffff" : "#cbd5e1"
                                    font.pixelSize: 11
                                    font.bold: metaModalRoot.productType === "Emulsion / Cream"
                                    font.family: "Segoe UI"
                                }
                            }
                            MouseArea {
                                id: mEmulsion
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: metaModalRoot.productType = "Emulsion / Cream"
                            }
                        }

                        Rectangle {
                            id: btnOintment
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            radius: 4
                            color: metaModalRoot.productType === "Ointment" ? "#0284c7" : (mOintment.containsMouse ? "#0f365d" : "#081d33")
                            border.color: metaModalRoot.productType === "Ointment" ? "#38bdf8" : (mOintment.containsMouse ? "#2563eb" : "#1d5b94")
                            border.width: metaModalRoot.productType === "Ointment" ? 2 : 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Text { text: "🧴"; font.pixelSize: 12 }
                                Text {
                                    text: "Ointment"
                                    color: metaModalRoot.productType === "Ointment" ? "#ffffff" : "#cbd5e1"
                                    font.pixelSize: 11
                                    font.bold: metaModalRoot.productType === "Ointment"
                                    font.family: "Segoe UI"
                                }
                            }
                            MouseArea {
                                id: mOintment
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: metaModalRoot.productType = "Ointment"
                            }
                        }
                    }
                }

                // Right: Shelf Life Label + Compact Input Box [ ⏱ 24 Months ]
                ColumnLayout {
                    Layout.preferredWidth: 395
                    Layout.fillWidth: true
                    spacing: 3

                    Text {
                        text: "SHELF LIFE / EXPIRY DURATION *"
                        color: "#cbd5e1"
                        font.pixelSize: 10
                        font.bold: true
                        font.family: "Segoe UI"
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        color: "#081d33"
                        border.color: shelfInput.activeFocus ? "#38bdf8" : "#1d5b94"
                        border.width: 1
                        radius: 4

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 6

                            Text {
                                text: "⏱"
                                font.pixelSize: 12
                            }

                            TextInput {
                                id: shelfInput
                                Layout.fillWidth: true
                                verticalAlignment: TextInput.AlignVCenter
                                text: metaModalRoot.shelfLifeMonths
                                color: "#ffffff"
                                font.pixelSize: 12
                                font.bold: true
                                font.family: "Segoe UI"
                                selectByMouse: true
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                onTextChanged: metaModalRoot.shelfLifeMonths = text
                                onActiveFocusChanged: if (activeFocus) numpadModal.openForInput(shelfInput, "SHELF LIFE", "Months", null, null)
                            }

                            Text {
                                text: "Months"
                                color: "#94a3b8"
                                font.pixelSize: 10
                                font.bold: true
                                font.family: "Segoe UI"
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.IBeamCursor
                            onClicked: {
                                shelfInput.forceActiveFocus();
                                numpadModal.openForInput(shelfInput, "SHELF LIFE", "Months", null, null);
                            }
                        }
                    }
                }
            }

            // =================================================================
            // ROW 2B (BOTTOM SECTOR): Product Type Row 2 (Left) & Batch Size + Density (Right)
            // Top Labels align, Bottom Input Boxes align at EXACTLY 32px height!
            // =================================================================
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // Left: Secondary Forms Label + Buttons [Gel] & [Solution]
                ColumnLayout {
                    Layout.preferredWidth: 395
                    Layout.fillWidth: true
                    spacing: 3

                    Text {
                        text: " " // Matches right column label height for 100% horizontal seam alignment
                        font.pixelSize: 10
                        font.family: "Segoe UI"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Rectangle {
                            id: btnGel
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            radius: 4
                            color: metaModalRoot.productType === "Gel" ? "#0284c7" : (mGel.containsMouse ? "#0f365d" : "#081d33")
                            border.color: metaModalRoot.productType === "Gel" ? "#38bdf8" : (mGel.containsMouse ? "#2563eb" : "#1d5b94")
                            border.width: metaModalRoot.productType === "Gel" ? 2 : 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Text { text: "💧"; font.pixelSize: 12 }
                                Text {
                                    text: "Gel"
                                    color: metaModalRoot.productType === "Gel" ? "#ffffff" : "#cbd5e1"
                                    font.pixelSize: 11
                                    font.bold: metaModalRoot.productType === "Gel"
                                    font.family: "Segoe UI"
                                }
                            }
                            MouseArea {
                                id: mGel
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: metaModalRoot.productType = "Gel"
                            }
                        }

                        Rectangle {
                            id: btnSolution
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            radius: 4
                            color: metaModalRoot.productType === "Solution" ? "#0284c7" : (mSolution.containsMouse ? "#0f365d" : "#081d33")
                            border.color: metaModalRoot.productType === "Solution" ? "#38bdf8" : (mSolution.containsMouse ? "#2563eb" : "#1d5b94")
                            border.width: metaModalRoot.productType === "Solution" ? 2 : 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Text { text: "🧪"; font.pixelSize: 12 }
                                Text {
                                    text: "Solution"
                                    color: metaModalRoot.productType === "Solution" ? "#ffffff" : "#cbd5e1"
                                    font.pixelSize: 11
                                    font.bold: metaModalRoot.productType === "Solution"
                                    font.family: "Segoe UI"
                                }
                            }
                            MouseArea {
                                id: mSolution
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: metaModalRoot.productType = "Solution"
                            }
                        }
                    }
                }

                // Right: Batch Size & Density Side-by-Side (2 Equal Columns)
                RowLayout {
                    Layout.preferredWidth: 395
                    Layout.fillWidth: true
                    spacing: 8

                    // Batch Size (kg)
                    ColumnLayout {
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
                            Layout.preferredHeight: 32
                            color: "#081d33"
                            border.color: batchInput.activeFocus ? "#38bdf8" : "#1d5b94"
                            border.width: 1
                            radius: 4

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 6
                                spacing: 4

                                TextInput {
                                    id: batchInput
                                    Layout.fillWidth: true
                                    verticalAlignment: TextInput.AlignVCenter
                                    text: metaModalRoot.batchSizeKg
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    font.bold: true
                                    font.family: "Segoe UI"
                                    selectByMouse: true
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextChanged: metaModalRoot.batchSizeKg = text
                                    onActiveFocusChanged: if (activeFocus) numpadModal.openForInput(batchInput, "BATCH SIZE", "kg", null, null)
                                }

                                Text {
                                    text: "kg"
                                    color: "#94a3b8"
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.IBeamCursor
                                onClicked: {
                                    batchInput.forceActiveFocus();
                                    numpadModal.openForInput(batchInput, "BATCH SIZE", "kg", null, null);
                                }
                            }
                        }
                    }

                    // Density (kg/m³)
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        Text {
                            text: "DENSITY (kg/m³) *"
                            color: "#cbd5e1"
                            font.pixelSize: 10
                            font.bold: true
                            font.family: "Segoe UI"
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            color: "#081d33"
                            border.color: densityInput.activeFocus ? "#38bdf8" : "#1d5b94"
                            border.width: 1
                            radius: 4

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 6
                                spacing: 4

                                TextInput {
                                    id: densityInput
                                    Layout.fillWidth: true
                                    verticalAlignment: TextInput.AlignVCenter
                                    text: metaModalRoot.targetDensity
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    font.family: "Segoe UI"
                                    selectByMouse: true
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextChanged: metaModalRoot.targetDensity = text
                                    onActiveFocusChanged: if (activeFocus) numpadModal.openForInput(densityInput, "DENSITY", "kg/m³", null, null)
                                }

                                Text {
                                    text: "kg/m³"
                                    color: "#94a3b8"
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.IBeamCursor
                                onClicked: {
                                    densityInput.forceActiveFocus();
                                    numpadModal.openForInput(densityInput, "DENSITY", "kg/m³", null, null);
                                }
                            }
                        }
                    }
                }
            }

            // =================================================================
            // ROW 3: AUTHOR NAME (Left 50%) & QTY CALCULATION MODE (Right 50%)
            // =================================================================
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // Author / Creator Name Input + Dynamic Current Logged-in Level (Left 50%)
                ColumnLayout {
                    Layout.preferredWidth: 395
                    Layout.fillWidth: true
                    spacing: 3
                    RowLayout {
                        spacing: 6
                        Text {
                            text: "AUTHOR / CREATOR NAME *"
                            color: "#fbbf24"
                            font.pixelSize: 10
                            font.bold: true
                            font.family: "Segoe UI"
                        }
                        Text {
                            text: "(e.g. Suresh / Mahesh)"
                            color: "#94a3b8"
                            font.pixelSize: 9
                            font.family: "Segoe UI"
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        color: "#081d33"
                        border.color: authorInput.activeFocus ? "#fbbf24" : "#1d5b94"
                        border.width: 1
                        radius: 4

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 6

                            ScadaIcon {
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 16
                                iconName: "user"
                            }

                            TextInput {
                                id: authorInput
                                Layout.fillWidth: true
                                verticalAlignment: TextInput.AlignVCenter
                                text: metaModalRoot.authorName
                                color: "#ffffff"
                                font.pixelSize: 11
                                font.bold: true
                                font.family: "Segoe UI"
                                selectByMouse: true
                                inputMethodHints: Qt.ImhNone
                                onTextChanged: metaModalRoot.authorName = text
                                onActiveFocusChanged: if (activeFocus) textKeyboard.openFor(authorInput, "AUTHOR / CREATOR NAME")
                            }

                            // Dynamic Logged-in Role Level Badge (Without duplicated outer brackets)
                            Rectangle {
                                Layout.preferredHeight: 20
                                Layout.preferredWidth: roleBadgeTxt.implicitWidth + 8
                                radius: 3
                                color: "#1e3a8a"
                                border.color: "#3b82f6"
                                border.width: 1

                                Text {
                                    id: roleBadgeTxt
                                    anchors.centerIn: parent
                                    text: metaModalRoot.currentUserRole
                                    color: "#93c5fd"
                                    font.bold: true
                                    font.pixelSize: 9
                                    font.family: "Segoe UI"
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.IBeamCursor
                            onClicked: {
                                authorInput.forceActiveFocus();
                                textKeyboard.openFor(authorInput, "AUTHOR / CREATOR NAME");
                            }
                        }
                    }
                }

                // Quantity Calculation Mode Toggle (Right 50%)
                ColumnLayout {
                    Layout.preferredWidth: 395
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
                            Layout.preferredHeight: 32
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
                            Layout.preferredHeight: 32
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
            }

            // =================================================================
            // ROW 4: RECIPE DESCRIPTION / PROCESS SUMMARY (Full Width, 2-Row Height ~54px)
            // =================================================================
            ColumnLayout {
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
                    Layout.preferredHeight: 54
                    color: "#081d33"
                    border.color: descInput.activeFocus ? "#38bdf8" : "#1d5b94"
                    border.width: 1
                    radius: 4

                    Flickable {
                        anchors.fill: parent
                        anchors.margins: 6
                        contentWidth: width
                        contentHeight: descInput.paintedHeight
                        clip: true

                        TextEdit {
                            id: descInput
                            width: parent.width
                            text: metaModalRoot.description
                            color: "#ffffff"
                            font.pixelSize: 11
                            font.family: "Segoe UI"
                            wrapMode: TextEdit.Wrap
                            selectByMouse: true
                            onTextChanged: metaModalRoot.description = text
                            onActiveFocusChanged: if (activeFocus) textKeyboard.openFor(descInput, "RECIPE DESCRIPTION")
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.IBeamCursor
                        onClicked: {
                            descInput.forceActiveFocus();
                            textKeyboard.openFor(descInput, "RECIPE DESCRIPTION");
                        }
                    }
                }
            }

            // Bottom Context Notice
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 26
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
                        font.pixelSize: 12
                    }
                    Text {
                        text: metaModalRoot.qtyType === "Fixed"
                              ? "FIXED MODE: Formulation steps accept absolute weights (e.g. 50.0 kg, 9.2 kg)."
                              : "VARIABLE MODE: Formulation allows relational formulas (e.g. '3.45% of Phase A Glycerine')."
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
            // BOTTOM ACTION BUTTONS
            // =================================================================
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

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
                        onClicked: {
                            numpadModal.visible = false;
                            textKeyboard.visible = false;
                            metaModalRoot.cancelled();
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 160
                    Layout.preferredHeight: 36
                    radius: 4
                    color: nextMouse.containsMouse ? "#0369a1" : "#0284c7"
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
                            numpadModal.visible = false;
                            textKeyboard.visible = false;
                            var cleanName = metaModalRoot.authorName.trim() || "Author";
                            var rolePart = metaModalRoot.currentUserRole ? (" (" + metaModalRoot.currentUserRole + ")") : "";
                            var computedAuthor = cleanName + rolePart;
                            var cleanShelf = metaModalRoot.shelfLifeMonths.trim() || "24";
                            var formattedShelf = cleanShelf + " Months";

                            var data = {
                                id: metaModalRoot.recipeId,
                                title: metaModalRoot.recipeTitle,
                                productName: metaModalRoot.productName,
                                productType: metaModalRoot.productType,
                                shelfLife: formattedShelf,
                                qtyType: metaModalRoot.qtyType,
                                batchSizeKg: parseFloat(metaModalRoot.batchSizeKg) || 100.0,
                                targetDensity: parseFloat(metaModalRoot.targetDensity) || 1020.0,
                                description: metaModalRoot.description,
                                author: computedAuthor,
                                version: metaModalRoot.version
                            };
                            metaModalRoot.saveAndNext(data);
                        }
                    }
                }
            }
        }
    }

    // Modular Numeric Value Putter (Same as Control Screen)
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
