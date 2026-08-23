pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../widgets"
import "../../config"

Rectangle {
    id: loginModalRoot
    implicitWidth: 1024
    implicitHeight: 600
    width: 1024
    height: 600
    color: "#bb000000"
    z: 999
    focus: true

    ScadaConfig { id: scadaConfig }

    // Active session details
    property string currentUserId: "operator"
    property string currentUserName: "Line Operator"
    property string currentUserRole: "Operator (Level 1)"
    property int currentUserLevel: 1

    // Target login details
    property string targetUserId: "admin"
    property string targetUserName: "System Administrator"
    property string targetUserRole: "Administrator (Level 5)"
    property int targetUserLevel: 5
    property string targetDescription: "Full unrestricted system access, user management, security audit log export."

    property string enteredPin: ""
    property string errorMessage: ""
    property int failedAttempts: 0

    signal loginSuccess(string userId, string userName, string userRole, int userLevel)
    signal userLoggedOut()
    signal closed()

    // Ensure keyboard focus when modal opens
    onVisibleChanged: {
        if (visible) {
            loginModalRoot.forceActiveFocus();
        }
    }
    Component.onCompleted: {
        if (visible) {
            loginModalRoot.forceActiveFocus();
        }
    }

    // Physical PC Keyboard Event Handler
    Keys.onPressed: function(event) {
        if ((event.key >= Qt.Key_0 && event.key <= Qt.Key_9) || (event.key >= Qt.Key_0 && event.key <= Qt.Key_9)) {
            var digit = (event.key >= Qt.Key_0 && event.key <= Qt.Key_9) ? (event.key - Qt.Key_0).toString() : event.text;
            if (loginModalRoot.enteredPin.length < 8) {
                loginModalRoot.enteredPin += digit;
                loginModalRoot.errorMessage = "";
            }
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            loginModalRoot.verifyLogin();
            event.accepted = true;
        } else if (event.key === Qt.Key_Backspace) {
            if (loginModalRoot.enteredPin.length > 0) {
                loginModalRoot.enteredPin = loginModalRoot.enteredPin.slice(0, -1);
                loginModalRoot.errorMessage = "";
            }
            event.accepted = true;
        } else if (event.key === Qt.Key_Escape) {
            loginModalRoot.closed();
            event.accepted = true;
        } else if (event.key === Qt.Key_Delete) {
            loginModalRoot.enteredPin = "";
            loginModalRoot.errorMessage = "";
            event.accepted = true;
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {} // Block clicks from propagating underneath
    }

    Rectangle {
        id: modalBox
        anchors.centerIn: parent
        width: 640
        height: 520
        color: "#08213b"
        border.color: "#184d7e"
        border.width: 2
        radius: 12
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 10

            // 1. Header Bar with SVG Icon
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                ScadaIcon {
                    iconName: "act_hold"
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22
                }

                Text {
                    text: "USER AUTHENTICATION & ACCESS CONTROL"
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 15
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: 6
                    color: closeMouse.containsMouse ? "#dc2626" : "#0d365e"
                    border.color: closeMouse.containsMouse ? "#ef4444" : "#1d5b94"
                    border.width: 1

                    ScadaIcon {
                        anchors.centerIn: parent
                        iconName: "close_x"
                        width: 14
                        height: 14
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: loginModalRoot.closed()
                    }
                }
            }

            // 2. Active Session Card + Logout Button
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                color: "#0b2a4a"
                border.color: "#1d5b94"
                border.width: 1
                radius: 6

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 10
                    spacing: 10

                    Text {
                        text: "ACTIVE SESSION:"
                        color: "#7dd3fc"
                        font.bold: true
                        font.pixelSize: 11
                    }

                    Text {
                        text: loginModalRoot.currentUserName + " [" + loginModalRoot.currentUserRole + "]"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 12
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    // Logout Button (Resets to default Operator)
                    Rectangle {
                        Layout.preferredWidth: 84
                        Layout.preferredHeight: 30
                        color: logoutMouse.pressed ? "#7f1d1d" : (logoutMouse.containsMouse ? "#b91c1c" : "#dc2626")
                        radius: 4
                        visible: loginModalRoot.currentUserLevel > 1

                        Text {
                            anchors.centerIn: parent
                            text: "LOGOUT"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 11
                        }

                        MouseArea {
                            id: logoutMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                loginModalRoot.currentUserId = "operator";
                                loginModalRoot.currentUserName = "Line Operator";
                                loginModalRoot.currentUserRole = "Operator (Level 1)";
                                loginModalRoot.currentUserLevel = 1;
                                loginModalRoot.enteredPin = "";
                                loginModalRoot.errorMessage = "";
                                loginModalRoot.userLoggedOut();
                                loginModalRoot.closed();
                            }
                        }
                    }
                }
            }

            // 3. User Selection Tabs (5 Roles with Structured Pill Badges)
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: scadaConfig.userList

                    delegate: Rectangle {
                        id: userTabItem
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 46
                        radius: 6
                        color: loginModalRoot.targetUserId === userTabItem.modelData.id ? "#164e85" : (uMouse.containsMouse ? "#124373" : "#0c345a")
                        border.color: loginModalRoot.targetUserId === userTabItem.modelData.id ? "#00d2ff" : (uMouse.containsMouse ? "#3b82f6" : "#1d5b94")
                        border.width: loginModalRoot.targetUserId === userTabItem.modelData.id ? 2 : 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 4
                            spacing: 1

                            Text {
                                text: userTabItem.modelData.id === "operator" ? "Operator" :
                                      userTabItem.modelData.id === "supervisor" ? "Supervisor" :
                                      userTabItem.modelData.id === "qa_officer" ? "QA Officer" :
                                      userTabItem.modelData.id === "engineer" ? "Engineer" : "Admin"
                                color: loginModalRoot.targetUserId === userTabItem.modelData.id ? "#ffffff" : "#cbd5e1"
                                font.bold: loginModalRoot.targetUserId === userTabItem.modelData.id
                                font.pixelSize: 11
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 14
                                radius: 7
                                color: userTabItem.modelData.level >= 5 ? "#ef4444" :
                                       userTabItem.modelData.level === 4 ? "#f97316" :
                                       userTabItem.modelData.level === 3 ? "#eab308" :
                                       userTabItem.modelData.level === 2 ? "#38bdf8" : "#22c55e"

                                Text {
                                    anchors.centerIn: parent
                                    text: "L" + userTabItem.modelData.level
                                    color: "#ffffff"
                                    font.bold: true
                                    font.pixelSize: 9
                                }
                            }
                        }

                        MouseArea {
                            id: uMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                loginModalRoot.targetUserId = userTabItem.modelData.id;
                                loginModalRoot.targetUserName = userTabItem.modelData.name;
                                loginModalRoot.targetUserRole = userTabItem.modelData.role;
                                loginModalRoot.targetUserLevel = userTabItem.modelData.level;
                                loginModalRoot.targetDescription = userTabItem.modelData.description;
                                loginModalRoot.enteredPin = "";
                                loginModalRoot.errorMessage = "";
                                loginModalRoot.forceActiveFocus();
                            }
                        }
                    }
                }
            }

            // 4. Role Description & Target Info Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                color: "#071b30"
                border.color: "#184d7e"
                border.width: 1
                radius: 6

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Text {
                        text: "PERMISSIONS:"
                        color: "#38bdf8"
                        font.bold: true
                        font.pixelSize: 11
                    }

                    Text {
                        text: loginModalRoot.targetDescription
                        color: "#cbd5e1"
                        font.pixelSize: 11
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }
            }

            // 5. Clean PIN Input Display Box
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                color: loginModalRoot.errorMessage !== "" ? "#451a03" : "#05162a"
                border.color: loginModalRoot.errorMessage !== "" ? "#ef4444" : "#00d2ff"
                border.width: 1.5
                radius: 6

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 12

                    Text {
                        text: "ENTER PIN / PASSWORD:"
                        color: "#94a3b8"
                        font.bold: true
                        font.pixelSize: 11
                    }

                    // Masked PIN display dots
                    Text {
                        text: loginModalRoot.enteredPin.length > 0 ? "● ".repeat(loginModalRoot.enteredPin.length) : "••••"
                        color: loginModalRoot.enteredPin.length > 0 ? "#00d2ff" : "#475569"
                        font.bold: true
                        font.pixelSize: 18
                        Layout.fillWidth: true
                    }

                    // Subtle keyboard input indicator
                    Text {
                        text: "Keyboard Active"
                        color: "#38bdf8"
                        font.pixelSize: 10
                        font.bold: true
                    }
                }
            }

            // 6. Dedicated Error / Status Banner
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 24
                color: loginModalRoot.errorMessage !== "" ? "#7f1d1d" : "transparent"
                border.color: loginModalRoot.errorMessage !== "" ? "#ef4444" : "transparent"
                border.width: 1
                radius: 4
                visible: loginModalRoot.errorMessage !== ""

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 6

                    ScadaIcon {
                        iconName: "warning"
                        Layout.preferredWidth: 14
                        Layout.preferredHeight: 14
                    }

                    Text {
                        text: loginModalRoot.errorMessage
                        color: "#fecaca"
                        font.bold: true
                        font.pixelSize: 10
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }
            }

            // 7. On-Screen Touchscreen PIN Keypad
            GridLayout {
                columns: 3
                Layout.fillWidth: true
                Layout.fillHeight: true
                columnSpacing: 8
                rowSpacing: 8

                Repeater {
                    model: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "CLEAR", "0", "LOGIN"]

                    delegate: Rectangle {
                        id: keypadItem
                        required property string modelData
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 6
                        color: keypadItem.modelData === "LOGIN" ? (kMouse.pressed ? "#15803d" : (kMouse.containsMouse ? "#16a34a" : "#22c55e")) :
                               keypadItem.modelData === "CLEAR" ? (kMouse.pressed ? "#991b1b" : (kMouse.containsMouse ? "#dc2626" : "#b91c1c")) :
                               (kMouse.pressed ? "#07203a" : (kMouse.containsMouse ? "#185590" : "#0d365e"))
                        border.color: keypadItem.modelData === "LOGIN" ? "#4ade80" : (keypadItem.modelData === "CLEAR" ? "#f87171" : "#1d5b94")
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: keypadItem.modelData
                            color: keypadItem.modelData === "LOGIN" ? "#ffffff" : "#ffffff"
                            font.bold: true
                            font.pixelSize: keypadItem.modelData.length > 1 ? 12 : 16
                        }

                        MouseArea {
                            id: kMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                loginModalRoot.forceActiveFocus();
                                if (keypadItem.modelData === "CLEAR") {
                                    loginModalRoot.enteredPin = "";
                                    loginModalRoot.errorMessage = "";
                                } else if (keypadItem.modelData === "LOGIN") {
                                    loginModalRoot.verifyLogin();
                                } else {
                                    if (loginModalRoot.enteredPin.length < 8) {
                                        loginModalRoot.enteredPin += keypadItem.modelData;
                                        loginModalRoot.errorMessage = "";
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // --- Authentication Verification Function ---
    function verifyLogin() {
        if (scadaConfig.verifyCredentials(targetUserId, enteredPin)) {
            currentUserId = targetUserId;
            currentUserName = targetUserName;
            currentUserRole = targetUserRole;
            currentUserLevel = targetUserLevel;
            failedAttempts = 0;
            errorMessage = "";
            enteredPin = "";
            loginSuccess(currentUserId, currentUserName, currentUserRole, currentUserLevel);
            closed();
        } else {
            failedAttempts++;
            enteredPin = "";
            errorMessage = "Invalid PIN! Attempt " + failedAttempts + " of 3 (Logged to Audit Trail)";
            loginModalRoot.forceActiveFocus();
        }
    }
}
