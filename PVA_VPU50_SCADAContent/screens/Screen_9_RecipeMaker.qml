import QtQuick
import QtQuick.Controls

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
        target: ui.newRecipeBtn
        function onClicked() {
            ui.recipeStatus = "DRAFT";
            ui.recipeVersion = 1;
            scadaMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "incharge", "Created new master recipe draft in Recipe Maker", "RECIPE_AUTHORING");
        }
    }

    Connections {
        target: ui.saveDraftBtn
        function onClicked() {
            ui.recipeStatus = "DRAFT";
            scadaMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "incharge", "Saved draft master recipe: " + ui.selectedRecipeName, "RECIPE_AUTHORING");
        }
    }

    Connections {
        target: ui.approveBtn
        function onClicked() {
            ui.recipeStatus = "APPROVED";
            ui.approvalDate = new Date().toISOString().replace("T", " ").substr(0, 19);
            scadaMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "incharge", "21 CFR Part 11 Electronic Signature: Master Recipe APPROVED for production: " + ui.selectedRecipeName, "ELECTRONIC_SIGNATURE");
        }
    }

    Connections {
        target: ui.deleteBtn
        function onClicked() {
            scadaMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "incharge", "Deleted master recipe draft: " + ui.selectedRecipeName, "RECIPE_AUTHORING");
        }
    }
}
