/*
This is a UI file (.ui.qml) for Master Recipe Maker.
Strictly declarative for Qt Design Studio. Interaction lives in Screen_9_RecipeMaker.qml.
Incharge / Supervisor (Level 2) and Administrator (Level 3) only.
*/

import QtQuick
import QtQuick.Layouts
import "../components/widgets/Screen_9_RecipeMaker"
import "../components/modals/Screen_9_RecipeMaker"

Rectangle {
    id: recipeMakerRoot
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#08213b"

    property string selectedRecipeName: "Industrial Shampoo Formulation"
    property string selectedRecipeId: "REC-VPU50-001"
    property string recipeStatus: "DRAFT"
    property int recipeVersion: 1
    property string recipeAuthor: "Process Incharge"
    property string reviewerName: "Shift Supervisor"
    property string approverName: "—"
    property string approvalDate: "—"

    property alias headerBar: header
    property alias tabBar: tabs
    property alias workspace: workspace
    property alias collaboratorsModal: collabModal
    property alias kpiStrip: kpis

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        RecipeMakerHeader {
            id: header
            recipeCode: recipeMakerRoot.selectedRecipeId
            recipeName: recipeMakerRoot.selectedRecipeName
            recipeStatus: recipeMakerRoot.recipeStatus
            recipeVersion: recipeMakerRoot.recipeVersion
        }

        RecipeMakerKpiStrip {
            id: kpis
            stageCount: workspace.stageCount
            taskCount: workspace.taskCount
            holdCount: workspace.holdCount
            estDuration: workspace.estDuration
            vesselTag: workspace.vesselTag
        }

        RecipeMakerTabBar {
            id: tabs
        }

        RecipeMakerWorkspace {
            id: workspace
            currentTab: tabs.currentTab
            recipeStatus: recipeMakerRoot.recipeStatus
            authorName: recipeMakerRoot.recipeAuthor
            reviewerName: recipeMakerRoot.reviewerName
            approverName: recipeMakerRoot.approverName
            approvalDate: recipeMakerRoot.approvalDate
            recipeVersion: recipeMakerRoot.recipeVersion
        }
    }

    RecipeCollaboratorsModal {
        id: collabModal
        anchors.fill: parent
    }
}
