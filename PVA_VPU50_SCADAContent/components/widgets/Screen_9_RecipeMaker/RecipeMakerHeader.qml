import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

// Master-recipe chrome: identity, lifecycle status, and authoring actions.
Rectangle {
    id: headerRoot
    implicitWidth: 1100
    implicitHeight: 52
    Layout.fillWidth: true
    Layout.preferredHeight: 52
    color: "#06182c"
    border.color: "#184d7e"
    border.width: 1
    radius: 6

    property string recipeCode: "REC-VPU50-001"
    property string recipeName: "Industrial Shampoo Formulation"
    property string recipeStatus: "DRAFT"
    property int recipeVersion: 1

    property alias recipeSelector: recipeCombo

    signal newClicked()
    signal saveClicked()
    signal collabClicked()
    signal submitClicked()
    signal approveClicked()
    signal recipeSelected(int index, string text)

    readonly property color statusColor: recipeStatus === "APPROVED" ? "#22c55e"
                                       : (recipeStatus === "IN_REVIEW" ? "#38bdf8"
                                       : (recipeStatus === "DEPRECATED" ? "#ef4444" : "#f59e0b"))
    readonly property string statusLabel: recipeStatus === "IN_REVIEW" ? "IN REVIEW"
                                        : (recipeStatus === "DRAFT" ? "BEING BUILT" : recipeStatus)

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 8

        Rectangle {
            Layout.preferredWidth: 110
            Layout.preferredHeight: 30
            radius: 4
            color: "#0d2b4a"
            border.color: "#00d2ff"
            border.width: 1
            Text {
                anchors.centerIn: parent
                text: "RECIPE MAKER"
                color: "#00d2ff"
                font.bold: true
                font.pixelSize: 10
            }
        }

        // Custom Dark Styled Recipe ComboBox
        ComboBox {
            id: recipeCombo
            Layout.preferredWidth: 320
            Layout.preferredHeight: 32
            model: [
                "REC-VPU50-001 | Industrial Shampoo Formulation",
                "REC-VPU50-002 | Intensive Body Lotion Cream",
                "REC-VPU50-003 | High-Shear Cosmetic Gel"
            ]
            onActivated: function(index) {
                headerRoot.recipeSelected(index, currentText)
            }

            background: Rectangle {
                color: "#0a243f"
                border.color: recipeCombo.activeFocus ? "#00d2ff" : "#1d5b94"
                border.width: 1
                radius: 4
            }
            contentItem: Text {
                leftPadding: 8
                text: recipeCombo.currentText
                color: "#ffffff"
                font.pixelSize: 11
                font.bold: true
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
            popup: Popup {
                y: recipeCombo.height + 2
                width: recipeCombo.width
                implicitHeight: Math.min(200, contentItem.implicitHeight + 8)
                padding: 2
                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: recipeCombo.popup.visible ? recipeCombo.delegateModel : null
                    currentIndex: recipeCombo.highlightedIndex
                }
                background: Rectangle {
                    color: "#08213b"
                    border.color: "#00d2ff"
                    border.width: 1
                    radius: 4
                }
            }
            delegate: ItemDelegate {
                width: recipeCombo.width
                height: 30
                contentItem: Text {
                    text: modelData
                    color: highlighted ? "#00d2ff" : "#ffffff"
                    font.pixelSize: 10
                    font.bold: highlighted
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: highlighted ? "#155590" : "transparent"
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: 46
            Layout.preferredHeight: 24
            radius: 12
            color: "#0f2d4d"
            border.color: "#1d5b94"
            Text {
                anchors.centerIn: parent
                text: "v" + headerRoot.recipeVersion + ".0"
                color: "#38bdf8"
                font.bold: true
                font.pixelSize: 10
            }
        }

        Rectangle {
            Layout.preferredHeight: 24
            Layout.preferredWidth: Math.max(90, statusText.implicitWidth + 16)
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

        // Action Buttons
        Rectangle {
            id: btnNew
            Layout.preferredWidth: 70
            Layout.preferredHeight: 30
            radius: 4
            color: "#0284c7"
            Text { anchors.centerIn: parent; text: "+ New"; color: "#ffffff"; font.bold: true; font.pixelSize: 11 }
            MouseArea {
                id: mNew
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: headerRoot.newClicked()
            }
            opacity: mNew.containsMouse ? 0.85 : 1.0
        }

        Rectangle {
            id: btnSave
            Layout.preferredWidth: 80
            Layout.preferredHeight: 30
            radius: 4
            color: "#075985"
            border.color: "#38bdf8"
            border.width: 1
            Text { anchors.centerIn: parent; text: "Save Draft"; color: "#ffffff"; font.bold: true; font.pixelSize: 11 }
            MouseArea {
                id: mSave
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: headerRoot.saveClicked()
            }
            opacity: mSave.containsMouse ? 0.85 : 1.0
        }

        Rectangle {
            id: btnCollab
            Layout.preferredWidth: 90
            Layout.preferredHeight: 30
            radius: 4
            color: "#1e293b"
            border.color: "#475569"
            border.width: 1
            Text { anchors.centerIn: parent; text: "Collaborators"; color: "#cbd5e1"; font.bold: true; font.pixelSize: 11 }
            MouseArea {
                id: mCollab
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: headerRoot.collabClicked()
            }
            opacity: mCollab.containsMouse ? 0.85 : 1.0
        }

        Rectangle {
            id: btnSubmit
            Layout.preferredWidth: 95
            Layout.preferredHeight: 30
            radius: 4
            color: "#2563eb"
            Text { anchors.centerIn: parent; text: "Submit Review"; color: "#ffffff"; font.bold: true; font.pixelSize: 11 }
            MouseArea {
                id: mSubmit
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: headerRoot.submitClicked()
            }
            opacity: mSubmit.containsMouse ? 0.85 : 1.0
        }

        Rectangle {
            id: btnApprove
            Layout.preferredWidth: 80
            Layout.preferredHeight: 30
            radius: 4
            color: "#16a34a"
            Text { anchors.centerIn: parent; text: "Approve"; color: "#ffffff"; font.bold: true; font.pixelSize: 11 }
            MouseArea {
                id: mApprove
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: headerRoot.approveClicked()
            }
            opacity: mApprove.containsMouse ? 0.85 : 1.0
        }
    }
}
