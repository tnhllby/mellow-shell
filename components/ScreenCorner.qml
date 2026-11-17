import QtQuick
import QtQuick.Shapes
import qs.core

// Black fill outside a rounded screen corner (a square minus a quarter circle),
// so the chrome's rounded corners read like the display's own corners.
// corner: "topLeft" | "topRight" | "bottomLeft" | "bottomRight"
Shape {
    id: root

    property string corner: "topLeft"
    property int radius: Theme.chromeShape.outerRadius

    readonly property bool isLeft: corner.endsWith("Left")
    readonly property bool isTop: corner.startsWith("top")
    // The square's corner that touches the screen corner.
    readonly property real cx: isLeft ? 0 : radius
    readonly property real cy: isTop ? 0 : radius

    width: radius
    height: radius
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
        fillColor: Theme.screenCorner
        strokeWidth: -1
        startX: root.cx
        startY: root.cy
        // Along the horizontal edge, round the quarter circle, back along the vertical edge.
        PathLine { x: root.radius - root.cx; y: root.cy }
        PathArc {
            x: root.cx
            y: root.radius - root.cy
            radiusX: root.radius
            radiusY: root.radius
            direction: root.isLeft === root.isTop ? PathArc.Counterclockwise : PathArc.Clockwise
        }
        PathLine { x: root.cx; y: root.cy }
    }
}
