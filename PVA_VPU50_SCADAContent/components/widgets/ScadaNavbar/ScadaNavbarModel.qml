import QtQuick

Rectangle {
    id: rootModel
    width: 200
    height: 300
    color: "#08213b"
    visible: false

    // Master definition of all SCADA screens accessible via Navbar
    readonly property var navItems: [
        { id: 0, name: "Control", icon: "status_stack", label: "Control", minLevel: 1 },
        { id: 1, name: "P&ID", icon: "pid_vessel", label: "P&ID", minLevel: 1 },
        { id: 2, name: "Trends", icon: "trends_chart", label: "Trends", minLevel: 1 },
        { id: 3, name: "Alarms", icon: "alarms_bell", label: "Alarms", minLevel: 1 },
        { id: 4, name: "Recipes", icon: "recipes_checklist", label: "Recipes (Run)", minLevel: 1 },
        { id: 5, name: "RecipeMaker", icon: "recipe_maker", label: "Recipe Maker", minLevel: 1 },
        { id: 6, name: "AuditLog", icon: "logs_order", label: "Audit Log", minLevel: 1 },
        { id: 7, name: "Diagnostics", icon: "tools_maintenance", label: "Diagnostics", minLevel: 1 }
    ]
}
