pragma ComponentBehavior: Bound
import QtQuick
import "../config"

Item {
    id: recipeMakerController
    implicitWidth: 1166
    implicitHeight: 630

    property string userRole: "incharge"
    property int userLevel: 2
    property string activeUserName: "Process Incharge"
    property string activeUserRole: "Supervisor (Level 2)"
    property int activeUserLevel: 2

    ScadaStateMiddleware { id: stateMiddleware }

    Screen_9_RecipeMakerView {
        id: ui
        anchors.fill: parent
    }

    // Top Stepper Navigation Tabs
    MouseArea {
        parent: ui.stage0Btn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: ui.currentStage = 0
    }

    MouseArea {
        parent: ui.stage1Btn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            var rec = ui.dashboardScreen.activeRecipeData;
            if (rec) {
                ui.ingredientScreen.loadRecipe(rec);
            }
            ui.currentStage = 1;
        }
    }

    MouseArea {
        parent: ui.stage2Btn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            var ings = ui.ingredientScreen.getIngredientsArray();
            ui.timelineScreen.ingredientsList = ings;
            ui.currentStage = 2;
        }
    }

    // =========================================================================
    // SCREEN 1: METADATA & CATALOG SIGNALS
    // =========================================================================
    Connections {
        target: ui.dashboardScreen

        function onNewRecipeRequested() {
            ui.metadataModal.mode = "NEW";
            ui.metadataModal.recipeId = "REC-VPU50-NEW";
            ui.metadataModal.recipeTitle = "New Formulation Recipe";
            ui.metadataModal.productName = "Product Batch";
            ui.metadataModal.productType = "Emulsion / Cream";
            ui.metadataModal.shelfLifeMonths = "24 Months";
            ui.metadataModal.qtyType = "Fixed";
            ui.metadataModal.batchSizeKg = "100.0";
            ui.metadataModal.targetDensity = "1.02";
            ui.metadataModal.description = "High-shear de-aerated formulation with vacuum homogenization.";
            ui.metadataModal.author = recipeMakerController.activeUserName + " (" + recipeMakerController.activeUserRole + ")";
            ui.metadataModal.version = 1;
            ui.metadataModal.visible = true;
        }

        function onEditRecipeRequested(recipe) {
            ui.metadataModal.mode = "EDIT";
            ui.metadataModal.recipeId = recipe.recipeId;
            ui.metadataModal.recipeTitle = recipe.title;
            ui.metadataModal.productName = recipe.productName;
            ui.metadataModal.productType = recipe.productType;
            ui.metadataModal.shelfLifeMonths = recipe.shelfLife;
            ui.metadataModal.qtyType = recipe.qtyType;
            ui.metadataModal.batchSizeKg = String(recipe.batchSizeKg);
            ui.metadataModal.targetDensity = String(recipe.density || 1.0);
            ui.metadataModal.description = recipe.description || "";
            ui.metadataModal.author = recipe.author || (recipeMakerController.activeUserName + " (" + recipeMakerController.activeUserRole + ")");
            ui.metadataModal.version = recipe.version || 1;
            ui.metadataModal.visible = true;
        }

        function onDuplicateRecipeRequested(recipe) {
            stateMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "incharge", "Duplicated master recipe: " + recipe.title, "RECIPE_AUTHORING");
        }

        function onDeleteRecipeRequested(recipe) {
            ui.deleteConfirmModal.targetItemTitle = recipe.title;
            ui.deleteConfirmModal.targetItemType = "recipe";
            ui.deleteConfirmModal.visible = true;
        }

        function onProceedToIngredientBuilder(recipe) {
            ui.activeRecipeTitle = recipe.title;
            ui.activeRecipeId = recipe.recipeId;
            ui.ingredientScreen.loadRecipe(recipe);
            ui.currentStage = 1; // Transition to Screen 2
            stateMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "incharge", "Opened ingredient formulation for: " + recipe.title, "RECIPE_AUTHORING");
        }
    }

    // =========================================================================
    // SCREEN 2: INGREDIENT BUILDER SIGNALS
    // =========================================================================
    Connections {
        target: ui.ingredientScreen

        function onBackToDashboardRequested() {
            ui.currentStage = 0;
        }

        function onProceedToTimelineRequested(ingredientsList) {
            ui.timelineScreen.ingredientsList = ingredientsList;
            ui.timelineScreen.recipeTitle = ui.activeRecipeTitle;
            ui.timelineScreen.recipeId = ui.activeRecipeId;
            ui.currentStage = 2; // Transition to Screen 3
            stateMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "incharge", "Opened timeline designer with " + ingredientsList.length + " ingredients for: " + ui.activeRecipeTitle, "RECIPE_AUTHORING");
        }

        function onAddIngredientRequested() {
            ui.ingredientModal.mode = "ADD";
            ui.ingredientModal.ingredientName = "";
            ui.ingredientModal.phase = "A";
            ui.ingredientModal.qtyValue = "1.0";
            ui.ingredientModal.qtyUnit = "kg";
            ui.ingredientModal.isaParameters = "Take in vessel and agitate.";
            ui.ingredientModal.isVariableQty = (ui.dashboardScreen.activeRecipeData && ui.dashboardScreen.activeRecipeData.qtyType === "Variable");
            ui.ingredientModal.visible = true;
        }

        function onEditIngredientRequested(item, index) {
            ui.ingredientModal.mode = "EDIT";
            ui.ingredientModal.srNo = item.srNo;
            ui.ingredientModal.ingredientName = item.name;
            ui.ingredientModal.phase = item.phase;
            ui.ingredientModal.qtyValue = item.qty.replace(" kg", "").replace(" g", "").replace(" L", "");
            ui.ingredientModal.qtyUnit = item.qty.indexOf("kg") !== -1 ? "kg" : (item.qty.indexOf("L") !== -1 ? "L" : "g");
            ui.ingredientModal.formulaText = item.qty;
            ui.ingredientModal.isaParameters = item.isa;
            ui.ingredientModal.isVariableQty = (ui.dashboardScreen.activeRecipeData && ui.dashboardScreen.activeRecipeData.qtyType === "Variable");
            ui.ingredientModal.visible = true;
        }

        function onDuplicateIngredientRequested(item, index) {
            ui.ingredientModal.mode = "DUPLICATE";
            ui.ingredientModal.srNo = item.srNo;
            ui.ingredientModal.ingredientName = item.name + " (Copy)";
            ui.ingredientModal.phase = item.phase;
            ui.ingredientModal.qtyValue = item.qty.replace(" kg", "").replace(" g", "").replace(" L", "");
            ui.ingredientModal.qtyUnit = item.qty.indexOf("kg") !== -1 ? "kg" : "g";
            ui.ingredientModal.formulaText = item.qty;
            ui.ingredientModal.isaParameters = item.isa;
            ui.ingredientModal.isVariableQty = (ui.dashboardScreen.activeRecipeData && ui.dashboardScreen.activeRecipeData.qtyType === "Variable");
            ui.ingredientModal.visible = true;
        }

        function onDeleteIngredientRequested(item, index) {
            ui.deleteConfirmModal.targetItemTitle = item.name;
            ui.deleteConfirmModal.targetItemType = "ingredient";
            ui.deleteConfirmModal.visible = true;
        }
    }

    // =========================================================================
    // SCREEN 3: TIMELINE DESIGNER SIGNALS
    // =========================================================================
    Connections {
        target: ui.timelineScreen

        function onBackToIngredientsRequested() {
            ui.currentStage = 1;
        }

        function onOpenConfigModalRequested(config) {
            ui.resourceConfigModal.stageId = config.stageId;
            ui.resourceConfigModal.phaseName = config.phaseName;
            ui.resourceConfigModal.resourceType = config.resourceType;
            ui.resourceConfigModal.resourceName = config.resourceName;
            ui.resourceConfigModal.unit = config.unit;
            ui.resourceConfigModal.minLimit = config.minLimit;
            ui.resourceConfigModal.maxLimit = config.maxLimit;
            ui.resourceConfigModal.setValue = config.setValue;
            ui.resourceConfigModal.purpose = config.purpose;
            ui.resourceConfigModal.selectedMaterials = config.selectedMaterials || [];

            // Populate available materials from Screen 2
            var avail = [];
            var rawList = ui.ingredientScreen.getIngredientsArray();
            for (var i = 0; i < rawList.length; i++) {
                avail.push(rawList[i].name);
            }
            ui.resourceConfigModal.availableMaterials = avail;

            ui.resourceConfigModal.manualConfirm = config.manualConfirm;
            ui.resourceConfigModal.hmiMessage = config.hmiMessage || "Material loaded. Close Valve.";
            ui.resourceConfigModal.durationSec = config.durationSec || 180;
            ui.resourceConfigModal.stopConditionType = config.stopConditionType || "timer";
            ui.resourceConfigModal.visible = true;
        }

        function onOpenManualModalRequested(manConfig) {
            ui.manualActivityModal.stageId = manConfig.stageId || "2.1";
            ui.manualActivityModal.phaseName = manConfig.phaseName || "Phase B";
            ui.manualActivityModal.actionTarget = manConfig.actionTarget || "Butterfly Valve abc123";
            ui.manualActivityModal.actionRequired = manConfig.actionRequired || "OPEN";
            ui.manualActivityModal.displayMessage = manConfig.displayMessage || ("Operator to confirm that " + (manConfig.actionTarget || "valve") + " is " + (manConfig.actionRequired || "OPEN") + ".");
            ui.manualActivityModal.visible = true;
        }

        function onRecipeSaved(recipePayload) {
            stateMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "incharge", "21 CFR Part 11: Master Recipe Saved & Serialized: " + ui.activeRecipeTitle, "RECIPE_AUTHORING");
        }

        function onRecipeSubmittedForReview(recipePayload) {
            stateMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "incharge", "21 CFR Part 11: Submitted Master Recipe for QA / Supervisor Approval: " + ui.activeRecipeTitle, "ELECTRONIC_SIGNATURE");
        }

        function onNodeRedExportGenerated(jsonText) {
            stateMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "incharge", "Exported Node-RED PLC batch execution package for: " + ui.activeRecipeTitle, "RECIPE_AUTHORING");
        }
    }

    // =========================================================================
    // MODAL DIALOGS CONNECTIONS
    // =========================================================================
    Connections {
        target: ui.metadataModal

        function onCancelled() {
            ui.metadataModal.visible = false;
        }

        function onSaveAndNext(metadata) {
            ui.metadataModal.visible = false;
            if (ui.metadataModal.mode === "NEW") {
                ui.dashboardScreen.addRecipe(metadata);
            } else {
                ui.dashboardScreen.updateCurrentRecipe(metadata);
            }
            ui.activeRecipeTitle = metadata.title;
            ui.ingredientScreen.loadRecipe(metadata);
            ui.currentStage = 1; // Advance to Screen 2
            stateMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "incharge", "Saved metadata & proceeded to formulation for: " + metadata.title, "RECIPE_AUTHORING");
        }
    }

    Connections {
        target: ui.ingredientModal

        function onCancelled() {
            ui.ingredientModal.visible = false;
        }

        function onAccepted(data) {
            ui.ingredientModal.visible = false;
            if (ui.ingredientModal.mode === "ADD") {
                ui.ingredientScreen.addIngredient(data);
                stateMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "incharge", "Added formulation ingredient: " + data.name + " (" + data.phase + ")", "RECIPE_AUTHORING");
            } else if (ui.ingredientModal.mode === "EDIT") {
                ui.ingredientScreen.updateIngredient(ui.ingredientScreen.selectedRowIndex, data);
                stateMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "incharge", "Updated formulation ingredient: " + data.name, "RECIPE_AUTHORING");
            } else if (ui.ingredientModal.mode === "DUPLICATE") {
                ui.ingredientScreen.duplicateIngredient(ui.ingredientScreen.selectedRowIndex, data);
                stateMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "incharge", "Copied formulation ingredient: " + data.name, "RECIPE_AUTHORING");
            }
        }
    }

    Connections {
        target: ui.deleteConfirmModal

        function onCancelled() {
            ui.deleteConfirmModal.visible = false;
        }

        function onConfirmed() {
            ui.deleteConfirmModal.visible = false;
            if (ui.deleteConfirmModal.targetItemType === "recipe") {
                ui.dashboardScreen.deleteCurrent();
                stateMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "incharge", "Deleted master recipe: " + ui.deleteConfirmModal.targetItemTitle, "RECIPE_AUTHORING");
            } else {
                ui.ingredientScreen.deleteIngredient(ui.ingredientScreen.selectedRowIndex);
                stateMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "incharge", "Deleted formulation item: " + ui.deleteConfirmModal.targetItemTitle, "RECIPE_AUTHORING");
            }
        }
    }

    Connections {
        target: ui.resourceConfigModal

        function onCancelled() {
            ui.resourceConfigModal.visible = false;
        }

        function onAccepted(config) {
            ui.resourceConfigModal.visible = false;
            ui.timelineScreen.setClipConfig(config);
            stateMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "incharge", "Updated timeline block config: " + config.resourceName + " in " + config.phase, "RECIPE_AUTHORING");
        }
    }

    Connections {
        target: ui.manualActivityModal

        function onCancelled() {
            ui.manualActivityModal.visible = false;
        }

        function onAccepted(config) {
            ui.manualActivityModal.visible = false;
            ui.timelineScreen.setClipConfig(config);
            stateMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "incharge", "21 CFR Part 11: Added/Updated manual sequence interlock: " + config.actionTarget + " (" + config.actionRequired + ") in " + config.phase, "RECIPE_AUTHORING");
        }
    }
}
