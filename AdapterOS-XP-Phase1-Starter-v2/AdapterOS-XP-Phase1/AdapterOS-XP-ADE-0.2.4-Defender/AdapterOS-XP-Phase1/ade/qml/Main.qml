import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtMultimedia

ApplicationWindow {
    id: root
    width: 1280
    height: 800
    minimumWidth: 960
    minimumHeight: 600
    visible: true
    visibility: Window.FullScreen
    flags: Qt.FramelessWindowHint
    title: "AdapterOS XP — ADE 0.2.4"
    color: "#3977b9"

    property string themeName: "luna"
    property string activeApp: ""
    property bool startMenuOpen: false
    property bool appMinimized: false
    property bool appMaximized: false
    property date currentDateTime: new Date()
    property string clockText: Qt.formatDateTime(new Date(), "h:mm AP")
    property string terminalOutput: "ADAPTEROS XP — ADE TERMINAL 0.2.4\nType 'help' to see available commands.\n\n"
    property string notepadText: "Welcome to AdapterOS XP Notepad.\n\nThis is a simple built-in text editor."
    property string calculatorDisplay: "0"
    property real calculatorStored: 0
    property string calculatorOperator: ""
    property bool calculatorNewNumber: true
    property var processRows: []
    property var taskStats: ({ processCount: 0, memoryUsedMb: 0, memoryTotalMb: 0, memoryAvailableMb: 0, memoryPercent: 0, diskUsedGb: "0", diskTotalGb: "0", diskAvailableGb: "0", diskPercent: 0, uptime: "Unknown", load: "Unknown" })
    property var utilityStats: ({ os: "Loading…", host: "Unknown", kernel: "Unknown", architecture: "Unknown", cpu: "Unknown", uptime: "Unknown" })
    property var networkRows: []
    property int endTaskPid: 0
    property string taskMessage: "Select a process to see its status."
    property var defenderInfo: ({ scannerAvailable: false, updaterAvailable: false, engineVersion: "Checking…", databasePresent: false, databaseUpdated: "Not checked", updaterService: "Unknown", profile: "Conservative signatures" })
    property bool defenderScanning: false
    property string defenderScanPath: ""
    property string defenderMessage: "Ready. Scan Downloads or choose a folder inside your home directory."
    property var defenderDetections: []
    property var defenderQuarantineRows: []
    property string pendingQuarantinePath: ""
    property string pendingRestorePath: ""

    readonly property int taskbarHeight: 44
    readonly property color taskbarTop: themeName === "classic" ? "#d4d0c8" : (themeName === "silver" ? "#bfc9d6" : (themeName === "olive" ? "#adb98d" : "#2b82d7"))
    readonly property color taskbarBottom: themeName === "classic" ? "#b9b6ad" : (themeName === "silver" ? "#8798ad" : (themeName === "olive" ? "#657d43" : "#0752a5"))
    readonly property color titleTop: themeName === "classic" ? "#0b246a" : (themeName === "silver" ? "#6c8aa9" : (themeName === "olive" ? "#718d48" : "#2386e9"))
    readonly property color titleBottom: themeName === "classic" ? "#173a83" : (themeName === "silver" ? "#476b90" : (themeName === "olive" ? "#4c6e2b" : "#0753a7"))
    readonly property color desktopText: "#ffffff"

    function openApp(name) {
        activeApp = name
        appMinimized = false
        appMaximized = false
        startMenuOpen = false
        clickSound.play()
        if (name === "taskmgr") refreshTaskData()
        if (name === "defender") refreshDefenderData()
        if (name === "utilities" || name === "sysinfo" || name === "disk" || name === "network" || name === "clock") refreshUtilityData()
    }

    function refreshTaskData() {
        processRows = adeBackend.processList()
        var updatedStats = adeBackend.systemStats()
        updatedStats.processCount = processRows.length
        taskStats = updatedStats
    }

    function refreshUtilityData() {
        utilityStats = adeBackend.systemStats()
        networkRows = adeBackend.networkInterfaces()
    }

    function refreshDefenderData() {
        defenderInfo = adeBackend.defenderStatus()
        defenderQuarantineRows = adeBackend.defenderQuarantineList()
        if (!defenderScanPath.length)
            defenderScanPath = adeBackend.defenderDefaultScanPath()
    }

    function startDefenderScan() {
        defenderScanning = true
        defenderMessage = "Starting scan…"
        defenderDetections = []
        adeBackend.startDefenderScan(defenderScanPath)
    }

    function closeApp() {
        activeApp = ""
        appMinimized = false
        appMaximized = false
        clickSound.play()
    }

    function appTitle(name) {
        if (name === "terminal") return "ADE Terminal"
        if (name === "snake") return "Games — Snake"
        if (name === "settings") return "Control Panel"
        if (name === "files") return "My Computer"
        if (name === "notepad") return "Untitled — Notepad"
        if (name === "calculator") return "Calculator"
        if (name === "about") return "About AdapterOS XP"
        if (name === "taskmgr") return "Windows Task Manager — ADE"
        if (name === "utilities") return "Utilities Center"
        if (name === "sysinfo") return "System Information"
        if (name === "disk") return "Disk Usage"
        if (name === "network") return "Network Status"
        if (name === "clock") return "Date and Time"
        if (name === "defender") return "AdapterOS Defender"
        return "AdapterOS XP"
    }

    function appIcon(name) {
        if (name === "terminal") return "▣"
        if (name === "snake") return "🐍"
        if (name === "settings") return "⚙"
        if (name === "files") return "🖥"
        if (name === "notepad") return "📝"
        if (name === "calculator") return "🧮"
        if (name === "taskmgr") return "▥"
        if (name === "utilities") return "🧰"
        if (name === "sysinfo") return "ⓘ"
        if (name === "disk") return "💽"
        if (name === "network") return "🌐"
        if (name === "clock") return "🕒"
        if (name === "defender") return "🛡️"
        return "ⓘ"
    }

    function appIndex(name) {
        if (name === "terminal") return 0
        if (name === "snake") return 1
        if (name === "settings") return 2
        if (name === "files") return 3
        if (name === "notepad") return 4
        if (name === "calculator") return 5
        if (name === "about") return 6
        if (name === "taskmgr") return 7
        if (name === "utilities") return 8
        if (name === "sysinfo") return 9
        if (name === "disk") return 10
        if (name === "network") return 11
        if (name === "clock") return 12
        if (name === "defender") return 13
        return 6
    }

    function appendTerminal(text) {
        terminalOutput += text + "\n\n"
    }

    function handleCommand(rawCommand) {
        var command = rawCommand.trim()
        if (!command.length)
            return

        terminalOutput += "ADE> " + command + "\n"
        var response = adeBackend.executeCommand(command)

        if (response.indexOf("@ACTION:") === 0) {
            var action = response.substring(8)
            if (action === "closeapp") {
                closeApp()
            } else if (action === "playsound") {
                clickSound.play()
                appendTerminal("ADE sound test played.")
            } else {
                openApp(action)
            }
        } else if (response.indexOf("@THEME:") === 0) {
            themeName = response.substring(7)
            appendTerminal("Theme changed to " + themeName + ".")
        } else if (response === "@CLEAR") {
            terminalOutput = "ADAPTEROS XP — ADE TERMINAL 0.2.4\nType 'help' to see available commands.\n\n"
        } else {
            if (response.indexOf(" is not an ADE command.") !== -1 || response.indexOf("Unknown app:") === 0)
                errorSound.play()
            appendTerminal(response)
        }
    }

    function calculatorPress(value) {
        if (value === "C") {
            calculatorDisplay = "0"
            calculatorStored = 0
            calculatorOperator = ""
            calculatorNewNumber = true
            return
        }
        if (value === "±") {
            calculatorDisplay = String(Number(calculatorDisplay) * -1)
            return
        }
        if (value === ".") {
            if (calculatorNewNumber) {
                calculatorDisplay = "0."
                calculatorNewNumber = false
            } else if (calculatorDisplay.indexOf(".") === -1) {
                calculatorDisplay += "."
            }
            return
        }
        if (["+", "−", "×", "÷", "="].indexOf(value) !== -1) {
            var current = Number(calculatorDisplay)
            if (value === "=") {
                if (calculatorOperator === "+") current = calculatorStored + current
                else if (calculatorOperator === "−") current = calculatorStored - current
                else if (calculatorOperator === "×") current = calculatorStored * current
                else if (calculatorOperator === "÷") current = current === 0 ? 0 : calculatorStored / current
                calculatorDisplay = String(Number(current.toPrecision(10)))
                calculatorOperator = ""
            } else {
                calculatorStored = current
                calculatorOperator = value
            }
            calculatorNewNumber = true
            return
        }
        if (calculatorNewNumber || calculatorDisplay === "0") {
            calculatorDisplay = value
            calculatorNewNumber = false
        } else {
            calculatorDisplay += value
        }
    }

    SoundEffect {
        id: startupSound
        source: "qrc:/sounds/adapter-startup.wav"
        volume: 0.42
    }
    SoundEffect {
        id: clickSound
        source: "qrc:/sounds/ui-click.wav"
        volume: 0.26
    }
    SoundEffect {
        id: errorSound
        source: "qrc:/sounds/ui-error.wav"
        volume: 0.32
    }

    Component.onCompleted: startupSound.play()

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            root.currentDateTime = new Date()
            root.clockText = Qt.formatDateTime(root.currentDateTime, "h:mm AP")
        }
    }

    Timer {
        interval: 4000
        repeat: true
        running: root.activeApp === "taskmgr"
        onTriggered: root.refreshTaskData()
    }

    Connections {
        target: adeBackend
        function onDefenderScanProgress(message) {
            root.defenderMessage = message
        }
        function onDefenderScanFinished(exitCode, summary, detections) {
            root.defenderScanning = false
            root.defenderMessage = summary
            root.defenderDetections = detections
            root.defenderQuarantineRows = adeBackend.defenderQuarantineList()
            root.defenderInfo = adeBackend.defenderStatus()
        }
    }

    Timer {
        id: taskRefreshAfterEnd
        interval: 900
        repeat: false
        onTriggered: root.refreshTaskData()
    }

    Shortcut {
        sequence: "Ctrl+Alt+S"
        onActivated: root.startMenuOpen = !root.startMenuOpen
    }
    Shortcut {
        sequence: "Ctrl+Alt+T"
        onActivated: root.openApp("terminal")
    }

    // Original Luna-era rolling-hills wallpaper, bundled locally for offline Live Mode.
    Image {
        id: desktopWallpaper
        anchors.fill: parent
        source: "qrc:/wallpapers/adapteros-luna-hills.jpg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        smooth: true

        Rectangle {
            anchors.fill: parent
            color: "#102a4d"
            opacity: 0.06
        }
    }

    // Desktop shortcuts
    Repeater {
        model: [
            { label: "My Computer", icon: "🖥️", app: "files" },
            { label: "ADE Terminal", icon: "▣", app: "terminal" },
            { label: "Games", icon: "🎮", app: "snake" },
            { label: "Control Panel", icon: "⚙️", app: "settings" },
            { label: "Notepad", icon: "📝", app: "notepad" },
            { label: "Calculator", icon: "🧮", app: "calculator" },
            { label: "Task Manager", icon: "▥", app: "taskmgr" },
            { label: "Utilities", icon: "🧰", app: "utilities" },
            { label: "Defender", icon: "🛡️", app: "defender" },
            { label: "About ADE", icon: "ⓘ", app: "about" }
        ]

        delegate: Item {
            width: 102
            height: 82
            x: 18 + Math.floor(index / 7) * 108
            y: 18 + (index % 7) * 88
            z: 1

            Rectangle {
                anchors.fill: parent
                color: desktopMouse.containsMouse ? "#664a91d1" : (desktopMouse.pressed ? "#884078c0" : "transparent")
                border.color: desktopMouse.containsMouse ? "#a9d9ff" : "transparent"
                radius: 3
            }
            Column {
                anchors.fill: parent
                spacing: 3
                Text {
                    text: modelData.icon
                    font.pixelSize: 30
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "white"
                    style: Text.Raised
                    styleColor: "#17375d"
                }
                Text {
                    text: modelData.label
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    color: "white"
                    font.pixelSize: 11
                    style: Text.Raised
                    styleColor: "#17375d"
                }
            }
            MouseArea {
                id: desktopMouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onDoubleClicked: root.openApp(modelData.app)
                onClicked: function(mouse) {
                    if (mouse.button === Qt.RightButton)
                        root.startMenuOpen = false
                }
            }
        }
    }

    // Application window frame
    Rectangle {
        id: appWindow
        visible: root.activeApp !== "" && !root.appMinimized
        z: 10
        width: root.appMaximized ? root.width - 22 : Math.min(820, root.width - 100)
        height: root.appMaximized ? root.height - root.taskbarHeight - 22 : Math.min(590, root.height - root.taskbarHeight - 92)
        anchors.centerIn: parent
        radius: 6
        color: "#ece9d8"
        border.color: "#174b83"
        border.width: 2

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                radius: 5
                gradient: Gradient {
                    GradientStop { position: 0; color: "#78baf4" }
                    GradientStop { position: 0.12; color: root.titleTop }
                    GradientStop { position: 0.58; color: root.titleBottom }
                    GradientStop { position: 1; color: "#06427f" }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: 13
                    radius: 5
                    opacity: 0.24
                    gradient: Gradient {
                        GradientStop { position: 0; color: "white" }
                        GradientStop { position: 1; color: "transparent" }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 5
                    spacing: 6

                    Text {
                        text: root.appIcon(root.activeApp)
                        color: "white"
                        font.pixelSize: 17
                    }
                    Label {
                        text: root.appTitle(root.activeApp)
                        color: "white"
                        font.bold: true
                        font.pixelSize: 13
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        width: 24; height: 23; radius: 3
                        gradient: Gradient { GradientStop { position: 0; color: "#8dbce8" } GradientStop { position: 1; color: "#2865a6" } }
                        border.color: "#e8f4ff"
                        Text { anchors.centerIn: parent; text: "_"; color: "white"; font.bold: true }
                        MouseArea { anchors.fill: parent; onClicked: root.appMinimized = true }
                    }
                    Rectangle {
                        width: 24; height: 23; radius: 3
                        gradient: Gradient { GradientStop { position: 0; color: "#8dbce8" } GradientStop { position: 1; color: "#2865a6" } }
                        border.color: "#e8f4ff"
                        Text { anchors.centerIn: parent; text: root.appMaximized ? "❐" : "□"; color: "white"; font.pixelSize: 13 }
                        MouseArea { anchors.fill: parent; onClicked: root.appMaximized = !root.appMaximized }
                    }
                    Rectangle {
                        width: 25; height: 23; radius: 3
                        gradient: Gradient { GradientStop { position: 0; color: "#ff9c8e" } GradientStop { position: 1; color: "#cc3028" } }
                        border.color: "#ffe4df"
                        Text { anchors.centerIn: parent; text: "×"; color: "white"; font.bold: true; font.pixelSize: 16 }
                        MouseArea { anchors.fill: parent; onClicked: root.closeApp() }
                    }
                }
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: root.appIndex(root.activeApp)

                // ADE Terminal
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 7
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#101820"
                            border.color: "#617b8e"
                            radius: 3
                            ScrollView {
                                anchors.fill: parent
                                anchors.margins: 9
                                TextArea {
                                    id: terminalLog
                                    text: root.terminalOutput
                                    readOnly: true
                                    selectByMouse: true
                                    wrapMode: TextArea.Wrap
                                    color: "#b7f2bb"
                                    font.family: "monospace"
                                    font.pixelSize: 12
                                    background: null
                                }
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Label { text: "ADE>"; color: "#175891"; font.bold: true; font.family: "monospace" }
                            TextField {
                                id: terminalInput
                                Layout.fillWidth: true
                                placeholderText: "Enter an ADE command…"
                                font.family: "monospace"
                                onAccepted: {
                                    root.handleCommand(text)
                                    text = ""
                                }
                            }
                            Button { text: "Run"; onClicked: { root.handleCommand(terminalInput.text); terminalInput.text = "" } }
                        }
                        Label {
                            text: "Custom ADE commands only · Type help · Ctrl+Alt+T opens terminal"
                            color: "#687b8c"
                            font.pixelSize: 10
                        }
                    }
                }

                // Snake game
                SnakeGame {
                    onExitRequested: root.closeApp()
                }

                // Control Panel
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 12
                        Label { text: "Appearance and desktop settings"; font.pixelSize: 20; font.bold: true; color: "#164d82" }
                        Label { text: "Choose an ADE theme. Changes apply immediately."; color: "#42596e" }
                        GridLayout {
                            columns: 2
                            rowSpacing: 9
                            columnSpacing: 9
                            Repeater {
                                model: [
                                    { name: "Luna Blue", id: "luna", color: "#176ac0" },
                                    { name: "Silver", id: "silver", color: "#8599ae" },
                                    { name: "Olive", id: "olive", color: "#758c48" },
                                    { name: "Classic", id: "classic", color: "#b8b5ad" }
                                ]
                                delegate: Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 58
                                    radius: 5
                                    color: "#f8fafc"
                                    border.color: root.themeName === modelData.id ? "#1468b3" : "#bacada"
                                    border.width: root.themeName === modelData.id ? 2 : 1
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 9
                                        Rectangle { width: 33; height: 33; radius: 4; color: modelData.color }
                                        Label { text: modelData.name; color: "#243e56"; Layout.fillWidth: true; font.bold: true }
                                        Label { text: root.themeName === modelData.id ? "✓" : ""; color: "#176a39"; font.bold: true }
                                    }
                                    MouseArea { anchors.fill: parent; onClicked: root.themeName = modelData.id }
                                }
                            }
                        }
                        Rectangle { Layout.fillWidth: true; height: 1; color: "#c7d4df" }
                        Label { text: "Adapter Desktop Environment 0.2.4"; font.bold: true; color: "#164d82" }
                        Label { text: "KWin manages windows; ADE provides the visible desktop, Start menu and taskbar."; color: "#536779"; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                        Item { Layout.fillHeight: true }
                    }
                }

                // My Computer / Files foundation
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 12
                        Label { text: "My Computer"; font.pixelSize: 21; font.bold: true; color: "#164d82" }
                        Label { text: "AdapterOS locations"; color: "#536779" }
                        GridLayout {
                            columns: 2
                            Layout.fillWidth: true
                            rowSpacing: 12
                            columnSpacing: 12
                            Repeater {
                                model: [
                                    { icon: "🏠", title: "Home folder", detail: "/home/adapteros" },
                                    { icon: "💾", title: "Filesystem", detail: "/" },
                                    { icon: "📁", title: "Documents", detail: "~/Documents" },
                                    { icon: "⬇️", title: "Downloads", detail: "~/Downloads" }
                                ]
                                delegate: Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 78
                                    color: "#f8fafc"
                                    border.color: "#bdccda"
                                    radius: 5
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        Text { text: modelData.icon; font.pixelSize: 28 }
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            Label { text: modelData.title; font.bold: true; color: "#244866" }
                                            Label { text: modelData.detail; font.pixelSize: 11; color: "#657d91" }
                                        }
                                    }
                                }
                            }
                        }
                        Rectangle { Layout.fillWidth: true; height: 1; color: "#c7d4df" }
                        Label { text: "File browsing is currently a shortcut dashboard; full file operations are planned for a later update."; color: "#536779"; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                        Item { Layout.fillHeight: true }
                    }
                }

                // Notepad
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 9
                        spacing: 7
                        Label { text: "Notepad"; color: "#164d82"; font.bold: true }
                        TextArea {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: root.notepadText
                            onTextChanged: root.notepadText = text
                            wrapMode: TextArea.Wrap
                            selectByMouse: true
                            color: "#172c3d"
                            background: Rectangle { color: "white"; border.color: "#aabccc" }
                        }
                        Label { text: "Text stays available while this live session is running. Live Mode changes are not automatically saved after shutdown."; color: "#687b8c"; font.pixelSize: 10; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                    }
                }

                // Calculator
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 10
                        Label { text: "Calculator"; font.pixelSize: 20; font.bold: true; color: "#164d82" }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 66
                            color: "#fafffc"
                            border.color: "#aabccc"
                            radius: 4
                            Text { anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: root.calculatorDisplay; color: "#1b2d3e"; font.pixelSize: 28; font.family: "monospace" }
                        }
                        GridLayout {
                            Layout.alignment: Qt.AlignHCenter
                            columns: 4
                            rowSpacing: 7
                            columnSpacing: 7
                            Repeater {
                                model: ["7","8","9","÷","4","5","6","×","1","2","3","−","C","0",".","+","±","=","",""]
                                delegate: Rectangle {
                                    Layout.preferredWidth: 76
                                    Layout.preferredHeight: 48
                                    radius: 4
                                    color: modelData === "" ? "transparent" : (["+","−","×","÷","=","C"].indexOf(modelData) >= 0 ? "#d7e8f8" : "#f8fbfd")
                                    border.color: modelData === "" ? "transparent" : "#a9bfd3"
                                    Text { anchors.centerIn: parent; text: modelData; color: "#1f405e"; font.pixelSize: 17; font.bold: true }
                                    MouseArea { anchors.fill: parent; enabled: modelData !== ""; onClicked: root.calculatorPress(modelData) }
                                }
                            }
                        }
                        Item { Layout.fillHeight: true }
                    }
                }

                // About
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 10
                        Label { text: "AdapterOS XP"; font.pixelSize: 26; font.bold: true; color: "#145492" }
                        Label { text: "Adapter Desktop Environment 0.2.4"; font.pixelSize: 16; color: "#3a6d99" }
                        Rectangle { Layout.fillWidth: true; height: 1; color: "#c7d4df" }
                        Label { text: "A community-built desktop experience based on Debian GNU/Linux 13 and Qt 6."; wrapMode: Text.WordWrap; color: "#263d51"; Layout.fillWidth: true }
                        Label { text: "ADE 0.2.4 includes the Luna-inspired desktop, Start menu, taskbar, custom command console, Task Manager, utilities, AdapterOS Defender, Settings, Notepad, Calculator and Snake."; wrapMode: Text.WordWrap; color: "#52687c"; Layout.fillWidth: true }
                        Item { Layout.fillHeight: true }
                        Label { text: "AdapterOS XP • Built with Qt 6 and QML"; color: "#788a99"; font.pixelSize: 11 }
                    }
                }
                // ADE Task Manager: process list and performance overview.
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            Label { text: "Task Manager"; font.pixelSize: 21; font.bold: true; color: "#164d82" }
                            Item { Layout.fillWidth: true }
                            Button { text: "Refresh"; onClicked: root.refreshTaskData() }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            Repeater {
                                model: [
                                    { caption: "PROCESSES", value: String(root.taskStats.processCount) },
                                    { caption: "MEMORY USED", value: String(root.taskStats.memoryUsedMb) + " MB" },
                                    { caption: "UPTIME", value: root.taskStats.uptime }
                                ]
                                delegate: Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 54
                                    color: "#f7fbff"
                                    border.color: "#b8cde0"
                                    radius: 4
                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 2
                                        Label { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.caption; color: "#648099"; font.pixelSize: 9; font.bold: true }
                                        Label { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.value; color: "#164d82"; font.pixelSize: 14; font.bold: true }
                                    }
                                }
                            }
                        }

                        TabBar {
                            id: taskManagerTabs
                            Layout.fillWidth: true
                            TabButton { text: "Processes" }
                            TabButton { text: "Performance" }
                        }

                        StackLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            currentIndex: taskManagerTabs.currentIndex

                            Item {
                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 5
                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 28
                                        color: "#dceaf7"
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 7
                                            anchors.rightMargin: 7
                                            Label { text: "Image name"; color: "#244b6d"; font.bold: true; font.pixelSize: 10; Layout.fillWidth: true }
                                            Label { text: "PID"; color: "#244b6d"; font.bold: true; font.pixelSize: 10; Layout.preferredWidth: 60; horizontalAlignment: Text.AlignRight }
                                            Label { text: "CPU %"; color: "#244b6d"; font.bold: true; font.pixelSize: 10; Layout.preferredWidth: 58; horizontalAlignment: Text.AlignRight }
                                            Label { text: "MEM %"; color: "#244b6d"; font.bold: true; font.pixelSize: 10; Layout.preferredWidth: 58; horizontalAlignment: Text.AlignRight }
                                            Item { Layout.preferredWidth: 84 }
                                        }
                                    }
                                    ListView {
                                        id: processView
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        clip: true
                                        model: root.processRows
                                        spacing: 1
                                        ScrollBar.vertical: ScrollBar {}
                                        delegate: Rectangle {
                                            width: processView.width
                                            height: 34
                                            color: processRowMouse.containsMouse ? "#e5f2ff" : (index % 2 === 0 ? "#ffffff" : "#f5f8fb")
                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 7
                                                anchors.rightMargin: 5
                                                Label { text: modelData.name; color: "#263f54"; font.pixelSize: 11; elide: Text.ElideRight; Layout.fillWidth: true }
                                                Label { text: String(modelData.pid); color: "#526b80"; font.pixelSize: 10; Layout.preferredWidth: 60; horizontalAlignment: Text.AlignRight }
                                                Label { text: modelData.cpu; color: "#526b80"; font.pixelSize: 10; Layout.preferredWidth: 58; horizontalAlignment: Text.AlignRight }
                                                Label { text: modelData.memory; color: "#526b80"; font.pixelSize: 10; Layout.preferredWidth: 58; horizontalAlignment: Text.AlignRight }
                                                Button {
                                                    text: "End task"
                                                    Layout.preferredWidth: 80
                                                    Layout.preferredHeight: 27
                                                    onClicked: {
                                                        root.endTaskPid = modelData.pid
                                                        endTaskDialog.open()
                                                    }
                                                }
                                            }
                                            MouseArea { id: processRowMouse; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
                                        }
                                    }
                                    Label { text: root.taskMessage; color: "#657b8e"; font.pixelSize: 10; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                                }
                            }

                            Item {
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 12
                                    Label { text: "Performance"; color: "#164d82"; font.pixelSize: 18; font.bold: true }
                                    Label { text: "Memory"; color: "#2e4d67"; font.bold: true }
                                    RowLayout {
                                        Layout.fillWidth: true
                                        Label { text: String(root.taskStats.memoryUsedMb) + " MB used"; color: "#40596e" }
                                        Item { Layout.fillWidth: true }
                                        Label { text: String(root.taskStats.memoryPercent) + "%"; color: "#164d82"; font.bold: true }
                                    }
                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 18
                                        radius: 3
                                        color: "#dce5ed"
                                        border.color: "#aebfce"
                                        Rectangle {
                                            width: parent.width * Math.max(0, Math.min(100, Number(root.taskStats.memoryPercent))) / 100
                                            height: parent.height - 4
                                            anchors.left: parent.left
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.leftMargin: 2
                                            radius: 2
                                            color: "#3a91d8"
                                        }
                                    }
                                    Label { text: "Total memory: " + String(root.taskStats.memoryTotalMb) + " MB · Available: " + String(root.taskStats.memoryAvailableMb) + " MB"; color: "#657b8e"; font.pixelSize: 10; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                                    Rectangle { Layout.fillWidth: true; height: 1; color: "#c7d4df" }
                                    Label { text: "System load averages"; color: "#2e4d67"; font.bold: true }
                                    Label { text: root.taskStats.load; color: "#164d82"; font.pixelSize: 20; font.family: "monospace" }
                                    Label { text: "1, 5 and 15 minute load averages reported by the Linux kernel."; color: "#657b8e"; font.pixelSize: 10; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                                    Item { Layout.fillHeight: true }
                                    Label { text: "Values refresh every few seconds while Task Manager is open."; color: "#657b8e"; font.pixelSize: 10 }
                                }
                            }
                        }
                    }

                    Dialog {
                        id: endTaskDialog
                        title: "End process"
                        modal: true
                        standardButtons: Dialog.Yes | Dialog.Cancel
                        width: 360
                        x: (parent.width - width) / 2
                        y: (parent.height - height) / 2
                        Label { text: "Send a close request to process " + root.endTaskPid + "? Unsaved work in that application may be lost."; wrapMode: Text.WordWrap; width: 320; color: "#263d51" }
                        onAccepted: {
                            root.taskMessage = adeBackend.terminateProcess(root.endTaskPid)
                            taskRefreshAfterEnd.restart()
                        }
                    }
                }

                // Utilities Center
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 10
                        Label { text: "Utilities Center"; color: "#164d82"; font.pixelSize: 21; font.bold: true }
                        Label { text: "System tools and information for your AdapterOS session."; color: "#5b7185" }
                        GridLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            columns: 2
                            rowSpacing: 9
                            columnSpacing: 9
                            Repeater {
                                model: [
                                    { title: "Task Manager", description: "Processes and performance", icon: "▥", app: "taskmgr" },
                                    { title: "System Information", description: "Hardware and OS details", icon: "ⓘ", app: "sysinfo" },
                                    { title: "Disk Usage", description: "Storage space and filesystem", icon: "💽", app: "disk" },
                                    { title: "Network Status", description: "Network adapters and link state", icon: "🌐", app: "network" },
                                    { title: "Clock and Calendar", description: "Date, time and uptime", icon: "🕒", app: "clock" },
                                    { title: "Calculator", description: "Basic arithmetic", icon: "🧮", app: "calculator" }
                                ]
                                delegate: Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 78
                                    radius: 5
                                    color: utilityCardMouse.containsMouse ? "#e5f2ff" : "#f8fbfe"
                                    border.color: utilityCardMouse.containsMouse ? "#3989d7" : "#b9cbdc"
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        Text { text: modelData.icon; font.pixelSize: 27 }
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2
                                            Label { text: modelData.title; color: "#214b6d"; font.bold: true; font.pixelSize: 12 }
                                            Label { text: modelData.description; color: "#647b8e"; font.pixelSize: 10; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                                        }
                                    }
                                    MouseArea { id: utilityCardMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.openApp(modelData.app) }
                                }
                            }
                        }
                    }
                }

                // System Information
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 10
                        Label { text: "System Information"; color: "#164d82"; font.pixelSize: 21; font.bold: true }
                        Label { text: "A summary of this running AdapterOS system."; color: "#5b7185" }
                        GridLayout {
                            columns: 2
                            columnSpacing: 18
                            rowSpacing: 9
                            Layout.fillWidth: true
                            Repeater {
                                model: [
                                    { key: "Operating system", value: root.utilityStats.os },
                                    { key: "Computer name", value: root.utilityStats.host },
                                    { key: "Processor", value: root.utilityStats.cpu },
                                    { key: "Architecture", value: root.utilityStats.architecture },
                                    { key: "Kernel", value: root.utilityStats.kernel },
                                    { key: "Uptime", value: root.utilityStats.uptime }
                                ]
                                delegate: Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 66
                                    color: "#f8fbfe"
                                    border.color: "#c1cfdd"
                                    radius: 4
                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: 3
                                        Label { text: modelData.key; color: "#6a8093"; font.pixelSize: 10 }
                                        Label { text: modelData.value; color: "#234c6d"; font.bold: true; font.pixelSize: 12; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                                    }
                                }
                            }
                        }
                        Item { Layout.fillHeight: true }
                        Button { text: "Refresh information"; onClicked: root.refreshUtilityData() }
                    }
                }

                // Disk Usage
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 12
                        Label { text: "Disk Usage"; color: "#164d82"; font.pixelSize: 21; font.bold: true }
                        Label { text: "Filesystem mounted at /"; color: "#5b7185" }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 126
                            radius: 5
                            color: "#f8fbfe"
                            border.color: "#c1cfdd"
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 9
                                RowLayout {
                                    Layout.fillWidth: true
                                    Label { text: "Used space"; color: "#244c6c"; font.bold: true }
                                    Item { Layout.fillWidth: true }
                                    Label { text: String(root.utilityStats.diskPercent) + "%"; color: "#164d82"; font.bold: true }
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 20
                                    radius: 3
                                    color: "#dce5ed"
                                    border.color: "#aebfce"
                                    Rectangle {
                                        width: parent.width * Math.max(0, Math.min(100, Number(root.utilityStats.diskPercent))) / 100
                                        height: parent.height - 4
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.leftMargin: 2
                                        radius: 2
                                        color: "#3a91d8"
                                    }
                                }
                                Label { text: root.utilityStats.diskUsedGb + " GB used of " + root.utilityStats.diskTotalGb + " GB"; color: "#40596e" }
                                Label { text: root.utilityStats.diskAvailableGb + " GB available · " + root.utilityStats.filesystem; color: "#687d8f"; font.pixelSize: 10 }
                            }
                        }
                        Label { text: "Live Mode uses a temporary writable layer. Storage shown here belongs to the running live environment and may not represent a persistent installation disk."; color: "#687d8f"; wrapMode: Text.WordWrap; Layout.fillWidth: true; font.pixelSize: 10 }
                        Item { Layout.fillHeight: true }
                        Button { text: "Refresh"; onClicked: root.refreshUtilityData() }
                    }
                }

                // Network Status
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 9
                        Label { text: "Network Status"; color: "#164d82"; font.pixelSize: 21; font.bold: true }
                        Label { text: "Detected network interfaces"; color: "#5b7185" }
                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: root.networkRows
                            spacing: 4
                            delegate: Rectangle {
                                width: parent ? parent.width : 0
                                height: 72
                                radius: 4
                                color: "#f8fbfe"
                                border.color: "#c1cfdd"
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 11
                                    Text { text: modelData.wireless ? "📶" : "🌐"; font.pixelSize: 24 }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        Label { text: modelData.name + (modelData.wireless ? " · Wireless" : " · Wired / virtual"); color: "#234c6d"; font.bold: true }
                                        Label { text: "State: " + modelData.state + "   MAC: " + modelData.address; color: "#687d8f"; font.pixelSize: 10; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                                    }
                                    Label { text: modelData.state === "up" ? "Connected" : "Not active"; color: modelData.state === "up" ? "#24743c" : "#9a6540"; font.bold: true; font.pixelSize: 10 }
                                }
                            }
                        }
                        Label { text: "In VirtualBox NAT mode, the guest usually sees a virtual Ethernet adapter. Your host computer manages the physical Wi-Fi connection."; color: "#687d8f"; font.pixelSize: 10; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                        Button { text: "Refresh adapters"; onClicked: root.refreshUtilityData() }
                    }
                }

                // Clock and Calendar
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 22
                        spacing: 12
                        Label { text: "Date and Time"; color: "#164d82"; font.pixelSize: 21; font.bold: true }
                        Item { Layout.fillHeight: true }
                        Label { text: Qt.formatDateTime(root.currentDateTime, "h:mm:ss AP"); color: "#145492"; font.pixelSize: 52; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                        Label { text: Qt.formatDateTime(root.currentDateTime, "dddd, d MMMM yyyy"); color: "#45657f"; font.pixelSize: 18; Layout.alignment: Qt.AlignHCenter }
                        Rectangle { Layout.fillWidth: true; height: 1; color: "#c7d4df" }
                        Label { text: "Session uptime: " + root.utilityStats.uptime; color: "#45657f"; Layout.alignment: Qt.AlignHCenter }
                        Item { Layout.fillHeight: true }
                        Button { text: "Refresh"; Layout.alignment: Qt.AlignHCenter; onClicked: root.refreshUtilityData() }
                    }
                }

                // AdapterOS Defender — conservative on-demand malware scanning
                Item {
                    ScrollView {
                        anchors.fill: parent
                        clip: true
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded
                        ColumnLayout {
                            width: parent.width
                            spacing: 9

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            Rectangle {
                                width: 48; height: 48; radius: 8
                                gradient: Gradient { GradientStop { position: 0; color: "#eff8ff" } GradientStop { position: 1; color: "#c8e4fa" } }
                                border.color: "#9dbedb"
                                Text { anchors.centerIn: parent; text: "🛡️"; font.pixelSize: 29 }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Label { text: "AdapterOS Defender"; color: "#164d82"; font.pixelSize: 21; font.bold: true }
                                Label { text: "Lightweight malware scanning and quarantine"; color: "#5b7185"; font.pixelSize: 11 }
                            }
                            Button { text: "Refresh"; onClicked: root.refreshDefenderData() }
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 3
                            columnSpacing: 7
                            rowSpacing: 7
                            Repeater {
                                model: [
                                    { title: "Scanner", value: root.defenderInfo.scannerAvailable ? root.defenderInfo.engineVersion : "Not installed" },
                                    { title: "Signatures", value: root.defenderInfo.databaseHealth || "Not checked" },
                                    { title: "Auto updates", value: root.defenderInfo.updaterService || "Unknown" }
                                ]
                                delegate: Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 66
                                    color: "#f7fbff"
                                    border.color: "#bdcede"
                                    radius: 4
                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 7
                                        spacing: 3
                                        Label { text: modelData.title; color: "#71879a"; font.pixelSize: 10 }
                                        Label { text: modelData.value; color: "#234d70"; font.bold: true; font.pixelSize: 10; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                                    }
                                }
                            }
                        }

                        Label {
                            Layout.fillWidth: true
                            text: "Last definition update: " + (root.defenderInfo.databaseUpdated || "Not downloaded yet")
                                + (root.defenderInfo.updaterService === "active" ? " · FreshClam is running" : " · FreshClam: " + (root.defenderInfo.updaterService || "unknown"))
                            color: "#687f92"
                            font.pixelSize: 9
                            wrapMode: Text.WordWrap
                        }
                        Label {
                            Layout.fillWidth: true
                            visible: !root.defenderInfo.databasePresent
                            text: "Connect to the internet and allow FreshClam to download its first signature database before scanning."
                            color: "#8a5a21"
                            font.pixelSize: 10
                            wrapMode: Text.WordWrap
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: "#c7d4df"
                        }
                        Label { text: "Scan a file or folder"; color: "#164d82"; font.bold: true; font.pixelSize: 15 }
                        RowLayout {
                            Layout.fillWidth: true
                            TextField {
                                id: defenderPathField
                                Layout.fillWidth: true
                                text: root.defenderScanPath
                                placeholderText: "Path inside your home folder (Downloads by default)"
                                onTextEdited: root.defenderScanPath = text
                            }
                            Button {
                                text: root.defenderScanning ? "Scanning…" : "Scan"
                                enabled: !root.defenderScanning && root.defenderInfo.scannerAvailable && root.defenderInfo.databasePresent
                                onClicked: root.startDefenderScan()
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            color: "#eef5fb"
                            border.color: "#c4d6e6"
                            radius: 4
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                BusyIndicator { running: root.defenderScanning; visible: root.defenderScanning; width: 24; height: 24 }
                                Label { text: root.defenderMessage; color: "#40596e"; wrapMode: Text.WordWrap; Layout.fillWidth: true; font.pixelSize: 10 }
                            }
                        }

                        Label { text: "Detections requiring review"; color: "#164d82"; font.bold: true; font.pixelSize: 14 }
                        ListView {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Math.min(130, Math.max(60, contentHeight))
                            clip: true
                            spacing: 4
                            model: root.defenderDetections
                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 58
                                color: "#fff8ed"
                                border.color: "#e1c79e"
                                radius: 4
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 7
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        Label { text: modelData.signature; color: "#8b4c13"; font.bold: true; font.pixelSize: 11 }
                                        Label { text: modelData.path; color: "#695d4e"; font.pixelSize: 9; elide: Text.ElideMiddle; Layout.fillWidth: true }
                                    }
                                    Button { text: "Quarantine…"; onClicked: { root.pendingQuarantinePath = modelData.path; quarantineConfirm.open() } }
                                }
                            }
                        }
                        Label { visible: root.defenderDetections.length === 0; text: "No detections in this session. A clean scan is not a guarantee that every threat is absent."; color: "#6a7f90"; font.pixelSize: 10; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                        Label { visible: root.defenderDetections.length > 0; text: "A signature match can still be a false positive. Review the file's origin and detection name before quarantining."; color: "#8a5a21"; font.pixelSize: 9; wrapMode: Text.WordWrap; Layout.fillWidth: true }

                        Rectangle { Layout.fillWidth: true; height: 1; color: "#c7d4df" }
                        RowLayout {
                            Layout.fillWidth: true
                            Label { text: "Quarantine"; color: "#164d82"; font.bold: true; font.pixelSize: 14 }
                            Item { Layout.fillWidth: true }
                            Label { text: root.defenderQuarantineRows.length + " item(s)"; color: "#71879a"; font.pixelSize: 10 }
                        }
                        ListView {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Math.min(105, Math.max(40, contentHeight))
                            clip: true
                            spacing: 3
                            model: root.defenderQuarantineRows
                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 48
                                color: "#f8fbfe"
                                border.color: "#c1cfdd"
                                radius: 4
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1
                                        Label { text: modelData.name; color: "#234c6d"; font.bold: true; font.pixelSize: 10 }
                                        Label { text: modelData.originalPath; color: "#71879a"; font.pixelSize: 9; elide: Text.ElideMiddle; Layout.fillWidth: true }
                                    }
                                    Button { text: "Restore…"; onClicked: { root.pendingRestorePath = modelData.path; restoreConfirm.open() } }
                                }
                            }
                        }
                        Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            color: "#64798b"
                            font.pixelSize: 9
                            text: "Conservative profile: PUA detection and heuristic alerts are off by default to reduce false alarms. This can miss some unwanted or heuristic-only detections. Files are never deleted automatically. Scans are limited to your home folder and large archives/time-intensive files may be skipped by scan limits."
                        }
                        Dialog {
                            id: quarantineConfirm
                            title: "Quarantine detected file?"
                            modal: true
                            standardButtons: Dialog.Yes | Dialog.Cancel
                            width: 390
                            Label { width: 340; wrapMode: Text.WordWrap; color: "#263d51"; text: "Move this file into your private ADE quarantine? The file will not be deleted, and it can be restored later if the detection is a false positive.\n\n" + root.pendingQuarantinePath }
                            onAccepted: {
                                root.defenderMessage = adeBackend.quarantineDefenderFile(root.pendingQuarantinePath)
                                if (root.defenderMessage.indexOf("Quarantined safely.") === 0) {
                                    root.defenderQuarantineRows = adeBackend.defenderQuarantineList()
                                    root.defenderDetections = root.defenderDetections.filter(function(item) {
                                        return item.path !== root.pendingQuarantinePath
                                    })
                                }
                            }
                        }
                        Dialog {
                            id: restoreConfirm
                            title: "Restore quarantined file?"
                            modal: true
                            standardButtons: Dialog.Yes | Dialog.Cancel
                            width: 390
                            Label { width: 340; wrapMode: Text.WordWrap; color: "#263d51"; text: "Restore this file to its original location? Only do this if you have reviewed the detection and trust the file.\n\n" + root.pendingRestorePath }
                            onAccepted: {
                                root.defenderMessage = adeBackend.restoreDefenderFile(root.pendingRestorePath)
                                root.defenderQuarantineRows = adeBackend.defenderQuarantineList()
                            }
                        }
                    }
                    }
                }
            }
        }
    }

    // Start menu
    Rectangle {
        id: startMenu
        visible: root.startMenuOpen
        z: 30
        width: 408
        height: Math.min(480, root.height - root.taskbarHeight - 20)
        x: 7
        anchors.bottom: taskbar.top
        color: "#e9f0f8"
        border.color: "#0d4a8c"
        border.width: 2
        radius: 5

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                radius: 5
                gradient: Gradient {
                    GradientStop { position: 0; color: "#65a9ed" }
                    GradientStop { position: 0.16; color: "#3989d7" }
                    GradientStop { position: 1; color: "#064785" }
                }
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 11
                    Text { text: "🖥️"; font.pixelSize: 34 }
                    ColumnLayout {
                        spacing: 1
                        Label { text: "AdapterOS XP"; color: "white"; font.bold: true; font.pixelSize: 17 }
                        Label { text: "Welcome to ADE"; color: "#d8edff"; font.pixelSize: 11 }
                    }
                    Item { Layout.fillWidth: true }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 8
                    spacing: 3
                    Label { text: "Pinned applications"; color: "#6a7c8b"; font.pixelSize: 10; font.bold: true; leftPadding: 5 }
                    Repeater {
                        model: [
                            { title: "ADE Terminal", detail: "Custom command console", icon: "▣", app: "terminal" },
                            { title: "Snake", detail: "Games", icon: "🐍", app: "snake" },
                            { title: "My Computer", detail: "Files and locations", icon: "🖥", app: "files" },
                            { title: "Control Panel", detail: "Change settings", icon: "⚙", app: "settings" },
                            { title: "Notepad", detail: "Text editor", icon: "📝", app: "notepad" },
                            { title: "Calculator", detail: "Calculator", icon: "🧮", app: "calculator" },
                            { title: "Task Manager", detail: "Processes and performance", icon: "▥", app: "taskmgr" },
                            { title: "Utilities Center", detail: "System tools", icon: "🧰", app: "utilities" },
                            { title: "AdapterOS Defender", detail: "Malware scanning and quarantine", icon: "🛡️", app: "defender" }
                        ]
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            color: startItemMouse.containsMouse ? "#d5e9fb" : "transparent"
                            radius: 3
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 5
                                Text { text: modelData.icon; font.pixelSize: 24 }
                                ColumnLayout {
                                    spacing: 0
                                    Label { text: modelData.title; color: "#183e5c"; font.pixelSize: 12; font.bold: true }
                                    Label { text: modelData.detail; color: "#667c8d"; font.pixelSize: 10 }
                                }
                                Item { Layout.fillWidth: true }
                            }
                            MouseArea { id: startItemMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.openApp(modelData.app) }
                        }
                    }
                    Item { Layout.fillHeight: true }
                }

                Rectangle { Layout.fillHeight: true; width: 1; color: "#c2d2e0" }

                ColumnLayout {
                    Layout.preferredWidth: 132
                    Layout.fillHeight: true
                    Layout.margins: 9
                    spacing: 8
                    Label { text: "Places"; color: "#60788d"; font.bold: true; font.pixelSize: 10 }
                    Repeater {
                        model: [
                            { title: "My Computer", app: "files", icon: "🖥" },
                            { title: "Control Panel", app: "settings", icon: "⚙" },
                            { title: "About ADE", app: "about", icon: "ⓘ" },
                            { title: "Security Center", app: "defender", icon: "🛡️" }
                        ]
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 42
                            color: placeMouse.containsMouse ? "#d5e9fb" : "transparent"
                            radius: 3
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 4
                                Text { text: modelData.icon; font.pixelSize: 19 }
                                Label { text: modelData.title; color: "#254b68"; font.pixelSize: 10; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                            }
                            MouseArea { id: placeMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.openApp(modelData.app) }
                        }
                    }
                    Item { Layout.fillHeight: true }
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#c2d2e0" }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 34
                        radius: 4
                        gradient: Gradient { GradientStop { position: 0; color: "#f9fcff" } GradientStop { position: 1; color: "#d9e8f5" } }
                        border.color: "#b3c7d8"
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 5
                            Text { text: "⏻"; color: "#22537b"; font.pixelSize: 17 }
                            Label { text: "Log off"; color: "#244861"; font.pixelSize: 11 }
                            Item { Layout.fillWidth: true }
                        }
                        MouseArea { anchors.fill: parent; onClicked: root.startMenuOpen = false }
                    }
                }
            }
        }
    }

    // Luna-style taskbar
    Rectangle {
        id: taskbar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: root.taskbarHeight
        z: 40
        gradient: Gradient {
            GradientStop { position: 0; color: root.taskbarTop }
            GradientStop { position: 1; color: root.taskbarBottom }
        }
        border.color: root.themeName === "classic" ? "#f5f3ec" : "#5ba0e4"

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 2
            color: root.themeName === "classic" ? "#ffffff" : "#9bcdf3"
            opacity: 0.85
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            spacing: 5

            Rectangle {
                Layout.preferredWidth: 125
                Layout.preferredHeight: 34
                radius: 7
                gradient: Gradient {
                    GradientStop { position: 0; color: "#80d94b" }
                    GradientStop { position: 0.45; color: "#329a20" }
                    GradientStop { position: 1; color: "#176410" }
                }
                border.color: "#b9e9a0"
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: 13
                    radius: 7
                    opacity: 0.22
                    gradient: Gradient {
                        GradientStop { position: 0; color: "white" }
                        GradientStop { position: 1; color: "transparent" }
                    }
                }
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 9
                    spacing: 7
                    Item {
                        width: 19
                        height: 19
                        Grid {
                            anchors.centerIn: parent
                            columns: 2
                            spacing: 2
                            Repeater {
                                model: ["#f44b32", "#75c744", "#2688e5", "#f4c443"]
                                Rectangle { width: 7; height: 7; color: modelData; radius: 1 }
                            }
                        }
                    }
                    Label {
                        text: "start"
                        color: "white"
                        font.bold: true
                        font.italic: true
                        font.pixelSize: 18
                        style: Text.Raised
                        styleColor: "#235c19"
                    }
                    Item { Layout.fillWidth: true }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.startMenuOpen = !root.startMenuOpen
                        clickSound.play()
                    }
                }
            }

            Rectangle { width: 1; height: 27; color: "#7db0df" }

            // Quick Launch shortcuts, inspired by the compact XP toolbar.
            Repeater {
                model: [
                    { icon: "▣", app: "terminal", tip: "ADE Terminal" },
                    { icon: "🗂", app: "files", tip: "My Computer" },
                    { icon: "🎮", app: "snake", tip: "Snake" }
                ]
                delegate: Rectangle {
                    Layout.preferredWidth: 31
                    Layout.preferredHeight: 30
                    radius: 3
                    color: quickLaunchMouse.containsMouse ? "#5599d4" : "#245f9b"
                    border.color: quickLaunchMouse.containsMouse ? "#c6e5ff" : "#6ca8db"
                    Text {
                        anchors.centerIn: parent
                        text: modelData.icon
                        color: "white"
                        font.pixelSize: 17
                    }
                    MouseArea {
                        id: quickLaunchMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.openApp(modelData.app)
                    }
                }
            }

            Rectangle {
                visible: root.activeApp !== ""
                Layout.preferredWidth: 175
                Layout.preferredHeight: 30
                radius: 3
                color: root.appMinimized ? "#1c64a8" : "#397fc1"
                border.color: "#9cc8ef"
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    Text { text: root.appIcon(root.activeApp); color: "white" }
                    Label { text: root.appTitle(root.activeApp); color: "white"; font.pixelSize: 11; elide: Text.ElideRight; Layout.fillWidth: true }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.appMinimized) root.appMinimized = false
                        else root.appMinimized = true
                    }
                }
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                Layout.preferredWidth: 126
                Layout.fillHeight: true
                color: "#16569a"
                border.color: "#7eb4e6"
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 7
                    spacing: 7
                    Text { text: "EN"; color: "#e8f4ff"; font.pixelSize: 10; font.bold: true }
                    Text { text: "◉"; color: "#dcefff"; font.pixelSize: 13 }
                    Text { text: "🔊"; color: "white"; font.pixelSize: 13 }
                    ColumnLayout {
                        spacing: 0
                        Label { text: root.clockText; color: "white"; font.pixelSize: 11 }
                        Label { text: "ADE 0.2.4"; color: "#d5eaff"; font.pixelSize: 8 }
                    }
                }
            }
        }
    }
}
