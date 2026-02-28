import QtQuick
import QtQuick.Layouts

Rectangle {
  id: notifItem
  
  required property var notification
  
  signal dismissClicked()
  
  height: contentLayout.height + 20
  
  color: Colors.isDark ? Qt.alpha(Colors.surfaceContainerLow, 0.8) : Qt.alpha(Colors.surface, 0.7)

  radius: 8
  border.width: 1
  border.color: Colors.outlineVariant
  
  ColumnLayout {
    id: contentLayout
    anchors {
      left: parent.left
      right: parent.right
      top: parent.top
      margins: 10
    }
    spacing: 5
    
    RowLayout {
      Layout.fillWidth: true
      
      Text {
        text: notification.appName || "Notification"
        color: Colors.overSurface
        font.pixelSize: 12
        Layout.fillWidth: true
      }
      
      // Close button
      Rectangle {
        width: 20
        height: 20
        color: closeArea.containsMouse ? Colors.errorContainer : Colors.surfaceContainerHigh
        radius: 3
        
        Text {
          anchors.centerIn: parent
          text: "×"
          color: "white"
          font.pixelSize: 16
          font.bold: true
        }
        
        MouseArea {
          id: closeArea
          anchors.fill: parent
          hoverEnabled: true
          onClicked: notifItem.dismissClicked()
        }
      }
    }
    
    Text {
      text: notification.summary || ""
      color: Colors.overSurface
      font.pixelSize: 14
      font.bold: true
      wrapMode: Text.WordWrap
      Layout.fillWidth: true
    }
    
    Text {
      text: notification.body || ""
      color: Colors.overSurface
      font.pixelSize: 12
      wrapMode: Text.WordWrap
      Layout.fillWidth: true
      visible: notification.body !== ""
    }
  }
}
