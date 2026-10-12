pragma ComponentBehavior: Bound
// @disable-check M203  -- JavaScript functions are required QML runtime logic; DS visual editor advisory only
import QtQuick
import QtQuick.Layouts
import "../../../common"
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
    property int selectedPerspectiveTab: 0 // 0: Identity, 1: R&D CQA, 2: Process Dev CPP

    // Hassan Eldeeb Perspective 2: R&D Formulation (CQA - Critical Quality Attributes)
    property string minViscosityCp: "15000"
    property string maxViscosityCp: "25000"
    property string minPh: "5.50"
    property string maxPh: "6.50"
    property string totalSolidsPct: "18.5"
    property string dropletSizeMicrons: "2.5"

    // Hassan Eldeeb Perspective 3: Process Development Scale-Up (CPP - Critical Process Parameters)
    property string maxHeatingRateCpm: "2.5"
    property string maxCoolingRateCpm: "2.0"
    property string maxAdditionRateKpm: "4.5"
    property string maxHomogenizerRpm: "3000"
    property string maxVacuumBar: "-0.80"
    property string targetBctMinutes: "45.0"

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

            minViscInput.text = metaModalRoot.minViscosityCp;
            maxViscInput.text = metaModalRoot.maxViscosityCp;
            minPhInput.text = metaModalRoot.minPh;
            maxPhInput.text = metaModalRoot.maxPh;
            solidsInput.text = metaModalRoot.totalSolidsPct;
            dropletInput.text = metaModalRoot.dropletSizeMicrons;

            heatRateInput.text = metaModalRoot.maxHeatingRateCpm;
            coolRateInput.text = metaModalRoot.maxCoolingRateCpm;
            addRateInput.text = metaModalRoot.maxAdditionRateKpm;
            homoMaxInput.text = metaModalRoot.maxHomogenizerRpm;
            vacMaxInput.text = metaModalRoot.maxVacuumBar;
            bctTargetInput.text = metaModalRoot.targetBctMinutes;
        } else {
            if (numpadModal.visible) numpadModal.visible = false;
            if (textKeyboard.visible) textKeyboard.visible = false;
            if (modalContextMenu.active) modalContextMenu.closeMenu();
            if (modalLoupe.active) modalLoupe.active = false;
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

        minViscosityCp = data.minViscosityCp !== undefined ? String(data.minViscosityCp) : "15000";
        maxViscosityCp = data.maxViscosityCp !== undefined ? String(data.maxViscosityCp) : "25000";
        minPh = data.minPh !== undefined ? String(data.minPh) : "5.50";
        maxPh = data.maxPh !== undefined ? String(data.maxPh) : "6.50";
        totalSolidsPct = data.totalSolidsPct !== undefined ? String(data.totalSolidsPct) : "18.5";
        dropletSizeMicrons = data.dropletSizeMicrons !== undefined ? String(data.dropletSizeMicrons) : "2.5";

        maxHeatingRateCpm = data.maxHeatingRateCpm !== undefined ? String(data.maxHeatingRateCpm) : "2.5";
        maxCoolingRateCpm = data.maxCoolingRateCpm !== undefined ? String(data.maxCoolingRateCpm) : "2.0";
        maxAdditionRateKpm = data.maxAdditionRateKpm !== undefined ? String(data.maxAdditionRateKpm) : "4.5";
        maxHomogenizerRpm = data.maxHomogenizerRpm !== undefined ? String(data.maxHomogenizerRpm) : "3000";
        maxVacuumBar = data.maxVacuumBar !== undefined ? String(data.maxVacuumBar) : "-0.80";
        targetBctMinutes = data.targetBctMinutes !== undefined ? String(data.targetBctMinutes) : "45.0";

        titleInput.text = recipeTitle;
        prodNameInput.text = productName;
        shelfInput.text = shelfLifeMonths;
        batchInput.text = batchSizeKg;
        densityInput.text = targetDensity;
        descInput.text = description;
        authorInput.text = authorName;

        minViscInput.text = minViscosityCp;
        maxViscInput.text = maxViscosityCp;
        minPhInput.text = minPh;
        maxPhInput.text = maxPh;
        solidsInput.text = totalSolidsPct;
        dropletInput.text = dropletSizeMicrons;

        heatRateInput.text = maxHeatingRateCpm;
        coolRateInput.text = maxCoolingRateCpm;
        addRateInput.text = maxAdditionRateKpm;
        homoMaxInput.text = maxHomogenizerRpm;
        vacMaxInput.text = maxVacuumBar;
        bctTargetInput.text = targetBctMinutes;

        visible = true;
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (numpadModal.visible) numpadModal.visible = false;
            if (textKeyboard.visible) textKeyboard.visible = false;
            if (modalContextMenu.active) modalContextMenu.closeMenu();
            if (modalLoupe.active) modalLoupe.active = false;
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
            // HASSAN ELDEEB 3-PERSPECTIVE MANUFACTURING TABS
            // (1. General & Identity, 2. R&D Formulation CQA, 3. Process Dev Scale-Up CPP)
            // =================================================================
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // Tab 1: General & Identity
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    radius: 4
                    color: metaModalRoot.selectedPerspectiveTab === 0 ? "#0284c7" : "#081d33"
                    border.color: metaModalRoot.selectedPerspectiveTab === 0 ? "#38bdf8" : "#1d5b94"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Rectangle { width: 6; height: 6; radius: 3; color: metaModalRoot.selectedPerspectiveTab === 0 ? "#38bdf8" : "#64748b" }
                        Text {
                            text: "1. GENERAL & IDENTITY"
                            color: metaModalRoot.selectedPerspectiveTab === 0 ? "#ffffff" : "#94a3b8"
                            font.pixelSize: 10
                            font.bold: true
                            font.family: "Segoe UI"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: metaModalRoot.selectedPerspectiveTab = 0
                    }
                }

                // Tab 2: R&D Formulation (CQA)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    radius: 4
                    color: metaModalRoot.selectedPerspectiveTab === 1 ? "#0284c7" : "#081d33"
                    border.color: metaModalRoot.selectedPerspectiveTab === 1 ? "#38bdf8" : "#1d5b94"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Rectangle { width: 6; height: 6; radius: 3; color: metaModalRoot.selectedPerspectiveTab === 1 ? "#38bdf8" : "#64748b" }
                        Text {
                            text: "2. R&D FORMULATION (CQA)"
                            color: metaModalRoot.selectedPerspectiveTab === 1 ? "#ffffff" : "#94a3b8"
                            font.pixelSize: 10
                            font.bold: true
                            font.family: "Segoe UI"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: metaModalRoot.selectedPerspectiveTab = 1
                    }
                }

                // Tab 3: Process Development Scale-Up (CPP)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    radius: 4
                    color: metaModalRoot.selectedPerspectiveTab === 2 ? "#0284c7" : "#081d33"
                    border.color: metaModalRoot.selectedPerspectiveTab === 2 ? "#38bdf8" : "#1d5b94"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Rectangle { width: 6; height: 6; radius: 3; color: metaModalRoot.selectedPerspectiveTab === 2 ? "#38bdf8" : "#64748b" }
                        Text {
                            text: "3. PROCESS DEV SCALE-UP (CPP)"
                            color: metaModalRoot.selectedPerspectiveTab === 2 ? "#ffffff" : "#94a3b8"
                            font.pixelSize: 10
                            font.bold: true
                            font.family: "Segoe UI"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: metaModalRoot.selectedPerspectiveTab = 2
                    }
                }
            }

            // =================================================================
            // TAB 1: GENERAL & IDENTITY SECTION
            // =================================================================
            ColumnLayout {
                id: tabGeneralIdentity
                Layout.fillWidth: true
                visible: metaModalRoot.selectedPerspectiveTab === 0
                spacing: 8

                // Row 1: Recipe Title & Product Name (50% / 50% Symmetry)
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
                            anchors.rightMargin: 28
                            verticalAlignment: TextInput.AlignVCenter
                            text: metaModalRoot.recipeTitle
                            color: "#ffffff"
                            font.pixelSize: 12
                            font.bold: true
                            font.family: "Segoe UI"
                            selectByMouse: false
                            inputMethodHints: Qt.ImhNone
                            onTextChanged: metaModalRoot.recipeTitle = text
                        }

                        ScadaTouchInputHandler {
                            targetInput: titleInput
                            keyboard: textKeyboard
                            loupe: modalLoupe
                            contextMenu: modalContextMenu
                            title: "RECIPE TITLE"
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
                            anchors.rightMargin: 28
                            verticalAlignment: TextInput.AlignVCenter
                            text: metaModalRoot.productName
                            color: "#ffffff"
                            font.pixelSize: 12
                            font.bold: true
                            font.family: "Segoe UI"
                            selectByMouse: false
                            inputMethodHints: Qt.ImhNone
                            onTextChanged: metaModalRoot.productName = text
                        }

                        ScadaTouchInputHandler {
                            targetInput: prodNameInput
                            keyboard: textKeyboard
                            loupe: modalLoupe
                            contextMenu: modalContextMenu
                            title: "PRODUCT NAME"
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
                                Rectangle {
                                    width: 6
                                    height: 6
                                    radius: 3
                                    color: metaModalRoot.productType === "Emulsion / Cream" ? "#38bdf8" : "#64748b"
                                }
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
                                Rectangle {
                                    width: 6
                                    height: 6
                                    radius: 3
                                    color: metaModalRoot.productType === "Ointment" ? "#38bdf8" : "#64748b"
                                }
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

                // Right: Shelf Life Label + Compact Input Box [ 24 Months ]
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

                            ScadaIcon {
                                Layout.preferredWidth: 14
                                Layout.preferredHeight: 14
                                iconName: "clock"
                                iconColor: shelfInput.activeFocus ? "#38bdf8" : "#94a3b8"
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
                                selectByMouse: false
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                onTextChanged: metaModalRoot.shelfLifeMonths = text
                            }

                            Text {
                                text: "Months"
                                color: "#94a3b8"
                                font.pixelSize: 10
                                font.bold: true
                                font.family: "Segoe UI"
                            }
                        }

                        ScadaTouchInputHandler {
                            targetInput: shelfInput
                            numpad: numpadModal
                            loupe: modalLoupe
                            contextMenu: modalContextMenu
                            isNumeric: true
                            title: "SHELF LIFE"
                            unit: "Months"
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
                                Rectangle {
                                    width: 6
                                    height: 6
                                    radius: 3
                                    color: metaModalRoot.productType === "Gel" ? "#38bdf8" : "#64748b"
                                }
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
                                Rectangle {
                                    width: 6
                                    height: 6
                                    radius: 3
                                    color: metaModalRoot.productType === "Solution" ? "#38bdf8" : "#64748b"
                                }
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
                                    selectByMouse: false
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextChanged: metaModalRoot.batchSizeKg = text
                                }

                                Text {
                                    text: "kg"
                                    color: "#94a3b8"
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }

                            ScadaTouchInputHandler {
                                targetInput: batchInput
                                numpad: numpadModal
                                loupe: modalLoupe
                                contextMenu: modalContextMenu
                                isNumeric: true
                                title: "BATCH SIZE"
                                unit: "kg"
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
                                    selectByMouse: false
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    onTextChanged: metaModalRoot.targetDensity = text
                                }

                                Text {
                                    text: "kg/m³"
                                    color: "#94a3b8"
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }

                            ScadaTouchInputHandler {
                                targetInput: densityInput
                                numpad: numpadModal
                                loupe: modalLoupe
                                contextMenu: modalContextMenu
                                isNumeric: true
                                title: "DENSITY"
                                unit: "kg/m³"
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
                                selectByMouse: false
                                inputMethodHints: Qt.ImhNone
                                onTextChanged: metaModalRoot.authorName = text
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

                        ScadaTouchInputHandler {
                            targetInput: authorInput
                            keyboard: textKeyboard
                            loupe: modalLoupe
                            contextMenu: modalContextMenu
                            title: "AUTHOR / CREATOR NAME"
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
                                Rectangle {
                                    width: 10
                                    height: 10
                                    radius: 5
                                    color: metaModalRoot.qtyType === "Fixed" ? "#38bdf8" : "transparent"
                                    border.color: metaModalRoot.qtyType === "Fixed" ? "#ffffff" : "#64748b"
                                    border.width: 1.5
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
                                Rectangle {
                                    width: 10
                                    height: 10
                                    radius: 5
                                    color: metaModalRoot.qtyType === "Variable" ? "#c084fc" : "transparent"
                                    border.color: metaModalRoot.qtyType === "Variable" ? "#ffffff" : "#64748b"
                                    border.width: 1.5
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
                            selectByMouse: false
                            onTextChanged: metaModalRoot.description = text
                        }
                    }

                    ScadaTouchInputHandler {
                        targetInput: descInput
                        keyboard: textKeyboard
                        loupe: modalLoupe
                        contextMenu: modalContextMenu
                        title: "RECIPE DESCRIPTION"
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
                    Rectangle {
                        Layout.preferredWidth: 14
                        Layout.preferredHeight: 14
                        radius: 7
                        color: "transparent"
                        border.color: metaModalRoot.qtyType === "Fixed" ? "#38bdf8" : "#c084fc"
                        border.width: 1.5

                        Text {
                            anchors.centerIn: parent
                            text: "i"
                            color: metaModalRoot.qtyType === "Fixed" ? "#38bdf8" : "#c084fc"
                            font.bold: true
                            font.pixelSize: 10
                            font.family: "Segoe UI"
                        }
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
            } // End tabGeneralIdentity

            // =================================================================
            // TAB 2: R&D FORMULATION (CRITICAL QUALITY ATTRIBUTES - CQA)
            // =================================================================
            ColumnLayout {
                id: tabRdFormulation
                Layout.fillWidth: true
                visible: metaModalRoot.selectedPerspectiveTab === 1
                spacing: 10

                // Row 1: Target Viscosity Window (Min / Max cP)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        Text { text: "MIN TARGET VISCOSITY (cP) *"; color: "#38bdf8"; font.pixelSize: 10; font.bold: true; font.family: "Segoe UI" }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 32; color: "#081d33"; radius: 4
                            border.color: minViscInput.activeFocus ? "#38bdf8" : "#1d5b94"; border.width: 1
                            TextInput {
                                id: minViscInput; anchors.fill: parent; anchors.margins: 6
                                text: metaModalRoot.minViscosityCp; color: "#ffffff"; font.pixelSize: 12; font.bold: true; font.family: "Segoe UI"
                                onTextChanged: metaModalRoot.minViscosityCp = text
                            }
                            ScadaTouchInputHandler { targetInput: minViscInput; numpad: numpadModal; title: "MIN TARGET VISCOSITY (cP)"; unit: "cP" }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        Text { text: "MAX TARGET VISCOSITY (cP) *"; color: "#38bdf8"; font.pixelSize: 10; font.bold: true; font.family: "Segoe UI" }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 32; color: "#081d33"; radius: 4
                            border.color: maxViscInput.activeFocus ? "#38bdf8" : "#1d5b94"; border.width: 1
                            TextInput {
                                id: maxViscInput; anchors.fill: parent; anchors.margins: 6
                                text: metaModalRoot.maxViscosityCp; color: "#ffffff"; font.pixelSize: 12; font.bold: true; font.family: "Segoe UI"
                                onTextChanged: metaModalRoot.maxViscosityCp = text
                            }
                            ScadaTouchInputHandler { targetInput: maxViscInput; numpad: numpadModal; title: "MAX TARGET VISCOSITY (cP)"; unit: "cP" }
                        }
                    }
                }

                // Row 2: Target pH Window
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        Text { text: "MIN TARGET pH *"; color: "#38bdf8"; font.pixelSize: 10; font.bold: true; font.family: "Segoe UI" }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 32; color: "#081d33"; radius: 4
                            border.color: minPhInput.activeFocus ? "#38bdf8" : "#1d5b94"; border.width: 1
                            TextInput {
                                id: minPhInput; anchors.fill: parent; anchors.margins: 6
                                text: metaModalRoot.minPh; color: "#ffffff"; font.pixelSize: 12; font.bold: true; font.family: "Segoe UI"
                                onTextChanged: metaModalRoot.minPh = text
                            }
                            ScadaTouchInputHandler { targetInput: minPhInput; numpad: numpadModal; title: "MIN TARGET pH"; unit: "pH" }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        Text { text: "MAX TARGET pH *"; color: "#38bdf8"; font.pixelSize: 10; font.bold: true; font.family: "Segoe UI" }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 32; color: "#081d33"; radius: 4
                            border.color: maxPhInput.activeFocus ? "#38bdf8" : "#1d5b94"; border.width: 1
                            TextInput {
                                id: maxPhInput; anchors.fill: parent; anchors.margins: 6
                                text: metaModalRoot.maxPh; color: "#ffffff"; font.pixelSize: 12; font.bold: true; font.family: "Segoe UI"
                                onTextChanged: metaModalRoot.maxPh = text
                            }
                            ScadaTouchInputHandler { targetInput: maxPhInput; numpad: numpadModal; title: "MAX TARGET pH"; unit: "pH" }
                        }
                    }
                }

                // Row 3: Total Solids & Emulsion Droplet D50
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        Text { text: "TOTAL DISSOLVED SOLIDS (TDS %) *"; color: "#38bdf8"; font.pixelSize: 10; font.bold: true; font.family: "Segoe UI" }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 32; color: "#081d33"; radius: 4
                            border.color: solidsInput.activeFocus ? "#38bdf8" : "#1d5b94"; border.width: 1
                            TextInput {
                                id: solidsInput; anchors.fill: parent; anchors.margins: 6
                                text: metaModalRoot.totalSolidsPct; color: "#ffffff"; font.pixelSize: 12; font.bold: true; font.family: "Segoe UI"
                                onTextChanged: metaModalRoot.totalSolidsPct = text
                            }
                            ScadaTouchInputHandler { targetInput: solidsInput; numpad: numpadModal; title: "TOTAL DISSOLVED SOLIDS (%)"; unit: "%" }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        Text { text: "TARGET EMULSION DROPLET D50 (µm) *"; color: "#38bdf8"; font.pixelSize: 10; font.bold: true; font.family: "Segoe UI" }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 32; color: "#081d33"; radius: 4
                            border.color: dropletInput.activeFocus ? "#38bdf8" : "#1d5b94"; border.width: 1
                            TextInput {
                                id: dropletInput; anchors.fill: parent; anchors.margins: 6
                                text: metaModalRoot.dropletSizeMicrons; color: "#ffffff"; font.pixelSize: 12; font.bold: true; font.family: "Segoe UI"
                                onTextChanged: metaModalRoot.dropletSizeMicrons = text
                            }
                            ScadaTouchInputHandler { targetInput: dropletInput; numpad: numpadModal; title: "EMULSION DROPLET D50"; unit: "µm" }
                        }
                    }
                }

                // CQA Regulatory Guidance Banner
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    color: "#082f49"
                    border.color: "#0284c7"
                    border.width: 1
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Rectangle {
                            width: 16; height: 16; radius: 8; color: "#0284c7"
                            Text { anchors.centerIn: parent; text: "i"; color: "#ffffff"; font.bold: true; font.pixelSize: 10 }
                        }
                        Text {
                            text: "HASSAN ELDEEB R&D PERSPECTIVE: Critical Quality Attributes (CQA) define final batch release & FDA 21 CFR Part 11 electronic batch record compliance."
                            color: "#7dd3fc"
                            font.pixelSize: 10
                            font.family: "Segoe UI"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }
                }
            } // End tabRdFormulation

            // =================================================================
            // TAB 3: PROCESS DEV SCALE-UP (CRITICAL PROCESS PARAMETERS - CPP)
            // =================================================================
            ColumnLayout {
                id: tabProcessDev
                Layout.fillWidth: true
                visible: metaModalRoot.selectedPerspectiveTab === 2
                spacing: 10

                // Row 1: Max Heating & Cooling Ramp Envelopes
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        Text { text: "MAX HEATING RAMP RATE (°C/min) *"; color: "#38bdf8"; font.pixelSize: 10; font.bold: true; font.family: "Segoe UI" }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 32; color: "#081d33"; radius: 4
                            border.color: heatRateInput.activeFocus ? "#38bdf8" : "#1d5b94"; border.width: 1
                            TextInput {
                                id: heatRateInput; anchors.fill: parent; anchors.margins: 6
                                text: metaModalRoot.maxHeatingRateCpm; color: "#ffffff"; font.pixelSize: 12; font.bold: true; font.family: "Segoe UI"
                                onTextChanged: metaModalRoot.maxHeatingRateCpm = text
                            }
                            ScadaTouchInputHandler { targetInput: heatRateInput; numpad: numpadModal; title: "MAX HEATING RAMP (°C/min)"; unit: "°C/min" }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        Text { text: "MAX COOLING RAMP RATE (°C/min) *"; color: "#38bdf8"; font.pixelSize: 10; font.bold: true; font.family: "Segoe UI" }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 32; color: "#081d33"; radius: 4
                            border.color: coolRateInput.activeFocus ? "#38bdf8" : "#1d5b94"; border.width: 1
                            TextInput {
                                id: coolRateInput; anchors.fill: parent; anchors.margins: 6
                                text: metaModalRoot.maxCoolingRateCpm; color: "#ffffff"; font.pixelSize: 12; font.bold: true; font.family: "Segoe UI"
                                onTextChanged: metaModalRoot.maxCoolingRateCpm = text
                            }
                            ScadaTouchInputHandler { targetInput: coolRateInput; numpad: numpadModal; title: "MAX COOLING RAMP (°C/min)"; unit: "°C/min" }
                        }
                    }
                }

                // Row 2: Addition Dosing Flow Rate & Max Homogenizer Speed
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        Text { text: "MAX ADDITION DOSING FLOW RATE (kg/min) *"; color: "#38bdf8"; font.pixelSize: 10; font.bold: true; font.family: "Segoe UI" }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 32; color: "#081d33"; radius: 4
                            border.color: addRateInput.activeFocus ? "#38bdf8" : "#1d5b94"; border.width: 1
                            TextInput {
                                id: addRateInput; anchors.fill: parent; anchors.margins: 6
                                text: metaModalRoot.maxAdditionRateKpm; color: "#ffffff"; font.pixelSize: 12; font.bold: true; font.family: "Segoe UI"
                                onTextChanged: metaModalRoot.maxAdditionRateKpm = text
                            }
                            ScadaTouchInputHandler { targetInput: addRateInput; numpad: numpadModal; title: "MAX ADDITION RATE (kg/min)"; unit: "kg/min" }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        Text { text: "MAX HOMOGENIZER TIP SPEED (RPM) *"; color: "#38bdf8"; font.pixelSize: 10; font.bold: true; font.family: "Segoe UI" }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 32; color: "#081d33"; radius: 4
                            border.color: homoMaxInput.activeFocus ? "#38bdf8" : "#1d5b94"; border.width: 1
                            TextInput {
                                id: homoMaxInput; anchors.fill: parent; anchors.margins: 6
                                text: metaModalRoot.maxHomogenizerRpm; color: "#ffffff"; font.pixelSize: 12; font.bold: true; font.family: "Segoe UI"
                                onTextChanged: metaModalRoot.maxHomogenizerRpm = text
                            }
                            ScadaTouchInputHandler { targetInput: homoMaxInput; numpad: numpadModal; title: "MAX HOMOGENIZER RPM"; unit: "RPM" }
                        }
                    }
                }

                // Row 3: Max Vacuum Envelope & Target BCT Budget
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        Text { text: "MAX VACUUM DE-AERATION (bar) *"; color: "#38bdf8"; font.pixelSize: 10; font.bold: true; font.family: "Segoe UI" }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 32; color: "#081d33"; radius: 4
                            border.color: vacMaxInput.activeFocus ? "#38bdf8" : "#1d5b94"; border.width: 1
                            TextInput {
                                id: vacMaxInput; anchors.fill: parent; anchors.margins: 6
                                text: metaModalRoot.maxVacuumBar; color: "#ffffff"; font.pixelSize: 12; font.bold: true; font.family: "Segoe UI"
                                onTextChanged: metaModalRoot.maxVacuumBar = text
                            }
                            ScadaTouchInputHandler { targetInput: vacMaxInput; numpad: numpadModal; title: "MAX VACUUM ENVELOPE"; unit: "bar" }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        Text { text: "TARGET BCT CYCLE BUDGET (Minutes) *"; color: "#38bdf8"; font.pixelSize: 10; font.bold: true; font.family: "Segoe UI" }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 32; color: "#081d33"; radius: 4
                            border.color: bctTargetInput.activeFocus ? "#38bdf8" : "#1d5b94"; border.width: 1
                            TextInput {
                                id: bctTargetInput; anchors.fill: parent; anchors.margins: 6
                                text: metaModalRoot.targetBctMinutes; color: "#ffffff"; font.pixelSize: 12; font.bold: true; font.family: "Segoe UI"
                                onTextChanged: metaModalRoot.targetBctMinutes = text
                            }
                            ScadaTouchInputHandler { targetInput: bctTargetInput; numpad: numpadModal; title: "TARGET BCT BUDGET"; unit: "Mins" }
                        }
                    }
                }

                // Process Dev Guidance Banner
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    color: "#271d07"
                    border.color: "#f59e0b"
                    border.width: 1
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Rectangle {
                            width: 16; height: 16; radius: 8; color: "#f59e0b"
                            Text { anchors.centerIn: parent; text: "!"; color: "#000000"; font.bold: true; font.pixelSize: 10 }
                        }
                        Text {
                            text: "HASSAN ELDEEB PROCESS DEV ENVELOPE: Scale-up limits prevent thermal emulsion shock and set the target Batch Cycle Time (BCT) budget to eliminate NVAT."
                            color: "#fde68a"
                            font.pixelSize: 10
                            font.family: "Segoe UI"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }
                }
            } // End tabProcessDev

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
                            text: ">>"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 12
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
                                version: metaModalRoot.version,

                                // Hassan Eldeeb 3-Perspective Data
                                minViscosityCp: parseFloat(metaModalRoot.minViscosityCp) || 15000,
                                maxViscosityCp: parseFloat(metaModalRoot.maxViscosityCp) || 25000,
                                minPh: parseFloat(metaModalRoot.minPh) || 5.50,
                                maxPh: parseFloat(metaModalRoot.maxPh) || 6.50,
                                totalSolidsPct: parseFloat(metaModalRoot.totalSolidsPct) || 18.5,
                                dropletSizeMicrons: parseFloat(metaModalRoot.dropletSizeMicrons) || 2.5,
                                maxHeatingRateCpm: parseFloat(metaModalRoot.maxHeatingRateCpm) || 2.5,
                                maxCoolingRateCpm: parseFloat(metaModalRoot.maxCoolingRateCpm) || 2.0,
                                maxAdditionRateKpm: parseFloat(metaModalRoot.maxAdditionRateKpm) || 4.5,
                                maxHomogenizerRpm: parseFloat(metaModalRoot.maxHomogenizerRpm) || 3000,
                                maxVacuumBar: parseFloat(metaModalRoot.maxVacuumBar) || -0.80,
                                targetBctMinutes: parseFloat(metaModalRoot.targetBctMinutes) || 45.0
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
        anchors.fill: parent
        z: 9999
        visible: false
    }

    // Touch Ergonomics: Magnifying Loupe Bubble & Floating Context Menu Overlays
    ScadaTouchLoupe {
        id: modalLoupe
        z: 100000
    }

    ScadaTextContextMenu {
        id: modalContextMenu
        z: 100000
    }
}
