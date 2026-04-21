import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
  anchors { top: true; bottom: true; right: true }
  implicitWidth: 15 
  color: "transparent"

  Rectangle {
    anchors.fill: parent
    antialiasing: true
    layer.enabled: true
    
    gradient: Gradient {
      orientation: Gradient.Vertical 
      GradientStop { position: 0.0; color: Colors.rightbar_gradient1 }
      GradientStop { position: 0.48; color: Colors.rightbar_gradient2 }
      GradientStop { position: 0.6; color: Colors.rightbar_gradient3 }
      GradientStop { position: 0.87; color: Colors.rightbar_gradient4 }
      GradientStop { position: 0.9; color: Colors.rightbar_gradient5 }
    }

    Rectangle {
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      width: 2               
      border.width: 2 
      border.color: Colors.outline_variant  
      
      anchors.topMargin: 13 
      anchors.bottomMargin: 28
    }
  }
}
