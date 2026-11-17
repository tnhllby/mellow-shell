pragma Singleton
import QtQuick
import Quickshell

// Colour helpers: WCAG 2.x contrast checks for generated schemes.
Singleton {
    id: root

    // Foreground/background role pairs that carry text in MELLOW.
    readonly property var textPairs: [
        ["contentSurface", "surface"],
        ["contentSurface", "surfaceContainer"],
        ["contentSurface", "surfaceContainerHighest"],
        ["contentSurfaceVariant", "surfaceContainerLow"],
        ["contentSurfaceVariant", "surfaceContainer"],
        ["contentSurfaceVariant", "surfaceContainerHigh"],
        ["contentSurfaceVariant", "surfaceContainerHighest"],
        ["contentPrimary", "primary"],
        ["contentPrimaryContainer", "primaryContainer"],
        ["contentSecondaryContainer", "secondaryContainer"],
        ["contentError", "error"],
        ["contentErrorContainer", "errorContainer"]
    ]

    function luminance(c) {
        const channel = v => v <= 0.04045 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4);
        return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
    }

    function contrast(foreground, background) {
        const a = luminance(Qt.color(foreground));
        const b = luminance(Qt.color(background));
        return (Math.max(a, b) + 0.05) / (Math.min(a, b) + 0.05);
    }

    // Lowest text contrast in a role map, and the pairs below WCAG AA (4.5:1).
    function check(roles) {
        let lowest = 21;
        const failing = [];
        for (const [fg, bg] of textPairs) {
            if (!roles[fg] || !roles[bg])
                continue;
            const ratio = contrast(roles[fg], roles[bg]);
            lowest = Math.min(lowest, ratio);
            if (ratio < 4.5)
                failing.push(`${fg} on ${bg} (${ratio.toFixed(1)}:1)`);
        }
        return { lowest, failing };
    }
}
