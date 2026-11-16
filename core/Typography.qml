pragma Singleton
import QtQuick
import Quickshell

// Semantic type roles. Families resolve to the first installed candidate so
// the shell still renders on systems without the preferred fonts.
Singleton {
    id: root

    function pick(candidates) {
        const installed = Qt.fontFamilies();
        for (const family of candidates) {
            if (installed.includes(family))
                return family;
        }
        return candidates[candidates.length - 1];
    }

    readonly property string family: pick(["Google Sans Flex", "Roboto Flex", "Roboto", "Noto Sans", "sans-serif"])
    readonly property string monoFamily: pick(["Roboto Mono", "JetBrains Mono", "Noto Sans Mono", "monospace"])
    readonly property string iconFamily: pick(["Material Symbols Rounded", "Material Symbols Outlined"])
    readonly property bool iconsAvailable: Qt.fontFamilies().includes(iconFamily)

    component Role: QtObject {
        required property int size
        property int weight: Font.Normal
        property real tracking: 0
    }

    readonly property Role displayLarge: Role { size: 57 }
    readonly property Role displayMedium: Role { size: 45 }
    readonly property Role headlineLarge: Role { size: 32 }
    readonly property Role headlineMedium: Role { size: 28 }
    readonly property Role titleLarge: Role { size: 22 }
    readonly property Role titleMedium: Role { size: 16; weight: Font.Medium; tracking: 0.15 }
    readonly property Role bodyLarge: Role { size: 16; tracking: 0.5 }
    readonly property Role bodyMedium: Role { size: 14; tracking: 0.25 }
    readonly property Role bodySmall: Role { size: 12; tracking: 0.4 }
    readonly property Role labelLarge: Role { size: 14; weight: Font.Medium; tracking: 0.1 }
    readonly property Role labelMedium: Role { size: 12; weight: Font.Medium; tracking: 0.5 }
    readonly property Role labelSmall: Role { size: 11; weight: Font.Medium; tracking: 0.5 }
}
