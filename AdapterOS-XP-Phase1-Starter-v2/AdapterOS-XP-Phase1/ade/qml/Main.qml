import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: window
    width: 900
    height: 560
    minimumWidth: 640
    minimumHeight: 420
    visible: true
    title: "Adapter Desktop Environment — Prototype"
    color: "#e9f1f8"

    Rectangle {
        anchors.fill: parent
        color: "#e9f1f8"

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 42
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#3b8bd4" }
                    GradientStop { position: 1.0; color: "#15549a" }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14

                    Label {
                        text: "AdapterOS XP"
                        color: "white"
                        font.pixelSize: 19
                        font.bold: true
                    }

                    Item { Layout.fillWidth: true }

                    Label {
                        text: "ADE 0.1 — Development Preview"
                        color: "#eaf4ff"
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 18

                ColumnLayout {
                    Layout.preferredWidth: 210
                    Layout.fillHeight: true
                    Layout.margins: 18
                    spacing: 10

                    Label {
                        text: "Welcome"
                        font.pixelSize: 23
                        font.bold: true
                        color: "#174d80"
                    }

                    Label {
                        text: "The Adapter Desktop Environment is starting to take shape."
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        color: "#263746"
                    }

                    Button { text: "Desktop"; Layout.fillWidth: true }
                    Button { text: "Applications"; Layout.fillWidth: true }
                    Button { text: "System"; Layout.fillWidth: true }

                    Item { Layout.fillHeight: true }

                    Label {
                        text: "Linux foundation: Debian 13"
                        color: "#536779"
                        font.pixelSize: 11
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 18
                    radius: 8
                    color: "white"
                    border.color: "#b9cddd"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 12

                        Label {
                            text: "Adapter Desktop Environment"
                            font.pixelSize: 25
                            font.bold: true
                            color: "#174d80"
                        }

                        Label {
                            text: "Phase 1 · Foundation"
                            font.pixelSize: 15
                            color: "#477ba8"
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: "#d6e2eb"
                        }

                        Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            text: "This is the first native Qt Quick application in AdapterOS XP. It runs as a normal Linux desktop application. Window management, the taskbar, Start Menu, and session integration will be implemented in later milestones."
                            color: "#263746"
                        }

                        Item { Layout.fillHeight: true }

                        Label {
                            text: "AdapterOS XP • Built on Debian GNU/Linux"
                            color: "#718596"
                            font.pixelSize: 11
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                color: "#175da5"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 14

                    Button {
                        text: "Adapter"
                        font.bold: true
                    }

                    Label {
                        text: "ADE Development Session"
                        color: "white"
                    }

                    Item { Layout.fillWidth: true }

                    Label {
                        text: Qt.formatTime(new Date(), "hh:mm")
                        color: "white"
                    }
                }
            }
        }
    }
}
