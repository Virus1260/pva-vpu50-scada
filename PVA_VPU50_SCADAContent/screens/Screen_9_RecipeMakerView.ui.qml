/*
This is a UI file (.ui.qml) for 3-Stage Master Recipe Management System.
Strictly declarative for Qt Design Studio. Interaction lives in Screen_9_RecipeMaker.qml.
Compliance: 21 CFR Part 11 / GAMP 5.
*/

import QtQuick
import QtQuick.Layouts
import "../components/widgets"
import "../components/widgets/Screen_9_RecipeMaker/Screen_1_Dashboard"
import "../components/widgets/Screen_9_RecipeMaker/Screen_2_Ingredients"
import "../components/widgets/Screen_9_RecipeMaker/Screen_3_Timeline"
import "../components/modals/Screen_9_RecipeMaker/Screen_1_Dashboard"
import "../components/modals/Screen_9_RecipeMaker/Screen_2_Ingredients"
import "../components/modals/Screen_9_RecipeMaker/Screen_3_Timeline"

Rectangle {
    id: recipeMakerRoot
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#08213b"

    property int currentStage: 0 // 0: Catalog & Metadata, 1: Ingredient Builder, 2: Timeline Designer
    property string activeRecipeTitle: "Body Lotion Formulation"
    property string activeRecipeId: "REC-VPU50-002"
    property string recipeStatus: "APPROVED"
    property int recipeVersion: 1
    property string recipeAuthor: "Process Incharge"

    property alias stage0Btn: tab0Btn
    property alias stage1Btn: tab1Btn
    property alias stage2Btn: tab2Btn

    property alias dashboardScreen: dashboardView
    property alias ingredientScreen: ingredientView
    property alias timelineScreen: timelineView

    property alias metadataModal: metaModal
    property alias ingredientModal: ingModal
    property alias deleteConfirmModal: delModal
    property alias resourceConfigModal: resModal
    property alias manualActivityModal: manModal

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 6

        // 1. Top 3-Stage Process Stepper Navigation Bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 46
            color: "#0b2e52"
            border.color: "#1d5b94"
            border.width: 1
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                ScadaIcon {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    iconName: "recipe_maker"
                }

                Text {
                    text: "RECIPE AUTHORING ENGINE"
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 12
                }

                Item { Layout.fillWidth: true }

                // Stage 1 Tab: Catalog & Metadata
                Rectangle {
                    id: tab0Btn
                    Layout.preferredWidth: 210
                    Layout.preferredHeight: 34
                    radius: 4
                    color: recipeMakerRoot.currentStage === 0 ? "#0284c7" : "#081d33"
                    border.color: recipeMakerRoot.currentStage === 0 ? "#38bdf8" : "#1d5b94"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Rectangle {
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 18
                            radius: 9
                            color: recipeMakerRoot.currentStage === 0 ? "#ffffff" : "#1e3a8a"
                            Text {
                                anchors.centerIn: parent
                                text: "1"
                                color: recipeMakerRoot.currentStage === 0 ? "#0284c7" : "#ffffff"
                                font.bold: true; font.pixelSize: 10
                            }
                        }
                        Text {
                            text: "1. Metadata & Catalog"
                            color: "#ffffff"
                            font.bold: recipeMakerRoot.currentStage === 0
                            font.pixelSize: 11
                        }
                    }
                }

                Text { text: "➔"; color: "#475569"; font.pixelSize: 12 }

                // Stage 2 Tab: Phase-Wise Ingredient Builder
                Rectangle {
                    id: tab1Btn
                    Layout.preferredWidth: 210
                    Layout.preferredHeight: 34
                    radius: 4
                    color: recipeMakerRoot.currentStage === 1 ? "#0284c7" : "#081d33"
                    border.color: recipeMakerRoot.currentStage === 1 ? "#38bdf8" : "#1d5b94"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Rectangle {
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 18
                            radius: 9
                            color: recipeMakerRoot.currentStage === 1 ? "#ffffff" : "#1e3a8a"
                            Text {
                                anchors.centerIn: parent
                                text: "2"
                                color: recipeMakerRoot.currentStage === 1 ? "#0284c7" : "#ffffff"
                                font.bold: true; font.pixelSize: 10
                            }
                        }
                        Text {
                            text: "2. Ingredient Builder"
                            color: "#ffffff"
                            font.bold: recipeMakerRoot.currentStage === 1
                            font.pixelSize: 11
                        }
                    }
                }

                Text { text: "➔"; color: "#475569"; font.pixelSize: 12 }

                // Stage 3 Tab: Video-Editor Timeline Designer
                Rectangle {
                    id: tab2Btn
                    Layout.preferredWidth: 210
                    Layout.preferredHeight: 34
                    radius: 4
                    color: recipeMakerRoot.currentStage === 2 ? "#0284c7" : "#081d33"
                    border.color: recipeMakerRoot.currentStage === 2 ? "#38bdf8" : "#1d5b94"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Rectangle {
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 18
                            radius: 9
                            color: recipeMakerRoot.currentStage === 2 ? "#ffffff" : "#1e3a8a"
                            Text {
                                anchors.centerIn: parent
                                text: "3"
                                color: recipeMakerRoot.currentStage === 2 ? "#0284c7" : "#ffffff"
                                font.bold: true; font.pixelSize: 10
                            }
                        }
                        Text {
                            text: "3. Timeline Designer"
                            color: "#ffffff"
                            font.bold: recipeMakerRoot.currentStage === 2
                            font.pixelSize: 11
                        }
                    }
                }
            }
        }

        // 2. Main Swappable 3-Stage Work Area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#08213b"

            // STAGE 0: Recipe Catalog & Metadata Engine
            RecipeDashboard {
                id: dashboardView
                anchors.fill: parent
                visible: recipeMakerRoot.currentStage === 0
            }

            // STAGE 1: Phase-Wise Ingredient Formulation Builder
            RecipeIngredientBuilder {
                id: ingredientView
                anchors.fill: parent
                visible: recipeMakerRoot.currentStage === 1
            }

            // STAGE 2: Video-Editor Style Recipe Designer Timeline
            RecipeTimelineDesigner {
                id: timelineView
                anchors.fill: parent
                visible: recipeMakerRoot.currentStage === 2
            }
        }
    }

    // =========================================================================
    // MODAL DIALOGS OVERLAYS (Z: 100)
    // =========================================================================

    RecipeMetadataModal {
        id: metaModal
        anchors.fill: parent
    }

    RecipeIngredientModal {
        id: ingModal
        anchors.fill: parent
    }

    RecipeDeleteConfirmModal {
        id: delModal
        anchors.fill: parent
    }

    RecipeResourceConfigModal {
        id: resModal
        anchors.fill: parent
    }

    RecipeManualActivityModal {
        id: manModal
        anchors.fill: parent
    }
}
