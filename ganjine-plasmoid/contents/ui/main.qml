import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import QtQuick.Controls as QQC2
import "../code/main.js" as Logic

PlasmoidItem {
    id: root

    // Poem data properties
    property var currentPoemMesras: ["", "", "", ""]
    property string currentPoet: ""
    property string poemLink: ""
    property var poemHistory: []

    // Configuration properties
    property int refreshIntervalMinutes: Plasmoid.configuration.refreshInterval || 20
    property color textColor: Plasmoid.configuration.textColor || "#FFFFFF"
    property real textOpacity: Plasmoid.configuration.textOpacity || 1.0
    property color backgroundColor: Plasmoid.configuration.backgroundColor || "#000000"
    property real backgroundOpacity: Plasmoid.configuration.backgroundOpacity !== undefined ? Plasmoid.configuration.backgroundOpacity : 0.5
    property int backgroundRadius: Plasmoid.configuration.backgroundRadius !== undefined ? Plasmoid.configuration.backgroundRadius : 5
    property bool useBackground: Plasmoid.configuration.useBackground || false
    property string fontFamily: Plasmoid.configuration.fontFamily || "Vazirmatn"
    property int fontSize: Plasmoid.configuration.fontSize || 18
    property bool fontBold: {
        var configValue = Plasmoid.configuration.fontBold;
        return configValue === true || configValue === "true" || configValue === 1;
    }
    property bool limitToPoet: Plasmoid.configuration.limitToPoet || false
    property string selectedPoet: Plasmoid.configuration.selectedPoet || "2"
    property int calculatedWidth: 400

    preferredRepresentation: fullRepresentation
    compactRepresentation: null
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    TextMetrics {
        id: mesraMetrics
        font.family: root.fontFamily
        font.pointSize: root.fontSize
        font.bold: root.fontBold
    }

    TextEdit {
        id: clipboardHelper
        width: 0
        height: 0
        opacity: 0
    }

    function calculatePreferredWidth() {
        var maxWidth = 400;
        for (var i = 0; i < root.currentPoemMesras.length; i++) {
            mesraMetrics.text = root.currentPoemMesras[i];
            var mesraWidth = mesraMetrics.boundingRect.width;
            if (mesraWidth > maxWidth) {
                maxWidth = mesraWidth;
            }
        }
        return Math.min(maxWidth + Kirigami.Units.gridUnit * 2, 800);
    }

    onCurrentPoemMesrasChanged: {
        root.calculatedWidth = calculatePreferredWidth();
    }

    function fetchPoem(limitToPoet, selectedPoet) {
        var xhr = new XMLHttpRequest();
        var url = 'http://c.ganjoor.net/beyt.php?a=1';
        if (limitToPoet && selectedPoet) url += '&p=' + selectedPoet;

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var result = Logic.processHtml(xhr.responseText);
                    if (result) {
                        if (root.currentPoemMesras && root.currentPoemMesras.length > 0 && root.currentPoemMesras[0] !== "") {
                            root.poemHistory.push({
                                mesras: root.currentPoemMesras,
                                poet: root.currentPoet,
                                link: root.poemLink
                            });
                            if (root.poemHistory.length > 30) root.poemHistory.shift();

                            var serializedHistory = root.poemHistory.map(JSON.stringify);
                            Plasmoid.configuration.poemHistory = serializedHistory;
                        }
                        root.currentPoemMesras = result.mesras;
                        root.currentPoet = result.poet;
                        root.poemLink = result.link;
                    }
                } else {
                    var fallback = Logic.showFallbackPoem(root.poemHistory);
                    root.currentPoemMesras = fallback.mesras;
                    root.currentPoet = fallback.poet;
                    root.poemLink = fallback.link;
                }
            }
        };

        xhr.onerror = function() {
            var fallback = Logic.showFallbackPoem(root.poemHistory);
            root.currentPoemMesras = fallback.mesras;
            root.currentPoet = fallback.poet;
            root.poemLink = fallback.link;
        };

        xhr.open('GET', url, true);
        xhr.send();
    }

    onFontBoldChanged: {
        Plasmoid.configuration.fontBold = root.fontBold;
    }

    fullRepresentation: Item {
        id: fullRep
        Layout.minimumWidth: 400
        Layout.preferredWidth: root.calculatedWidth
        Layout.minimumHeight: mainLayout.implicitHeight + (Kirigami.Units.gridUnit * 2)
        Layout.preferredHeight: Math.max(350, Layout.minimumHeight)

        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            color: root.backgroundColor
            opacity: root.useBackground ? root.backgroundOpacity : 0
            border.width: 0
            radius: root.backgroundRadius
        }

        Timer {
            id: refreshTimer
            interval: root.refreshIntervalMinutes * 60 * 1000
            running: true
            repeat: true
            onTriggered: root.fetchPoem(root.limitToPoet, root.selectedPoet)
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: root.poemLink ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: if (root.poemLink) Qt.openUrlExternally(root.poemLink)
        }

        ColumnLayout {
            id: mainLayout
            anchors.fill: parent
            anchors.margins: Kirigami.Units.gridUnit
            spacing: Kirigami.Units.smallSpacing

            // Mesra 1 (aligned right)
            QQC2.Label {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                text: root.currentPoemMesras[0]
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignRight
                font.family: root.fontFamily
                font.pointSize: root.fontSize
                font.bold: root.fontBold
                color: root.textColor
                opacity: root.textOpacity
            }

            // Mesra 2 (aligned left)
            QQC2.Label {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
                text: root.currentPoemMesras[1]
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignLeft
                font.family: root.fontFamily
                font.pointSize: root.fontSize
                font.bold: root.fontBold
                color: root.textColor
                opacity: root.textOpacity
            }

            // Mesra 3 (aligned right)
            QQC2.Label {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                text: root.currentPoemMesras[2]
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignRight
                font.family: root.fontFamily
                font.pointSize: root.fontSize
                font.bold: root.fontBold
                color: root.textColor
                opacity: root.textOpacity
                visible: root.currentPoemMesras[2] !== ""
            }

            // Mesra 4 (aligned left)
            QQC2.Label {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
                text: root.currentPoemMesras[3]
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignLeft
                font.family: root.fontFamily
                font.pointSize: root.fontSize
                font.bold: root.fontBold
                color: root.textColor
                opacity: root.textOpacity
                visible: root.currentPoemMesras[3] !== ""
            }

            // Spacer to push poet name and button to the bottom
            Item {
                Layout.fillHeight: true
            }

            // Poet name
            QQC2.Label {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                text: root.currentPoet
                horizontalAlignment: Text.AlignHCenter
                font.family: root.fontFamily
                font.pointSize: root.fontSize * 0.7
                font.bold: root.fontBold
                color: root.textColor
                opacity: root.textOpacity * 0.7
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Kirigami.Units.largeSpacing

                // Previous button
                QQC2.Button {
                    Layout.preferredWidth: root.fontSize * 1.0
                    Layout.preferredHeight: root.fontSize * 1.0
                    enabled: root.poemHistory.length > 0

                    contentItem: Kirigami.Icon {
                        source: "go-previous"
                        anchors.centerIn: parent
                        width: parent.width * 0.8
                        height: parent.height * 0.8
                        Kirigami.Theme.inherit: false
                        Kirigami.Theme.textColor: root.textColor
                        opacity: parent.enabled ? root.textOpacity : 0.3
                    }
                    background: Rectangle { color: "transparent"; radius: 5 }
                    hoverEnabled: true
                    onHoveredChanged: background.color = hovered ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                    
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: i18n("Previous Poem")

                    onClicked: {
                        var result = Logic.showPreviousPoem(root.poemHistory)
                        if (result) {
                            root.currentPoemMesras = result.poem.mesras
                            root.currentPoet = result.poem.poet
                            root.poemLink = result.poem.link
                            root.poemHistory = result.newHistory
                            var serializedHistory = root.poemHistory.map(JSON.stringify)
                            Plasmoid.configuration.poemHistory = serializedHistory
                            refreshTimer.restart()
                        }
                    }
                }

                // Copy button
                QQC2.Button {
                    Layout.preferredWidth: root.fontSize * 1.0
                    Layout.preferredHeight: root.fontSize * 1.0

                    contentItem: Kirigami.Icon {
                        source: "edit-copy"
                        anchors.centerIn: parent
                        width: parent.width * 0.8
                        height: parent.height * 0.8
                        Kirigami.Theme.inherit: false
                        Kirigami.Theme.textColor: root.textColor
                        opacity: root.textOpacity
                    }
                    background: Rectangle { color: "transparent"; radius: 5 }
                    hoverEnabled: true
                    onHoveredChanged: background.color = hovered ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                    
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: i18n("Copy Text")

                    onClicked: {
                        var textToCopy = root.currentPoemMesras.filter(function(m) { return m !== ""; }).join("\n")
                        textToCopy += "\n— " + root.currentPoet
                        clipboardHelper.text = textToCopy
                        clipboardHelper.selectAll()
                        clipboardHelper.copy()
                    }
                }

                // Refresh button
                QQC2.Button {
                    Layout.preferredWidth: root.fontSize * 1.0
                    Layout.preferredHeight: root.fontSize * 1.0

                    contentItem: Kirigami.Icon {
                        source: "view-refresh"
                        anchors.centerIn: parent
                        width: parent.width * 0.8
                        height: parent.height * 0.8
                        Kirigami.Theme.inherit: false
                        Kirigami.Theme.textColor: root.textColor
                        opacity: root.textOpacity
                    }
                    background: Rectangle { color: "transparent"; radius: 5 }
                    hoverEnabled: true
                    onHoveredChanged: background.color = hovered ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                    
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: i18n("Next Poem")

                    onClicked: {
                        refreshTimer.restart()
                        root.fetchPoem(root.limitToPoet, root.selectedPoet)
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        root.poemHistory = Logic.initializeHistory(Plasmoid.configuration.poemHistory || []);
        root.fetchPoem(root.limitToPoet, root.selectedPoet);
    }
}
