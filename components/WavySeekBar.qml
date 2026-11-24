import QtQuick
import QtQuick.Shapes
import qs.core

// Material 3 Expressive style seek bar: the played part is a thick wavy line,
// the rest a flat track, with a pill-shaped handle between them.
// The wave is purely decorative progress styling. It does not represent the
// audio signal, and its motion only indicates that playback is running.
Item {
    id: root

    property real value: 0          // 0..1
    property bool seekable: true
    property bool playing: false
    property real step: 0.02        // keyboard step as a fraction

    // Emitted with the requested fraction when the user releases a drag or presses a key.
    signal seekRequested(real fraction)

    readonly property real shownValue: drag.pressed ? drag.fraction : Math.max(0, Math.min(1, value))
    readonly property real handleX: shownValue * width
    readonly property int stroke: 4
    readonly property int amplitude: 3
    readonly property int wavelength: 28
    readonly property int gap: 6

    implicitHeight: 28
    activeFocusOnTab: seekable
    Accessible.role: Accessible.Slider
    Accessible.name: "Playback position"

    Keys.onLeftPressed: if (seekable) seekRequested(Math.max(0, value - step))
    Keys.onRightPressed: if (seekable) seekRequested(Math.min(1, value + step))

    // Played part: a static wave scrolled sideways, clipped to the played width.
    Item {
        id: played
        anchors.verticalCenter: parent.verticalCenter
        width: Math.max(0, root.handleX - root.gap)
        height: 2 * root.amplitude + root.stroke
        clip: true

        Shape {
            id: wave
            width: root.width + root.wavelength
            height: parent.height
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeColor: Theme.color.tertiary
                strokeWidth: root.stroke
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin
                fillColor: "transparent"

                PathPolyline {
                    path: {
                        const points = [];
                        const mid = wave.height / 2;
                        for (let x = 0; x <= wave.width; x += 2)
                            points.push(Qt.point(x, mid + root.amplitude * Math.sin(2 * Math.PI * x / root.wavelength)));
                        return points;
                    }
                }
            }

            NumberAnimation on x {
                from: 0
                to: -root.wavelength
                duration: 1600
                loops: Animation.Infinite
                running: root.playing && !Motion.reduced
            }
        }
    }

    // Remaining part: flat track.
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        x: Math.min(root.width, root.handleX + root.gap)
        width: Math.max(0, root.width - x)
        height: root.stroke
        radius: height / 2
        color: Theme.color.tertiaryContainer
    }

    // Handle.
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        x: root.handleX - width / 2
        width: root.activeFocus || drag.pressed ? 6 : 4
        height: root.implicitHeight - 4
        radius: width / 2
        color: Theme.color.tertiary
        visible: root.seekable

        Behavior on width {
            MotionNumber { duration: Motion.press }
        }
    }

    FocusRing {
        shown: root.activeFocus
        radius: Theme.shape.xs
    }

    MouseArea {
        id: drag

        property real fraction: 0

        anchors.fill: parent
        enabled: root.seekable
        cursorShape: Qt.PointingHandCursor
        preventStealing: true

        function update(mouseX) {
            fraction = Math.max(0, Math.min(1, mouseX / root.width));
        }

        onPressed: mouse => update(mouse.x)
        onPositionChanged: mouse => update(mouse.x)
        onReleased: root.seekRequested(fraction)
    }
}
