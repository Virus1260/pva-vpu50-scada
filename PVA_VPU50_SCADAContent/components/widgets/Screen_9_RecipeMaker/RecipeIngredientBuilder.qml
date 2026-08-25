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

    // Formulation Ingredients ListModel directly matching Body Lotion Formulation (image_cf2be0.jpg)
    ListModel {
        id: ingredientsModel

        // Phase A
        ListElement { srNo: 1; name: "WATER (9.2 KG)"; phase: "A"; qty: "9.2 kg"; isa: "Take in vessel first. Heat till 80-85°C with slow anchor stirring (25 RPM)." }
        ListElement { srNo: 2; name: "DI SODIUM EDTA"; phase: "A"; qty: "0.1 kg"; isa: "Add to aqueous phase and dissolve completely." }
        ListElement { srNo: 3; name: "GLYCERINE"; phase: "A"; qty: "3.0 kg"; isa: "Charge humectant into Phase A under continuous agitation." }
        ListElement { srNo: 4; name: "SHELL POL 940"; phase: "A"; qty: "0.4 kg"; isa: "Slowly disperse carbomer thickener to prevent lump formation." }
        ListElement { srNo: 5; name: "PHENOXY ETHANOL"; phase: "A"; qty: "0.5 kg"; isa: "Preservative addition in aqueous base." }

        // Phase B
        ListElement { srNo: 6; name: "LIGHT LIQUID PARAFFIN"; phase: "B"; qty: "6.0 kg"; isa: "Take Phase B in premix vessel. Heat till 80-85°C." }
        ListElement { srNo: 7; name: "CETO STEARYL ALCOHOL"; phase: "B"; qty: "2.5 kg"; isa: "Melt with oil phase at 80-85°C." }
        ListElement { srNo: 8; name: "MCW (Microcrystalline Wax)"; phase: "B"; qty: "1.0 kg"; isa: "Ensure complete dissolution in oil phase." }
        ListElement { srNo: 9; name: "GLYCERYL STEARATE"; phase: "B"; qty: "2.0 kg"; isa: "Emulsifier addition into oil phase at 80-85°C." }
        ListElement { srNo: 10; name: "STEARIC ACID"; phase: "B"; qty: "2.5 kg"; isa: "Maintain temp of both Phase A & B at 80-85°C. Add Phase B in Phase A with continuous stirring." }

        // Phase C
        ListElement { srNo: 11; name: "SLES 70%"; phase: "C"; qty: "1.5 kg"; isa: "At 55°C add Phase C under gentle vacuum (-300 mbar)." }

        // Phase D
        ListElement { srNo: 12; name: "TRIETHANOLAMINE"; phase: "D"; qty: "0.4 kg"; isa: "At 50°C add Phase D (Neutralizer) for gel network formation." }

        // Phase E
        ListElement { srNo: 13; name: "DMDM HYDANTOIN"; phase: "E"; qty: "0.2 kg"; isa: "At 40-45°C add Phase E preservative & perfume actives." }
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
        ingredientsModel.append({
            srNo: nextSr,
            name: data.name,
            phase: data.phase,
            qty: data.qty,
            isa: data.isa
        });
        selectedRowIndex = ingredientsModel.count - 1;
    }

    function updateIngredient(index, data) {
        if (index >= 0 && index < ingredientsModel.count) {
            var item = ingredientsModel.get(index);
            item.name = data.name;
            item.phase = data.phase;
            item.qty = data.qty;
            item.isa = data.isa;
        }
    }

    function duplicateIngredient(index, data) {
        var nextSr = ingredientsModel.count + 1;
        ingredientsModel.append({
            srNo: nextSr,
            name: data.name,
            phase: data.phase,
            qty: data.qty,
            isa: data.isa
        });
        selectedRowIndex = ingredientsModel.count - 1;
    }

    function deleteIngredient(index) {
        if (index >= 0 && index < ingredientsModel.count) {
            ingredientsModel.remove(index);
            // Re-index srNo
            for (var i = 0; i < ingredientsModel.count; i++) {
                ingredientsModel.get(i).srNo = (i + 1);
            }
            selectedRowIndex = -1;
        }
    }

    function loadRecipe(recipe) {
        if (!recipe) return;
        recipeId = recipe.recipeId || "REC-VPU50-002";
        recipeTitle = recipe.title || "Body Lotion Formulation";
        productName = recipe.productName || "Cosmetic Intensive Body Lotion";
        qtyType = recipe.qtyType || "Fixed";
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

                // Sr No. (01, 02...)
                Text {
                    Layout.preferredWidth: 50
                    text: String(rowDelegate.srNo).padStart(2, '0')
                    color: rowDelegate.isSelected ? "#38bdf8" : "#94a3b8"
                    font.bold: true
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 20; color: "#1d5b94" }

                // Ingredient Name
                Text {
                    Layout.preferredWidth: 260
                    text: rowDelegate.name
                    color: rowDelegate.isSelected ? "#ffffff" : "#f1f5f9"
                    font.bold: true
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 20; color: "#1d5b94" }

                // Phase Badge (A, B, C, D, E)
                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 22
                    radius: 3
                    color: rowDelegate.phase === "A" ? "#0369a1" : (rowDelegate.phase === "B" ? "#b45309" : (rowDelegate.phase === "C" ? "#047857" : (rowDelegate.phase === "D" ? "#7c2d12" : "#6b21a8")))
                    border.color: "#38bdf8"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Phase " + rowDelegate.phase
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 10
                    }
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 20; color: "#1d5b94" }

                // Qty / Ratio
                Text {
                    Layout.preferredWidth: 110
                    text: rowDelegate.qty
                    color: "#34d399"
                    font.bold: true
                    font.pixelSize: 11
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 20; color: "#1d5b94" }

                // ISA Process Instructions
                Text {
                    Layout.fillWidth: true
                    text: rowDelegate.isa
                    color: "#cbd5e1"
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
            }

            MouseArea {
                id: rowMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (ingBuilderLogicRoot.selectedRowIndex === rowDelegate.index) {
                        ingBuilderLogicRoot.selectedRowIndex = -1; // Toggle unselect
                    } else {
                        ingBuilderLogicRoot.selectedRowIndex = rowDelegate.index;
                    }
                }
                onDoubleClicked: {
                    ingBuilderLogicRoot.selectedRowIndex = rowDelegate.index;
                    var item = ingredientsModel.get(rowDelegate.index);
                    ingBuilderLogicRoot.editIngredientRequested(item, rowDelegate.index);
                }
            }
        }
    }

    // Connect trigger row for adding new ingredient
    MouseArea {
        parent: view.addTriggerRow
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: ingBuilderLogicRoot.addIngredientRequested()
    }

    // Connect selection action buttons
    MouseArea {
        parent: view.editSelectedBtn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (ingBuilderLogicRoot.selectedRowIndex >= 0 && ingBuilderLogicRoot.selectedRowIndex < ingredientsModel.count) {
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
            if (ingBuilderLogicRoot.selectedRowIndex >= 0 && ingBuilderLogicRoot.selectedRowIndex < ingredientsModel.count) {
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
            if (ingBuilderLogicRoot.selectedRowIndex >= 0 && ingBuilderLogicRoot.selectedRowIndex < ingredientsModel.count) {
                var item = ingredientsModel.get(ingBuilderLogicRoot.selectedRowIndex);
                ingBuilderLogicRoot.deleteIngredientRequested(item, ingBuilderLogicRoot.selectedRowIndex);
            }
        }
    }

    // Stepper navigation buttons
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
}
