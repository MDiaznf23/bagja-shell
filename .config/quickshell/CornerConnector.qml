import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import "."

QtObject {

  property var topLeft: PanelWindow {
    anchors { top: true; left: true }
    margins { top: -2; left: -2 }
    implicitWidth: 15; implicitHeight: 15
    color: "transparent"

    Shape {
      anchors.fill: parent
      layer.enabled: true; layer.samples: 4
      ShapePath {
        strokeWidth: 0; strokeColor: "transparent"; fillColor: Colors.topbar_gradient1           
        startX: 0; startY: 15
        PathLine { x: 0; y: 0 }
        PathLine { x: 15; y: 0 }
        PathQuad { x: 0; y: 15; controlX: 0; controlY: 0 }
      }
              
      ShapePath {
        strokeWidth: 2         
        strokeColor: Colors.outline_variant  
        fillColor: Colors.outline_variant
        capStyle: ShapePath.RoundCap 
        
        startX: 15; startY: 0 
        PathLine { x: 15; y: 1 }
        PathQuad { 
          x: 1; y: 15
          controlX: 0; controlY: 0 
        }
        PathLine { x: 0; y: 15 }
        PathQuad { 
          x: 15; y: 0
          controlX: 0; controlY: 0 
        }
      }
    }
  }

  property var topRight: PanelWindow {
    anchors { top: true; right: true } 
    margins { top: -2; right: -2 }
    implicitWidth: 15; implicitHeight: 15
    color: "transparent"

    Shape {
      anchors.fill: parent
      layer.enabled: true; layer.samples: 4
      
      transform: Scale { origin.x: 7.5; xScale: -1 } 

      ShapePath {
        strokeWidth: 0; strokeColor: "transparent"; fillColor: Colors.rightbar_gradient1       
        startX: 0; startY: 15
        PathLine { x: 0; y: 0 }
        PathLine { x: 15; y: 0 }
        PathQuad { x: 0; y: 15; controlX: 0; controlY: 0 }
      }
      ShapePath {
        strokeWidth: 2         
        strokeColor: Colors.outline_variant 
        fillColor: Colors.outline_variant 
        capStyle: ShapePath.RoundCap 
        
        startX: 15; startY: 0 
        PathLine { x: 15; y: 1 }
        PathQuad { 
          x: 1; y: 15
          controlX: 0; controlY: 0 
        }
        PathLine { x: 0; y: 15 }
        PathQuad { 
          x: 15; y: 0
          controlX: 0; controlY: 0 
        }
      }
    }
  }

  property var bottomLeft: PanelWindow {
    anchors { bottom: true; left: true }
    margins { bottom: -2; left: -2 }
    implicitWidth: 15; implicitHeight: 15
    color: "transparent"

    Shape {
      anchors.fill: parent
      layer.enabled: true; layer.samples: 4
      ShapePath {
        strokeWidth: 0; strokeColor: "transparent"; fillColor: Colors.bottombar_gradient1
        
        startX: 0; startY: 0
        PathLine { x: 0; y: 15 }
        PathLine { x: 15; y: 15 }
        PathQuad { x: 0; y: 0; controlX: 0; controlY: 15 }
      }
        
      ShapePath {
        strokeWidth: 2         
        strokeColor: Colors.outline_variant 
        fillColor: Colors.outline_variant
        capStyle: ShapePath.RoundCap 
        
        startX: 0; startY: 0 
        PathLine { x: 1; y: 0 }
        PathQuad { x: 15; y: 14; controlX: 0; controlY: 15 }
        PathLine { x: 15; y: 15 }
        PathQuad { x: 0; y: 0; controlX: 0; controlY: 15 }
      }
    }
  }

  property var bottomRight: PanelWindow {
    anchors { bottom: true; right: true }
    margins { bottom: -2; right: -2 }
    implicitWidth: 15; implicitHeight: 15
    color: "transparent"

    Shape {
      anchors.fill: parent
      layer.enabled: true; layer.samples: 4

      transform: Scale { origin.x: 7.5; xScale: -1 } 
      ShapePath {
        strokeWidth: 0; 
        strokeColor: "transparent"; 
        fillColor: Colors.bottombar_gradient6 
        
        startX: 0; startY: 0
        PathLine { x: 0; y: 15 }
        PathLine { x: 15; y: 15 }
        PathQuad { x: 0; y: 0; controlX: 0; controlY: 15 }
      }

      ShapePath {
        strokeWidth: 2         
        strokeColor: Colors.outline_variant 
        fillColor: Colors.outline_variant
        capStyle: ShapePath.RoundCap 
        
        startX: 0; startY: 0 
        PathLine { x: 1; y: 0 }
        PathQuad { x: 15; y: 14; controlX: 0; controlY: 15 }
        PathLine { x: 15; y: 15 }
        PathQuad { x: 0; y: 0; controlX: 0; controlY: 15 }
      }
    }
  }
}
