import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    // Settings
    property string command: pluginData.command || ""
    property string iconName: pluginData.icon || "info"
    property int refreshInterval: (pluginData.refreshInterval || 10) * 1000
    property string clickCommand: pluginData.clickCommand || ""

    // State
    property string outputText: command === "" ? "Configure me" : "..."

    // Click handler — run clickCommand silently if configured
    pillClickAction: (x, y, width, section, screen) => {
        if (clickCommand !== "") {
            clickProcess.command = ["sh", "-c", root.clickCommand];
            clickProcess.running = true;
        }
    }

    // Process to run the configured command on a timer
    Process {
        id: commandProcess
        command: ["sh", "-c", root.command + "; echo"]
        running: false

        stdout: SplitParser {
            property bool captured: false
            onRead: data => {
                if (!captured) {
                    let line = data.trim();
                    if (line.length > 30) {
                        line = line.substring(0, 30);
                    }
                    root.outputText = line;
                    captured = true;
                }
            }
        }

        onRunningChanged: {
            if (!running && !commandProcess.stdout.captured) {
                root.outputText = "N/A";
            }
        }
    }

    // Process to run the click command silently
    Process {
        id: clickProcess
        running: false
    }

    // Timer to periodically execute the command
    Timer {
        interval: root.refreshInterval
        running: root.command !== ""
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (root.command !== "") {
                commandProcess.stdout.captured = false;
                commandProcess.running = true;
            }
        }
    }

    // Horizontal bar layout
    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            DankIcon {
                name: root.iconName
                size: root.iconSize
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: root.outputText
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // Vertical bar layout
    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS

            DankIcon {
                name: root.iconName
                size: root.iconSize
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: root.outputText
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
