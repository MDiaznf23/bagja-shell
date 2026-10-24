import QtQuick
import QtQuick.Effects

Item {
  id: root

  property url source
  property color color: "white"
  property real size: 16

  implicitWidth: size
  implicitHeight: size

  Image {
    id: img
    anchors.fill: parent
    source: root.source
    sourceSize: Qt.size(root.size * 2, root.size * 2)  // render 2x
    fillMode: Image.PreserveAspectFit
    smooth: true
    mipmap: true
    visible: false
  }

  MultiEffect {
    anchors.fill: img
    source: img
    colorization: 1.0
    colorizationColor: root.color
  }
}
