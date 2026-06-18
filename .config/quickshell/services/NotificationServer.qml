//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

QtObject {
  id: root
  
  property list<Notification> notifications

  property var history: []
  
  property NotificationServer server: NotificationServer {
    bodySupported: true
    bodyMarkupSupported: true
    actionsSupported: true
    imageSupported: true
    
    onNotification: (notification) => {
      console.log("=== NEW NOTIFICATION ===")
      console.log("App:", notification.appName)
      console.log("Summary:", notification.summary)
      console.log("Body:", notification.body)

      // Save to history
      var entry = {
        appName: notification.appName,
        summary: notification.summary,
        body: notification.body,
        time: Qt.formatTime(new Date(), "hh:mm"),
        timestamp: Date.now()
      }
      var newHistory = root.history.slice()
      newHistory.unshift(entry)
      root.history = newHistory
      
      notification.tracked = true
      
      // CRITICAL FIX
      var temp = []
      for (var i = 0; i < root.notifications.length; i++) {
        temp.push(root.notifications[i])
      }
      temp.push(notification)
      root.notifications = temp
      
      console.log("Total notifications:", root.notifications.length)
      
      // HANDLE CLOSE
      notification.closed.connect(() => {
        console.log("Notification closed:", notification.summary)
        
        // CRITICAL FIX
        var newList = []
        for (var i = 0; i < root.notifications.length; i++) {
          if (root.notifications[i] !== notification) {
            newList.push(root.notifications[i])
          }
        }
        root.notifications = newList
        
        console.log("Remaining notifications:", root.notifications.length)
      })
    }
  }
  
  function dismiss(notification) {
    notification.dismiss()
  }

  function clearHistory() {
    root.history = []
  }
  
  function clearAll() {
    var notifsCopy = []
    for (var i = 0; i < root.notifications.length; i++) {
      notifsCopy.push(root.notifications[i])
    }
    root.notifications = []
    for (var i = 0; i < notifsCopy.length; i++) {
      notifsCopy[i].dismiss()
    }
  }

  function removeFromHistory(index) {
    var newHistory = root.history.slice()
    newHistory.splice(index, 1)
    root.history = newHistory
  }

  function clearAllWithHistory() {
    clearHistory()
    clearAll()
  }
}
