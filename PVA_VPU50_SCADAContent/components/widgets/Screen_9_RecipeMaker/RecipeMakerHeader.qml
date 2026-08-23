import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

// Master-recipe chrome: identity, lifecycle status, and authoring actions.
Rectangle {
    id: headerRoot
    Layout.fillWidth: true
    Layout.preferredHeight: 56
    color: "#06182c"
    border.color: "#184d7e"
    border.width: 1
    radius: 6

    property string recipeCode: "REC-VPU50-001"
    property string recipeName: "Industrial Shampoo Formulation"
    property string recipeStatus: "DRAFT"
    property int recipeVersion: 1

    property alias recipeSelector: recipeCombo
    property alias newButton: btnNew
    property alias saveButton: btnSave
    property alias collaboratorsButton: btnCollab
    property alias submitButton: btnSubmit
    property alias approveButton: btnApprove

    readonly property color statusColor: recipeStatus === "APPROVED" ? "#22c55e"
                                       : (recipeStatus === "IN_REVIEW" ? "#38bdf8"
                                       : (recipeStatus === "DEPRECATED" ? "#ef4444" : "#f59e0b"))
    readonly property string statusLabel: recipeStatus === "IN_REVIEW" ? "IN REVIEW"
                                        : (recipeStatus === "DRAFT" ? "BEING BUILT" : recipeStatus)

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        Rectangle {
            Layout.preferredWidth: 128
            Layout.preferredHeight: 32
            radius: 4
            color: "#0d2b4a"
            border.color: "#00d2ff"
            border.width: 1
            Text {
                anchors.centerIn: parent
                text: "RECIPE MAKER"
                color: "#00d2ff"
                font.bold: true
                font.pixelSize: 11
            }
        }

        ComboBox {
            id: recipeCombo
            Layout.preferredWidth: 280
            Layout.preferredHeight: 34
            model: [
                "REC-VPU50-001 | Industrial Shampoo Formulation",
                "REC-VPU50-002 | Intensive Body Lotion Cream",
                "REC-VPU50-003 | High-Shear Cosmetic Gel"
            ]
        }

        Rectangle {
            Layout.preferredWidth: 52
            Layout.preferredHeight: 24
            radius: 12
            color: "#0f2d4d"
            border.color: "#1d5b94"
            Text {
                anchors.centerIn: parent
                text: "v" + headerRoot.recipeVersion + ".0"
                color: "#38bdf8"
                font.bold: true
                font.pixelSize: 11
            }
        }

        Rectangle {
            Layout.preferredHeight: 24
            Layout.preferredWidth: Math.max(96, statusText.implicitWidth + 18)
            radius: 12
            color: "#0a243f"
            border.color: headerRoot.statusColor
            Text {
                id: statusText
                anchors.centerIn: parent
                text: headerRoot.statusLabel
                color: headerRoot.statusColor
                font.bold: true
                font.pixelSize: 10
            }
        }

        Item { Layout.fillWidth: true }

        ScadaButton {
            id: btnNew
            Layout.preferredWidth: 72
            Layout.preferredHeight: 32
            text: "+ New"
            accentColor: "#154d80"
        }
        ScadaButton {
            id: btnSave
            Layout.preferredWidth: 92
            Layout.preferredHeight: 32
            text: "Save Draft"
            accentColor: "#0f4477"
        }
        ScadaButton {
            id: btnCollab
            Layout.preferredWidth: 118
            Layout.preferredHeight: 32
            text: "Collaborators"
            accentColor: "#0c345a"
        }
        ScadaButton {
            id: btnSubmit
            Layout.preferredWidth: 132
            Layout.preferredHeight: 32
            text: "Submit Review"
            accentColor: "#1d4ed8"
        }
        ScadaButton {
            id: btnApprove
            Layout.preferredWidth: 92
            Layout.preferredHeight: 32
            text: "Approve"
            accentColor: "#166534"
        }
    }
}
