import QtQuick
import QtQuick.Layouts

Rectangle {
  id: notifItem
  
  required property var notification
  
  signal dismissClicked()
  
  height: contentLayout.height + 20
  
  color: Qt.alpha(Colors.notif_popup_bg, Colors.isDark ? 0.8 : 0.7)

  radius: 8
  border.width: 1
  border.color: Colors.outline_variant
  
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
        color: Colors.notif_popup_app_name
        font.pixelSize: 12
        Layout.fillWidth: true
      }
      
      // Close button
      Rectangle {
        width: 20
        height: 20
        color: closeArea.containsMouse ? Colors.notif_popup_close_hovered : Colors.notif_popup_close_bg
        radius: 3
        
        Text {
          anchors.centerIn: parent
          text: "×"
          color: Colors.notif_popup_close_icon
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
      color: Colors.notif_popup_summary
      font.pixelSize: 14
      font.bold: true
      wrapMode: Text.WordWrap
      Layout.fillWidth: true
    }
    
    Text {
      text: notification.body || ""
      color: Colors.notif_popup_body
      font.pixelSize: 12
      wrapMode: Text.WordWrap
      Layout.fillWidth: true
      visible: notification.body !== ""
    }

    Flow {
      Layout.fillWidth: true
      spacing: 8
      visible: notification.actions && notification.actions.length > 0
      
      Repeater {
        model: notification.actions || []
        
        onItemAdded: function(index, item) {
          item.actionTriggered.connect(function(actionObj) {
            actionObj.invoke()             
            notifItem.dismissClicked()     
          })
        }
        
        delegate: Rectangle {
          id: actionBtn
          
          signal actionTriggered(var actionObj)
          
          visible: modelData.text !== "" && modelData.id !== "default"
          width: actionText.implicitWidth + 24
          height: 28
          radius: 14
          color: actionArea.containsMouse ? Colors.notif_popup_action_hovered : Colors.notif_popup_action_bg
          
          Behavior on color { ColorAnimation { duration: 150 } }

          Text {
            id: actionText
            anchors.centerIn: parent
            text: modelData.text || "Action"
            color: actionArea.containsMouse
            ? Colors.notif_popup_action_text_hovered
            : Colors.notif_popup_action_text
            font.pixelSize: 11
            font.bold: true
          }
          
          MouseArea {
            id: actionArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              actionBtn.actionTriggered(modelData)
            }
          }
        }
      }
    }
  }
}
