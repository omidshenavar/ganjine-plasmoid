import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: configRoot

    // Explicitly declare all configuration properties with defaults
    property alias cfg_fontFamily: fontComboBox.currentText
    property int cfg_fontSize: plasmoid.configuration.fontSize || 18
    property bool cfg_fontBold: plasmoid.configuration.fontBold || false
    property color cfg_textColor: plasmoid.configuration.textColor || "#FFFFFF"
    property real cfg_textOpacity: plasmoid.configuration.textOpacity || 1.0
    property color cfg_backgroundColor: plasmoid.configuration.backgroundColor || "#000000"
    property real cfg_backgroundOpacity: plasmoid.configuration.backgroundOpacity || 0.5
    property bool cfg_useBackground: plasmoid.configuration.useBackground || false
    property int cfg_refreshInterval: plasmoid.configuration.refreshInterval || 20
    property bool cfg_limitToPoet: plasmoid.configuration.limitToPoet || false
    property string cfg_selectedPoet: plasmoid.configuration.selectedPoet || "2"

    Kirigami.FormLayout {
        Kirigami.Heading { level: 2; text: i18n("Appearance") }

        QQC2.ComboBox {
            id: fontComboBox
            Kirigami.FormData.label: i18n("Font:")
            model: Qt.fontFamilies()
            currentIndex: {
                var index = model.indexOf(plasmoid.configuration.fontFamily);
                if (index === -1) {
                    index = model.indexOf("Noto Naskh Arabic");
                }
                if (index === -1) {
                    index = model.indexOf("DejaVu Sans");
                }
                if (index === -1) {
                    index = model.indexOf("Arial");
                }
                return index !== -1 ? index : 0;
            }
        }

        QQC2.SpinBox {
            id: fontSizeSpinBox
            Kirigami.FormData.label: i18n("Font Size:")
            from: 8
            to: 72
            value: configRoot.cfg_fontSize
            onValueChanged: configRoot.cfg_fontSize = value
        }

        QQC2.CheckBox {
            id: fontBoldCheckBox
            Kirigami.FormData.label: i18n("Bold Font:")
            checked: configRoot.cfg_fontBold
            onCheckedChanged: configRoot.cfg_fontBold = checked
        }

        KQuickControls.ColorButton {
            id: textColorButton
            Kirigami.FormData.label: i18n("Text Color:")
            color: configRoot.cfg_textColor
            dialogTitle: i18n("Select Text Color")
            onColorChanged: configRoot.cfg_textColor = color
        }

        QQC2.Slider {
            id: textOpacitySlider
            Kirigami.FormData.label: i18n("Text Opacity:")
            from: 0.1
            to: 1.0
            stepSize: 0.1
            value: configRoot.cfg_textOpacity
            onValueChanged: configRoot.cfg_textOpacity = value
        }

        QQC2.CheckBox {
            id: useBackgroundCheckBox
            Kirigami.FormData.label: i18n("Use Custom Background:")
            checked: configRoot.cfg_useBackground
            onCheckedChanged: configRoot.cfg_useBackground = checked
        }

        KQuickControls.ColorButton {
            id: backgroundColorButton
            Kirigami.FormData.label: i18n("Background Color:")
            enabled: configRoot.cfg_useBackground
            color: configRoot.cfg_backgroundColor
            dialogTitle: i18n("Select Background Color")
            onColorChanged: configRoot.cfg_backgroundColor = color
        }

        QQC2.Slider {
            id: backgroundOpacitySlider
            Kirigami.FormData.label: i18n("Background Opacity:")
            enabled: configRoot.cfg_useBackground
            from: 0.1
            to: 1.0
            stepSize: 0.1
            value: configRoot.cfg_backgroundOpacity
            onValueChanged: configRoot.cfg_backgroundOpacity = value
        }

        Kirigami.Heading { level: 2; text: i18n("Options") }

        QQC2.SpinBox {
            id: refreshIntervalSpinBox
            Kirigami.FormData.label: i18n("Refresh Interval (minutes):")
            from: 1
            to: 1000
            stepSize: 5
            value: configRoot.cfg_refreshInterval
            onValueChanged: configRoot.cfg_refreshInterval = value
        }

        QQC2.CheckBox {
            id: limitToPoetCheckBox
            Kirigami.FormData.label: i18n("Limit Poems to Specific Poet:")
            checked: configRoot.cfg_limitToPoet
            onCheckedChanged: configRoot.cfg_limitToPoet = checked
        }

        QQC2.ComboBox {
            id: poetComboBox
            Kirigami.FormData.label: i18n("Selected Poet:")
            enabled: limitToPoetCheckBox.checked
            textRole: "text"
            valueRole: "value"
            model: [
                { text: "حافظ", value: "2" },
                { text: "خیام", value: "3" },
                { text: "ابوسعید ابوالخیر", value: "26" },
                { text: "صائب", value: "22" },
                { text: "سعدی", value: "7" },
                { text: "باباطاهر", value: "28" },
                { text: "مولوی", value: "5" },
                { text: "اوحدی", value: "19" },
                { text: "خواجو", value: "20" },
                { text: "شهریار", value: "35" },
                { text: "عراقی", value: "21" },
                { text: "فروغی بسطامی", value: "32" },
                { text: "سلمان ساوجی", value: "40" },
                { text: "محتشم کاشانی", value: "29" },
                { text: "امیرخسرو دهلوی", value: "34" },
                { text: "سیف فرغانی", value: "31" },
                { text: "عبید زاکانی", value: "33" },
                { text: "هاتف اصفهانی", value: "25" },
                { text: "رهی معیری", value: "41" }
            ]
            currentIndex: {
                var index = 0;
                for (var i = 0; i < model.length; i++) {
                    if (model[i].value === configRoot.cfg_selectedPoet) {
                        index = i;
                        break;
                    }
                }
                return index;
            }
            onActivated: configRoot.cfg_selectedPoet = model[currentIndex].value
        }
    }
}
