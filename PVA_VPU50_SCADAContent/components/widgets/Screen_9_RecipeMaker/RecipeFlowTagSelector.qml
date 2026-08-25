pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

Item {
    id: tagSelectorRoot
    implicitWidth: 500
    implicitHeight: 220
    Layout.fillWidth: true

    property var selectedTags: [] // Array of strings e.g. ["Water (9.2 KG)", "EDTA Disodium"]
    property var availableTags: [] // Array of strings e.g. ["Glycerine", "Shell Pol 940", "Phenoxy Ethanol"]
    property string placeholderText: "Type ingredient name and press Enter..."

    signal tagsChanged(var tags)

    function addTag(tag) {
        if (!tag || tag.trim() === "") return;
        var clean = tag.trim();
        var current = selectedTags.slice();
        if (current.indexOf(clean) === -1) {
            current.push(clean);
            selectedTags = current;
            tagsChanged(selectedTags);
        }
    }

    function removeTag(index) {
        var current = selectedTags.slice();
        if (index >= 0 && index < current.length) {
            current.splice(index, 1);
            selectedTags = current;
            tagsChanged(selectedTags);
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // 1. Label & Selected Tags Count
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Selected Ingredients / Materials (" + tagSelectorRoot.selectedTags.length + ")"
                color: "#94a3b8"
                font.pixelSize: 11
                font.bold: true
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "Click '✕' to remove"
                color: "#64748b"
                font.pixelSize: 10
            }
        }

        // 2. Selected Tags Flow Area (Pill Tags with 'x')
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.max(50, selectedFlow.implicitHeight + 16)
            color: "#081d33"
            border.color: "#1d5b94"
            border.width: 1
            radius: 6
            clip: true

            Flickable {
                anchors.fill: parent
                anchors.margins: 6
                contentWidth: width
                contentHeight: selectedFlow.implicitHeight
                clip: true

                Flow {
                    id: selectedFlow
                    width: parent.width
                    spacing: 6

                    Repeater {
                        model: tagSelectorRoot.selectedTags
                        delegate: Rectangle {
                            id: selPill
                            required property string modelData
                            required property int index

                            height: 28
                            implicitWidth: pillRow.implicitWidth + 16
                            radius: 14
                            color: "#164e85"
                            border.color: "#38bdf8"
                            border.width: 1

                            RowLayout {
                                id: pillRow
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: selPill.modelData
                                    color: "#f8fafc"
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                Rectangle {
                                    Layout.preferredWidth: 16
                                    Layout.preferredHeight: 16
                                    radius: 8
                                    color: closeMouse.containsMouse ? "#ef4444" : "#0d365e"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "✕"
                                        color: "#ffffff"
                                        font.pixelSize: 9
                                        font.bold: true
                                    }

                                    MouseArea {
                                        id: closeMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: tagSelectorRoot.removeTag(selPill.index)
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        visible: tagSelectorRoot.selectedTags.length === 0
                        text: "No materials selected yet. Choose from suggestions below or type custom tag."
                        color: "#64748b"
                        font.pixelSize: 11
                        font.italic: true
                        padding: 6
                    }
                }
            }
        }

        // 3. Custom Input Bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            color: "#0c2847"
            border.color: tagInput.activeFocus ? "#38bdf8" : "#1d5b94"
            border.width: 1
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 6
                spacing: 6

                TextInput {
                    id: tagInput
                    Layout.fillWidth: true
                    color: "#ffffff"
                    font.pixelSize: 12
                    selectByMouse: true
                    clip: true

                    Text {
                        anchors.fill: parent
                        text: tagSelectorRoot.placeholderText
                        color: "#64748b"
                        font.pixelSize: 12
                        visible: !tagInput.text && !tagInput.activeFocus
                    }

                    onAccepted: {
                        if (text.trim().length > 0) {
                            tagSelectorRoot.addTag(text);
                            text = "";
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 26
                    Layout.preferredHeight: 24
                    radius: 3
                    color: addBtnMouse.containsMouse ? "#0284c7" : "#0369a1"

                    Text {
                        anchors.centerIn: parent
                        text: "+"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 14
                    }

                    MouseArea {
                        id: addBtnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (tagInput.text.trim().length > 0) {
                                tagSelectorRoot.addTag(tagInput.text);
                                tagInput.text = "";
                            }
                        }
                    }
                }
            }
        }

        // 4. Suggested Materials Section (Pill Tags with '+')
        Text {
            text: "Or select from available recipe ingredients (Screen 2):"
            color: "#94a3b8"
            font.pixelSize: 11
            font.bold: true
        }

        Flickable {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            contentWidth: width
            contentHeight: suggestedFlow.implicitHeight
            clip: true

            Flow {
                id: suggestedFlow
                width: parent.width
                spacing: 6

                Repeater {
                    model: tagSelectorRoot.availableTags
                    delegate: Rectangle {
                        id: sugPill
                        required property string modelData
                        
                        readonly property bool isAlreadySelected: tagSelectorRoot.selectedTags.indexOf(sugPill.modelData) !== -1

                        visible: !isAlreadySelected
                        height: isAlreadySelected ? 0 : 26
                        implicitWidth: isAlreadySelected ? 0 : (sugRow.implicitWidth + 14)
                        radius: 13
                        color: sugMouse.containsMouse ? "#1e3a8a" : "#0f2d4e"
                        border.color: sugMouse.containsMouse ? "#60a5fa" : "#2563eb"
                        border.width: 1

                        RowLayout {
                            id: sugRow
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: sugPill.modelData
                                color: "#e2e8f0"
                                font.pixelSize: 10
                            }

                            Text {
                                text: "+"
                                color: "#38bdf8"
                                font.bold: true
                                font.pixelSize: 12
                            }
                        }

                        MouseArea {
                            id: sugMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: tagSelectorRoot.addTag(sugPill.modelData)
                        }
                    }
                }
            }
        }
    }
}
