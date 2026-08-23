import QtQuick

Item {
    id: root
    width: 1166
    height: 630

    property string userRole: "incharge"
    property int userLevel: 2

    Screen_9_RecipeMakerView {
        id: ui
        anchors.fill: parent
    }

    Connections {
        target: ui.headerBar
        function onNewClicked() {
            ui.recipeStatus = "DRAFT"
            ui.recipeVersion = 1
            ui.approverName = "—"
            ui.approvalDate = "—"
            ui.selectedRecipeName = "New Master Recipe"
            scadaMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "incharge", "Created new master recipe draft in Recipe Maker", "RECIPE_AUTHORING")
        }
        function onSaveClicked() {
            ui.recipeStatus = "DRAFT"
            scadaMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "incharge", "Saved draft master recipe: " + ui.selectedRecipeName, "RECIPE_AUTHORING")
        }
        function onSubmitClicked() {
            ui.recipeStatus = "IN_REVIEW"
            ui.reviewerName = "Shift Supervisor"
            scadaMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "incharge", "Submitted master recipe for review: " + ui.selectedRecipeName, "RECIPE_AUTHORING")
        }
        function onApproveClicked() {
            ui.recipeStatus = "APPROVED"
            ui.approverName = "QA / Incharge"
            ui.approvalDate = new Date().toISOString().replace("T", " ").substr(0, 19)
            scadaMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "incharge", "21 CFR Part 11 Electronic Signature: Master Recipe APPROVED for production: " + ui.selectedRecipeName, "ELECTRONIC_SIGNATURE")
        }
        function onCollabClicked() {
            ui.collaboratorsModal.visible = true
        }
        function onRecipeSelected(index, text) {
            ui.selectedRecipeName = text
            scadaMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "incharge", "Opened master recipe: " + text, "RECIPE_AUTHORING")
        }
    }

    Connections {
        target: ui.collaboratorsModal
        function onCancelled() { ui.collaboratorsModal.visible = false }
        function onSent() {
            ui.collaboratorsModal.visible = false
            scadaMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "incharge", "Updated recipe collaborators for " + ui.selectedRecipeName, "RECIPE_AUTHORING")
        }
    }
}
