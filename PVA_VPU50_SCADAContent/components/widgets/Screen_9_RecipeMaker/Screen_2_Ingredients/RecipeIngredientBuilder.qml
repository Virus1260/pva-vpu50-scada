pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

Item {
    id: ingBuilderLogicRoot
    implicitWidth: 1166
    implicitHeight: 600

    property string recipeId: "REC-VPU50-002"
    property string recipeTitle: "Body Lotion Formulation"
    property string productName: "Cosmetic Intensive Body Lotion"
    property string qtyType: "Fixed"
    property int selectedRowIndex: -1

    signal backToDashboardRequested
    signal proceedToTimelineRequested(var ingredientsList)
    signal addIngredientRequested
    signal editIngredientRequested(var item, int index)
    signal duplicateIngredientRequested(var item, int index)
    signal deleteIngredientRequested(var item, int index)
    signal ingredientsUpdated(var ingredientsList)

    // Master Ingredients ListModel
    ListModel {
        id: ingredientsModel
    }

    Component.onCompleted: {
        loadSampleBodyLotion();
    }

    function getPhaseColor(phaseStr) {
        var p = String(phaseStr || "A").toUpperCase().replace("PHASE", "").trim();
        var colors = {
            "A": "#0369a1",
            "B": "#b45309",
            "C": "#047857",
            "D": "#7c2d12",
            "E": "#6b21a8",
            "F": "#0f766e",
            "G": "#4338ca",
            "H": "#be185d",
            "I": "#854d0e",
            "J": "#1e3a8a",
            "1": "#0369a1",
            "2": "#b45309",
            "3": "#047857",
            "4": "#7c2d12",
            "5": "#6b21a8"
        };
        if (colors[p]) return colors[p];
        var hash = 0;
        for (var i = 0; i < p.length; i++) {
            hash = (hash << 5) - hash + p.charCodeAt(i);
            hash |= 0;
        }
        var palette = ["#0284c7", "#059669", "#d97706", "#7c3aed", "#db2777", "#0d9488", "#4f46e5", "#ea580c"];
        return palette[Math.abs(hash) % palette.length];
    }

    function loadSampleBodyLotion() {
        ingredientsModel.clear();
        ingredientsModel.append({ srNo: 1, name: "WATER (9.2 KG)", phase: "Phase A", qty: "9.2 kg", isa: "Take in vessel first. Heat till 80-85°C with slow anchor stirring (25 RPM)." });
        ingredientsModel.append({ srNo: 2, name: "DI SODIUM EDTA", phase: "Phase A", qty: "0.1 kg", isa: "Add to aqueous phase and dissolve completely." });
        ingredientsModel.append({ srNo: 3, name: "GLYCERINE", phase: "Phase A", qty: "3.0 kg", isa: "Charge humectant into Phase A under continuous agitation." });
        ingredientsModel.append({ srNo: 4, name: "SHELL POL 940", phase: "Phase A", qty: "0.4 kg", isa: "Slowly disperse carbomer thickener to prevent lump formation." });
        ingredientsModel.append({ srNo: 5, name: "PHENOXY ETHANOL", phase: "Phase A", qty: "0.5 kg", isa: "Preservative addition in aqueous base." });
        ingredientsModel.append({ srNo: 6, name: "LIGHT LIQUID PARAFFIN", phase: "Phase B", qty: "6.0 kg", isa: "Take Phase B in premix vessel. Heat till 80-85°C." });
        ingredientsModel.append({ srNo: 7, name: "CETO STEARYL ALCOHOL", phase: "Phase B", qty: "2.5 kg", isa: "Melt with oil phase at 80-85°C." });
        ingredientsModel.append({ srNo: 8, name: "MCW (Microcrystalline Wax)", phase: "Phase B", qty: "1.0 kg", isa: "Ensure complete dissolution in oil phase." });
        ingredientsModel.append({ srNo: 9, name: "GLYCERYL STEARATE", phase: "Phase B", qty: "2.0 kg", isa: "Emulsifier addition into oil phase at 80-85°C." });
        ingredientsModel.append({ srNo: 10, name: "STEARIC ACID", phase: "Phase B", qty: "2.5 kg", isa: "Maintain temp of both Phase A & B at 80-85°C. Add Phase B in Phase A with continuous stirring." });
        ingredientsModel.append({ srNo: 11, name: "SLES 70%", phase: "Phase C", qty: "1.5 kg", isa: "At 55°C add Phase C under gentle vacuum (-300 mbar)." });
        ingredientsModel.append({ srNo: 12, name: "TRIETHANOLAMINE", phase: "Phase D", qty: "0.4 kg", isa: "At 50°C add Phase D (Neutralizer) for gel network formation." });
        ingredientsModel.append({ srNo: 13, name: "DMDM HYDANTOIN", phase: "Phase E", qty: "0.2 kg", isa: "At 40-45°C add Phase E preservative & perfume actives." });
    }

    function loadSampleShampoo() {
        ingredientsModel.clear();
        ingredientsModel.append({ srNo: 1, name: "DM WATER", phase: "Phase A", qty: "72.0 kg", isa: "Charge purified water. Heat to 60°C with anchor agitation (30 RPM)." });
        ingredientsModel.append({ srNo: 2, name: "DISODIUM EDTA", phase: "Phase A", qty: "0.1 kg", isa: "Chelating agent. Dissolve until transparent." });
        ingredientsModel.append({ srNo: 3, name: "GLYCERIN", phase: "Phase A", qty: "2.0 kg", isa: "Humectant charge in aqueous base." });
        ingredientsModel.append({ srNo: 4, name: "POLYQUATERNIUM-7", phase: "Phase A", qty: "1.5 kg", isa: "Conditioning polymer. Disperse slowly." });
        ingredientsModel.append({ srNo: 5, name: "SLES 70% (Sodium Laureth Sulfate)", phase: "Phase B", qty: "14.0 kg", isa: "Primary anionic surfactant. Vacuum load under -300 mbar." });
        ingredientsModel.append({ srNo: 6, name: "CAPB 30% (Cocamidopropyl Betaine)", phase: "Phase B", qty: "3.5 kg", isa: "Secondary amphoteric surfactant for foam stability." });
        ingredientsModel.append({ srNo: 7, name: "COCAMIDE DEA (CDEA)", phase: "Phase B", qty: "1.5 kg", isa: "Viscosity builder and foam booster." });
        ingredientsModel.append({ srNo: 8, name: "ETHYLENE GLYCOL DISTEARATE (EGDS)", phase: "Phase B", qty: "1.2 kg", isa: "Pearlizing agent. Melt at 70°C and homogenize." });
        ingredientsModel.append({ srNo: 9, name: "DIMETHICONOL EMULSION", phase: "Phase C", qty: "0.8 kg", isa: "Silicone conditioning agent. Add under slow stirring." });
        ingredientsModel.append({ srNo: 10, name: "ZINC PYRITHIONE (ZPT)", phase: "Phase C", qty: "1.0 kg", isa: "Anti-dandruff active. High shear dispersion." });
        ingredientsModel.append({ srNo: 11, name: "CITRIC ACID 50% SOLN", phase: "Phase D", qty: "0.3 kg", isa: "Adjust batch pH to 5.5 - 6.2." });
        ingredientsModel.append({ srNo: 12, name: "SODIUM CHLORIDE (NaCl)", phase: "Phase D", qty: "1.2 kg", isa: "Viscosity builder. Add in increments." });
        ingredientsModel.append({ srNo: 13, name: "SODIUM BENZOATE", phase: "Phase D", qty: "0.4 kg", isa: "Antimicrobial preservative." });
        ingredientsModel.append({ srNo: 14, name: "PHENOXYETHANOL", phase: "Phase D", qty: "0.3 kg", isa: "Broad spectrum preservative." });
        ingredientsModel.append({ srNo: 15, name: "ACTIVE BOTANICAL PERFUME", phase: "Phase D", qty: "0.5 kg", isa: "Cold add fragrance at 35°C." });
    }

    function loadSampleBarrierGel() {
        ingredientsModel.clear();
        ingredientsModel.append({ srNo: 1, name: "PURIFIED WATER USP", phase: "Phase A", qty: "35.0 kg", isa: "Charge water at room temp. Start anchor stirrer at 35 RPM." });
        ingredientsModel.append({ srNo: 2, name: "CARBOPOL ULTREZ 20", phase: "Phase A", qty: "0.8 kg", isa: "Polymer gelling agent. Disperse under -400 mbar vacuum." });
        ingredientsModel.append({ srNo: 3, name: "GLYCERIN USP", phase: "Phase A", qty: "5.0 kg", isa: "Humectant hydration agent." });
        ingredientsModel.append({ srNo: 4, name: "WHITE PETROLATUM", phase: "Phase B", qty: "4.5 kg", isa: "Hydrocarbon barrier base. Melt at 75°C." });
        ingredientsModel.append({ srNo: 5, name: "DIMETHICONE 350 CST", phase: "Phase B", qty: "2.5 kg", isa: "Hydrophobic barrier fluid. Homogenize at 2800 RPM." });
        ingredientsModel.append({ srNo: 6, name: "CYCLOMETHICONE", phase: "Phase B", qty: "1.5 kg", isa: "Spreading volatile silicone." });
        ingredientsModel.append({ srNo: 7, name: "TRIETHANOLAMINE 99%", phase: "Phase C", qty: "0.4 kg", isa: "Neutralize carbomer matrix to form clear gel." });
        ingredientsModel.append({ srNo: 8, name: "ETHYLHEXYLGLYCERIN", phase: "Phase C", qty: "0.3 kg", isa: "Preservative potentiator and skin conditioner." });
    }

    function getIngredientsArray() {
        var arr = [];
        for (var i = 0; i < ingredientsModel.count; i++) {
            var item = ingredientsModel.get(i);
            arr.push({
                srNo: item.srNo,
                name: item.name,
                phase: item.phase,
                qty: item.qty,
                isa: item.isa
            });
        }
        return arr;
    }

    function addIngredient(data) {
        var nextSr = ingredientsModel.count + 1;
        var formattedQty = data.qty || (data.isVariable ? (data.formulaText || "1.0%") : ((data.qtyValue !== undefined ? data.qtyValue : "1.0") + " " + (data.qtyUnit || "kg")));
        var formattedIsa = data.isa || data.isaParameters || "Take in vessel and agitate.";

        ingredientsModel.append({
            srNo: nextSr,
            name: data.name || "Raw Material",
            phase: data.phase || "Phase 1",
            qty: formattedQty,
            isa: formattedIsa
        });
        selectedRowIndex = ingredientsModel.count - 1;
        ingBuilderLogicRoot.ingredientsUpdated(getIngredientsArray());
    }

    function updateIngredient(index, data) {
        if (index >= 0 && index < ingredientsModel.count) {
            var item = ingredientsModel.get(index);
            var formattedQty = data.qty || (data.isVariable ? (data.formulaText || "1.0%") : ((data.qtyValue !== undefined ? data.qtyValue : "1.0") + " " + (data.qtyUnit || "kg")));
            var formattedIsa = data.isa || data.isaParameters || item.isa;

            item.name = data.name || item.name;
            item.phase = data.phase || item.phase;
            item.qty = formattedQty;
            item.isa = formattedIsa;
            ingBuilderLogicRoot.ingredientsUpdated(getIngredientsArray());
        }
    }

    function duplicateIngredient(index, data) {
        var nextSr = ingredientsModel.count + 1;
        var formattedQty = data.qty || (data.isVariable ? (data.formulaText || "1.0%") : ((data.qtyValue !== undefined ? data.qtyValue : "1.0") + " " + (data.qtyUnit || "kg")));
        var formattedIsa = data.isa || data.isaParameters || "Take in vessel and agitate.";

        ingredientsModel.append({
            srNo: nextSr,
            name: (data.name || "Raw Material") + " (Copy)",
            phase: data.phase || "Phase 1",
            qty: formattedQty,
            isa: formattedIsa
        });
        selectedRowIndex = ingredientsModel.count - 1;
        ingBuilderLogicRoot.ingredientsUpdated(getIngredientsArray());
    }

    function deleteIngredient(index) {
        if (index >= 0 && index < ingredientsModel.count) {
            ingredientsModel.remove(index);
            for (var i = 0; i < ingredientsModel.count; i++) {
                ingredientsModel.get(i).srNo = (i + 1);
            }
            selectedRowIndex = -1;
            ingBuilderLogicRoot.ingredientsUpdated(getIngredientsArray());
        }
    }

    function loadRecipe(recipe) {
        if (!recipe) return;
        recipeId = recipe.recipeId || recipe.id || "REC-VPU50-NEW";
        recipeTitle = recipe.title || "New Master Recipe";
        productName = recipe.productName || "Product Batch";
        qtyType = recipe.qtyType || "Fixed";
        selectedRowIndex = -1;

        ingredientsModel.clear();

        // If recipe has explicit ingredients, load them
        if (recipe.ingredients && recipe.ingredients.length > 0) {
            for (var i = 0; i < recipe.ingredients.length; i++) {
                var ing = recipe.ingredients[i];
                var fQty = ing.qty || (ing.qtyValue ? (ing.qtyValue + " " + (ing.qtyUnit || "kg")) : "1.0 kg");
                var fIsa = ing.isa || ing.isaParameters || "Take in vessel and agitate.";
                ingredientsModel.append({
                    srNo: ing.srNo || (i + 1),
                    name: ing.name || "",
                    phase: ing.phase || "Phase A",
                    qty: fQty,
                    isa: fIsa
                });
            }
        } else if (recipe.recipeId === "REC-VPU50-001" && !recipe.isNew) {
            loadSampleShampoo();
        } else if (recipe.recipeId === "REC-VPU50-002" && !recipe.isNew) {
            loadSampleBodyLotion();
        } else if (recipe.recipeId === "REC-VPU50-003" && !recipe.isNew) {
            loadSampleBarrierGel();
        }
    }

    RecipeIngredientBuilderView {
        id: view
        anchors.fill: parent
        recipeTitle: ingBuilderLogicRoot.recipeTitle
        productName: ingBuilderLogicRoot.productName
        qtyType: ingBuilderLogicRoot.qtyType
        ingredientCount: ingredientsModel.count
        hasSelection: ingBuilderLogicRoot.selectedRowIndex >= 0

        ingredientsListView.model: ingredientsModel
        ingredientsListView.delegate: Rectangle {
            id: rowDelegate
            required property int srNo
            required property string name
            required property string phase
            required property string qty
            required property string isa
            required property int index

            readonly property bool isSelected: ingBuilderLogicRoot.selectedRowIndex === rowDelegate.index

            width: view.ingredientsListView.width
            height: 38
            radius: 4
            color: isSelected ? "#164e85" : (rowMouse.containsMouse ? "#0e3359" : (rowDelegate.index % 2 === 0 ? "#071b30" : "#092442"))
            border.color: isSelected ? "#38bdf8" : (rowMouse.containsMouse ? "#2563eb" : "#123860")
            border.width: isSelected ? 2 : 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 8

                // Serial No
                Text {
                    Layout.preferredWidth: 36
                    text: String(rowDelegate.srNo).padStart(2, '0')
                    color: "#94a3b8"
                    font.bold: true
                    font.pixelSize: 11
                    font.family: "Segoe UI"
                }

                // Phase Badge
                Rectangle {
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 22
                    radius: 3
                    color: ingBuilderLogicRoot.getPhaseColor(rowDelegate.phase)

                    Text {
                        anchors.centerIn: parent
                        text: rowDelegate.phase
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 10
                        font.family: "Segoe UI"
                    }
                }

                // Ingredient Name (Highlight on selection)
                Text {
                    Layout.preferredWidth: 220
                    Layout.fillWidth: true
                    text: rowDelegate.name
                    color: rowDelegate.isSelected ? "#38bdf8" : "#ffffff"
                    font.bold: true
                    font.pixelSize: 12
                    font.family: "Segoe UI"
                    elide: Text.ElideRight
                }

                // Quantity / Formula
                Rectangle {
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 22
                    radius: 3
                    color: "#081d33"
                    border.color: "#1d5b94"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: rowDelegate.qty
                        color: "#34d399"
                        font.bold: true
                        font.pixelSize: 11
                        font.family: "Segoe UI"
                    }
                }

                // ISA Process Instructions
                Text {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 320
                    text: rowDelegate.isa
                    color: "#94a3b8"
                    font.pixelSize: 11
                    font.family: "Segoe UI"
                    elide: Text.ElideRight
                }
            }

            MouseArea {
                id: rowMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    ingBuilderLogicRoot.selectedRowIndex = rowDelegate.index;
                }
                onDoubleClicked: {
                    var item = ingredientsModel.get(rowDelegate.index);
                    ingBuilderLogicRoot.editIngredientRequested(item, rowDelegate.index);
                }
            }
        }
    }

    // Stepper Navigation Actions
    MouseArea {
        parent: view.backBtn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: ingBuilderLogicRoot.backToDashboardRequested()
    }

    MouseArea {
        parent: view.nextBtn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            var list = ingBuilderLogicRoot.getIngredientsArray();
            ingBuilderLogicRoot.proceedToTimelineRequested(list);
        }
    }

    // Toolbar Buttons
    MouseArea {
        parent: view.addTriggerRow
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: ingBuilderLogicRoot.addIngredientRequested()
    }

    MouseArea {
        parent: view.editSelectedBtn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (ingBuilderLogicRoot.selectedRowIndex >= 0) {
                var item = ingredientsModel.get(ingBuilderLogicRoot.selectedRowIndex);
                ingBuilderLogicRoot.editIngredientRequested(item, ingBuilderLogicRoot.selectedRowIndex);
            }
        }
    }

    MouseArea {
        parent: view.duplicateSelectedBtn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (ingBuilderLogicRoot.selectedRowIndex >= 0) {
                var item = ingredientsModel.get(ingBuilderLogicRoot.selectedRowIndex);
                ingBuilderLogicRoot.duplicateIngredientRequested(item, ingBuilderLogicRoot.selectedRowIndex);
            }
        }
    }

    MouseArea {
        parent: view.deleteSelectedBtn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (ingBuilderLogicRoot.selectedRowIndex >= 0) {
                var item = ingredientsModel.get(ingBuilderLogicRoot.selectedRowIndex);
                ingBuilderLogicRoot.deleteIngredientRequested(item, ingBuilderLogicRoot.selectedRowIndex);
            }
        }
    }
}
