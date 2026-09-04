pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../../"

Item {
    id: dashboardLogicRoot
    implicitWidth: 1166
    implicitHeight: 600

    property int currentRecipeIndex: 0
    property var activeRecipeData: null
    readonly property int recipesCount: recipesModel.count

    signal createNewRecipeRequested
    signal newRecipeRequested
    signal editRecipeRequested(var recipeData)
    signal duplicateRecipeRequested(var recipeData)
    signal deleteRecipeRequested(var recipeData)
    signal proceedToIngredientsRequested(var recipeData)
    signal proceedToIngredientBuilder(var recipeData)
    signal openRecipeRequested(var recipeData)

    ListModel {
        id: recipesModel

        ListElement {
            recipeId: "REC-VPU50-001"
            title: "Industrial Shampoo Formulation"
            productName: "Clarifying Hair Care Cleanser"
            productType: "Solution / Cleanser"
            shelfLife: "36 Months"
            qtyType: "Variable"
            batchSizeKg: 100.0
            density: 1050.0
            author: "Dr. E. Vance (Level 3 - QA Officer)"
            version: 2
            status: "APPROVED"
            ingredientsCount: 15
            durationMin: 40
            description: "Surfactant-rich cleansing system with cold pearlizer dispersion."
        }

        ListElement {
            recipeId: "REC-VPU50-002"
            title: "Body Lotion Formulation"
            productName: "Cosmetic Intensive Body Lotion"
            productType: "Emulsion / Cream"
            shelfLife: "24 Months"
            qtyType: "Fixed"
            batchSizeKg: 100.0
            density: 1020.0
            author: "Formulation Chemist (Level 2 - Supervisor)"
            version: 1
            status: "APPROVED"
            ingredientsCount: 13
            durationMin: 45
            description: "5-Phase standard body lotion formulation per SOP-VPU50-042 (Phases A, B, C, D, E)."
        }

        ListElement {
            recipeId: "REC-VPU50-003"
            title: "Barrier Hydro-Gel Emulsion"
            productName: "Dermatological Barrier Ointment"
            productType: "Ointment"
            shelfLife: "24 Months"
            qtyType: "Fixed"
            batchSizeKg: 50.0
            density: 980.0
            author: "QA Tech Leader (Level 2 - Supervisor)"
            version: 1
            status: "DRAFT"
            ingredientsCount: 8
            durationMin: 30
            description: "High-shear de-aerated barrier hydro-gel with vacuum homogenization."
        }
    }

    Component.onCompleted: {
        updateActiveRecipe();
    }

    property var recipeIngredientsMap: ({})

    function updateActiveRecipe() {
        if (recipesModel.count > 0 && currentRecipeIndex >= 0 && currentRecipeIndex < recipesModel.count) {
            var item = recipesModel.get(currentRecipeIndex);
            var ings = recipeIngredientsMap[item.recipeId] || null;
            dashboardLogicRoot.activeRecipeData = {
                recipeId: item.recipeId,
                title: item.title,
                productName: item.productName,
                productType: item.productType,
                shelfLife: item.shelfLife,
                qtyType: item.qtyType,
                batchSizeKg: item.batchSizeKg,
                density: item.density,
                author: item.author,
                version: item.version,
                status: item.status,
                ingredientsCount: ings ? ings.length : item.ingredientsCount,
                durationMin: item.durationMin,
                description: item.description,
                ingredients: ings
            };
        }
    }

    function updateRecipeIngredients(rId, ings) {
        if (!rId) return;
        recipeIngredientsMap[rId] = ings;
        for (var i = 0; i < recipesModel.count; i++) {
            var item = recipesModel.get(i);
            if (item.recipeId === rId) {
                item.ingredientsCount = ings ? ings.length : 0;
                break;
            }
        }
        updateActiveRecipe();
    }

    function addRecipe(metadata) {
        var newId = metadata.id || ("REC-VPU50-" + String(recipesModel.count + 1).padStart(3, '0'));
        recipesModel.append({
            recipeId: newId,
            title: metadata.title || "New Master Recipe",
            productName: metadata.productName || "Product",
            productType: metadata.productType || "Emulsion / Cream",
            shelfLife: metadata.shelfLife || "24 Months",
            qtyType: metadata.qtyType || "Fixed",
            batchSizeKg: metadata.batchSizeKg || 100.0,
            density: metadata.targetDensity || metadata.density || 1000.0,
            author: metadata.author || "Supervisor (Level 2)",
            version: metadata.version || 1,
            status: "DRAFT",
            ingredientsCount: 0,
            durationMin: 0,
            description: metadata.description || "New formulation recipe authored per SOP standards."
        });
        currentRecipeIndex = recipesModel.count - 1;
        updateActiveRecipe();
    }

    function updateCurrentRecipe(metadata) {
        if (currentRecipeIndex >= 0 && currentRecipeIndex < recipesModel.count) {
            var item = recipesModel.get(currentRecipeIndex);
            item.title = metadata.title;
            item.productName = metadata.productName;
            item.productType = metadata.productType;
            item.shelfLife = metadata.shelfLife;
            item.qtyType = metadata.qtyType;
            item.batchSizeKg = metadata.batchSizeKg;
            item.density = metadata.targetDensity || metadata.density || 1000.0;
            item.author = metadata.author || item.author;
            item.version = metadata.version || item.version;
            item.description = metadata.description || item.description;
            updateActiveRecipe();
        }
    }

    function duplicateCurrent() {
        if (currentRecipeIndex >= 0 && currentRecipeIndex < recipesModel.count) {
            var src = recipesModel.get(currentRecipeIndex);
            var copyId = src.recipeId + "-COPY";
            recipesModel.append({
                recipeId: copyId,
                title: src.title + " (Copy)",
                productName: src.productName,
                productType: src.productType,
                shelfLife: src.shelfLife,
                qtyType: src.qtyType,
                batchSizeKg: src.batchSizeKg,
                density: src.density,
                author: src.author,
                version: 1,
                status: "DRAFT",
                ingredientsCount: src.ingredientsCount,
                durationMin: src.durationMin,
                description: "Duplicate of " + src.title
            });
            currentRecipeIndex = recipesModel.count - 1;
            updateActiveRecipe();
        }
    }

    function deleteCurrent() {
        if (recipesModel.count > 1 && currentRecipeIndex >= 0 && currentRecipeIndex < recipesModel.count) {
            recipesModel.remove(currentRecipeIndex);
            currentRecipeIndex = Math.max(0, currentRecipeIndex - 1);
            updateActiveRecipe();
        }
    }

    RecipeDashboardView {
        id: view
        anchors.fill: parent
        totalRecipesCount: recipesModel.count
        selectedIndex: dashboardLogicRoot.currentRecipeIndex

        recipeListView.model: recipesModel
        recipeListView.delegate: Rectangle {
            id: cardDelegate
            required property string recipeId
            required property string title
            required property string productName
            required property string productType
            required property string shelfLife
            required property string qtyType
            required property double batchSizeKg
            required property double density
            required property string author
            required property int version
            required property string status
            required property int ingredientsCount
            required property int durationMin
            required property string description
            required property int index

            readonly property bool isSelected: dashboardLogicRoot.currentRecipeIndex === cardDelegate.index

            width: view.recipeListView.width
            height: 106
            radius: 6
            color: isSelected ? "#124373" : (cardMouse.containsMouse ? "#0e3359" : "#092442")
            border.color: isSelected ? "#38bdf8" : (cardMouse.containsMouse ? "#2563eb" : "#1d5b94")
            border.width: isSelected ? 2 : 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 16

                // 1. Left Flask Icon & Clean Recipe ID Box (Generous sizing & padding)
                Rectangle {
                    Layout.preferredWidth: 94
                    Layout.preferredHeight: 82
                    Layout.alignment: Qt.AlignVCenter
                    radius: 6
                    color: "#081d33"
                    border.color: cardDelegate.isSelected ? "#38bdf8" : "#1d5b94"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 4

                        ScadaIcon {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            iconName: "recipe_maker"
                        }

                        Text {
                            Layout.fillWidth: true
                            text: cardDelegate.recipeId
                            color: "#38bdf8"
                            font.bold: true
                            font.pixelSize: 10
                            font.family: "Segoe UI"
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }
                    }
                }

                // 2. Middle Information Hierarchy Column
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 4

                    // Header Row: Recipe Title + Status Pill + Qty Mode Pill
                    RowLayout {
                        spacing: 8

                        Text {
                            text: cardDelegate.title
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 15
                            font.family: "Segoe UI"
                        }

                        Rectangle {
                            Layout.preferredHeight: 20
                            Layout.preferredWidth: statusTxt.implicitWidth + 12
                            radius: 3
                            color: cardDelegate.status === "APPROVED" ? "#065f46" : (cardDelegate.status === "IN_REVIEW" ? "#854d0e" : "#334155")
                            border.color: cardDelegate.status === "APPROVED" ? "#34d399" : (cardDelegate.status === "IN_REVIEW" ? "#facc15" : "#64748b")
                            border.width: 1

                            Text {
                                id: statusTxt
                                anchors.centerIn: parent
                                text: cardDelegate.status
                                color: "#ffffff"
                                font.bold: true
                                font.pixelSize: 10
                                font.family: "Segoe UI"
                            }
                        }

                        Rectangle {
                            Layout.preferredHeight: 20
                            Layout.preferredWidth: typeTxt.implicitWidth + 12
                            radius: 3
                            color: cardDelegate.qtyType === "Fixed" ? "#0369a1" : "#6b21a8"
                            border.color: cardDelegate.qtyType === "Fixed" ? "#38bdf8" : "#c084fc"
                            border.width: 1

                            Text {
                                id: typeTxt
                                anchors.centerIn: parent
                                text: cardDelegate.qtyType + " Qty"
                                color: "#ffffff"
                                font.bold: true
                                font.pixelSize: 10
                                font.family: "Segoe UI"
                            }
                        }
                    }

                    // Subtitle: Product Name & Description
                    Text {
                        text: cardDelegate.productName + " | Type: " + cardDelegate.productType + " | " + cardDelegate.description
                        color: "#94a3b8"
                        font.pixelSize: 12
                        font.family: "Segoe UI"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    // Clean Metrics Strip (Zero unicode emoji dependency, web-safe formatting)
                    RowLayout {
                        spacing: 12
                        Layout.fillWidth: true

                        Text {
                            text: "Shelf Life: <font color='#34d399'><b>" + cardDelegate.shelfLife + "</b></font>"
                            color: "#94a3b8"
                            font.pixelSize: 11
                            font.family: "Segoe UI"
                            textFormat: Text.RichText
                        }

                        Text {
                            text: "•"
                            color: "#475569"
                            font.pixelSize: 10
                        }

                        Text {
                            text: "Batch Size: <font color='#38bdf8'><b>" + cardDelegate.batchSizeKg + " kg</b></font>"
                            color: "#94a3b8"
                            font.pixelSize: 11
                            font.family: "Segoe UI"
                            textFormat: Text.RichText
                        }

                        Text {
                            text: "•"
                            color: "#475569"
                            font.pixelSize: 10
                        }

                        Text {
                            text: "Density: <font color='#c084fc'><b>" + cardDelegate.density + " kg/m³</b></font>"
                            color: "#94a3b8"
                            font.pixelSize: 11
                            font.family: "Segoe UI"
                            textFormat: Text.RichText
                        }

                        Text {
                            text: "•"
                            color: "#475569"
                            font.pixelSize: 10
                        }

                        Text {
                            text: "Formulation: <font color='#facc15'><b>" + cardDelegate.ingredientsCount + " Ingredients</b></font>"
                            color: "#94a3b8"
                            font.pixelSize: 11
                            font.family: "Segoe UI"
                            textFormat: Text.RichText
                        }

                        Text {
                            text: "•"
                            color: "#475569"
                            font.pixelSize: 10
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Author: <font color='#cbd5e1'>" + cardDelegate.author + " (v" + cardDelegate.version + ")</font>"
                            color: "#94a3b8"
                            font.pixelSize: 11
                            font.family: "Segoe UI"
                            textFormat: Text.RichText
                            elide: Text.ElideRight
                        }
                    }
                }

                // 3. Selection Radio Indicator
                Rectangle {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    radius: 12
                    color: cardDelegate.isSelected ? "#0284c7" : "#081d33"
                    border.color: cardDelegate.isSelected ? "#38bdf8" : "#1d5b94"
                    border.width: 2

                    Rectangle {
                        anchors.centerIn: parent
                        width: 10
                        height: 10
                        radius: 5
                        color: "#ffffff"
                        visible: cardDelegate.isSelected
                    }
                }
            }

            MouseArea {
                id: cardMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    dashboardLogicRoot.currentRecipeIndex = cardDelegate.index;
                    dashboardLogicRoot.updateActiveRecipe();
                }
                onDoubleClicked: {
                    dashboardLogicRoot.currentRecipeIndex = cardDelegate.index;
                    dashboardLogicRoot.updateActiveRecipe();
                    dashboardLogicRoot.openRecipeRequested(dashboardLogicRoot.activeRecipeData);
                }
            }
        }
    }

    // Connect View Mouse Areas to Logic Actions
    Connections {
        target: view.createNewRecipeMouse
        function onClicked() {
            dashboardLogicRoot.createNewRecipeRequested();
            dashboardLogicRoot.newRecipeRequested();
        }
    }

    Connections {
        target: view.editRecipeMouse
        function onClicked() {
            if (dashboardLogicRoot.activeRecipeData) {
                dashboardLogicRoot.editRecipeRequested(dashboardLogicRoot.activeRecipeData);
            }
        }
    }

    Connections {
        target: view.duplicateRecipeMouse
        function onClicked() {
            if (dashboardLogicRoot.activeRecipeData) {
                dashboardLogicRoot.duplicateRecipeRequested(dashboardLogicRoot.activeRecipeData);
            }
        }
    }

    Connections {
        target: view.deleteRecipeMouse
        function onClicked() {
            if (dashboardLogicRoot.activeRecipeData) {
                dashboardLogicRoot.deleteRecipeRequested(dashboardLogicRoot.activeRecipeData);
            }
        }
    }

    Connections {
        target: view.proceedToIngredientsMouse
        function onClicked() {
            if (dashboardLogicRoot.activeRecipeData) {
                dashboardLogicRoot.proceedToIngredientsRequested(dashboardLogicRoot.activeRecipeData);
                dashboardLogicRoot.proceedToIngredientBuilder(dashboardLogicRoot.activeRecipeData);
            }
        }
    }
}
