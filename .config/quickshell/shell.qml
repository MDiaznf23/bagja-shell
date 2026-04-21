//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland   

ShellRoot {
  property bool isDashboardVisible: false
  property bool isMenuVisible: false
  property bool isPanelVisible: false
  property bool isWallpaperPickerVisible: false
  property bool isAppLauncherVisible: false
  property bool isOSDPopupVisible: false
  property bool isNotificationPopupVisible: false
  property bool isBluetoothPanelVisible: false
  property bool isWifiPanelVisible: false
  property bool isAudioPanelVisible: false
  property bool isNotificationPanelVisible: false
  property bool isPowerMenuVisible: false
  property bool isClipboardPanelVisible: false
  property bool isShellSettingsVisible: false
  property bool isWorkspaceOverviewVisible: false
  property bool isSnapshotSessionVisible: false
  property bool isLocked: false
  property bool dndEnabled: false
  
  // Notification Server - Singleton instance
  NotificationServer {
    id: notificationServer
    
    property var notificationsMonitor: notificationServer.notifications
    onNotificationsMonitorChanged: {
      if (notificationServer.notifications.length > 0) {
        if (!isNotificationPopupVisible && !isPanelVisible && !isNotificationPanelVisible && !dndEnabled) {
          isNotificationPopupVisible = true
        }
      } 
      else {
        if (isNotificationPopupVisible) {
          notificationPopup.shouldAnimate = false
          notifCloseTimer.start()
        }
      }
    }
  }

  IpcHandler {
    target: "snapshotsession"
    function toggle() {
        if (isSnapshotSessionVisible) {
            snapshotSession.isShowing = false
            snapshotSessionCloseTimer.start()
        } else {
            closeAllPanels()
            closeSecondaryPanels()
            isSnapshotSessionVisible = true
        }
    }
  }

  IpcHandler {
    target: "workspaceoverview"
    function toggle() {
      if (isWorkspaceOverviewVisible) {
        workspaceOverview.isShowing = false
        workspaceOverviewCloseTimer.start()
      } else {
        closeAllPanels()
        closeSecondaryPanels()
        isWorkspaceOverviewVisible = true
      }
    }
  }

  IpcHandler {
    target: "lockscreen"

    function lock() {
        isLocked = true
    }

    function unlock() {
        isLocked = false
    }
  }
  
  IpcHandler {
    target: "wallpaper"
    
    function toggle() {
      if (isWallpaperPickerVisible) {
        wallpaperPickerWindow.isShowing = false
        wallpaperCloseTimer.start()
      } else {
        closeSecondaryPanels()
        isWallpaperPickerVisible = true
      }
    }
  }

  IpcHandler {
    target: "powermenu"
    function display() {
      if (isPowerMenuVisible) {
        powerMenu.isShowing = false
        powerMenuCloseTimer.start()
      } else {
        closeAllPanels()
        closeSecondaryPanels()
        isPowerMenuVisible = true
      }
    }
  }
  
  IpcHandler {
    target: "launcher"
    
    function toggle() {
      if (isAppLauncherVisible) {
        appLauncher.isShowing = false
        closeDelayTimer.start()
      } else {
        isAppLauncherVisible = true
      }
    }
    
    function show() {
      closeAllPanels()
      isAppLauncherVisible = true
    }
    
    function hide() {
      isAppLauncherVisible = false
    }
  }
  
  IpcHandler {
    target: "osd"

    function open() {
      if (!isOSDPopupVisible) {
        closeSecondaryPanels()
        isOSDPopupVisible = true
      } 
      else {
        osdPopup.isShowing = true
        osdPopup.restartTimer()
      }
    }
  }
  
  IpcHandler {
    target: "notifications"
    
    function clearAll() {
      notificationServer.clearAll()
    }
  }

  WlSessionLock {
    id: sessionLock
    locked: isLocked

    WlSessionLockSurface {
      LockScreen {
        anchors.fill: parent
        onUnlocked: isLocked = false
      }
    }
  }

  function closeSecondaryPanels() {
    isOSDPopupVisible = false
    if (isWallpaperPickerVisible) {
      wallpaperPickerWindow.isShowing = false
      wallpaperCloseTimer.start()
    } else {
      isWallpaperPickerVisible = false
    }

    if (isPanelVisible) {
      panelSettings.isShowing = false
      panelCloseTimer.start()
    } else {
      isPanelVisible = false
    }

    if (isWifiPanelVisible) {
      wifiPanel.isShowing = false
      wifiCloseTimer.start()
    } else {
      isWifiPanelVisible = false
    }

    if (isBluetoothPanelVisible) {
      bluetoothPanel.isShowing = false
      bluetoothCloseTimer.start()
    } else {
      isBluetoothPanelVisible = false
    }

    if (isAudioPanelVisible) {
      audioPanel.isShowing = false
      audioCloseTimer.start()
    } else {
      isAudioPanelVisible = false
    }

    if (isNotificationPanelVisible) {
      notificationPanel.isShowing = false
      notificationPanelCloseTimer.start()
    } else {
      isNotificationPanelVisible = false
    }

    if (isClipboardPanelVisible) {
      clipboardPanel.isShowing = false
      clipboardCloseTimer.start()
    } else {
      isClipboardPanelVisible = false
    }
  }

  function closeAllPanels() {
    if (isMenuVisible) {
      appMenu.isShowing = false
      menuCloseTimer.start()
    } else {
      isMenuVisible = false
    }

    if (isAppLauncherVisible) {
      appLauncher.isShowing = false
      closeDelayTimer.start()
    } else {
      isAppLauncherVisible = false
    }

    if (isDashboardVisible) {
      dashboard.isShowing = false
      dashboardCloseTimer.start()
    } else {
      isDashboardVisible = false
    }
  }

  Timer {
    id: workspaceOverviewCloseTimer
    interval: 300
    onTriggered: isWorkspaceOverviewVisible = false
  }

  WorkspaceOverview {
    id: workspaceOverview
    visible: isWorkspaceOverviewVisible
    onRequestClose: {
      workspaceOverview.isShowing = false
      workspaceOverviewCloseTimer.start()
    }
  }

  // Timer
  Timer {
      id: snapshotSessionCloseTimer
      interval: 300
      onTriggered: isSnapshotSessionVisible = false
  }

  // Instance
  SnapshotSession {
      id: snapshotSession
      visible: isSnapshotSessionVisible
      onRequestClose: {
          snapshotSession.isShowing = false
          snapshotSessionCloseTimer.start()
      }
  }

  Timer {
    id: notifCloseTimer
    interval: 300
    onTriggered: isNotificationPopupVisible = false
  }
  
  TopBar {
    id: topBar
    isOpen: isDashboardVisible
    isMenuOpen: isMenuVisible
    anyPanelOpen: isPanelVisible || isWifiPanelVisible || isBluetoothPanelVisible || isAudioPanelVisible || isNotificationPanelVisible || isClipboardPanelVisible
    onToggleClicked: {
      if (isDashboardVisible) {
        dashboard.isShowing = false        
        dashboardCloseTimer.start()       
      } 
      else {
        closeAllPanels()
        isDashboardVisible = true          
      }
    }
    onMenuClicked: {
      if (isMenuVisible) {
        appMenu.isShowing = false
        menuCloseTimer.start()
      } 
      else {
        closeAllPanels()
        isMenuVisible = true
      }
    }

    onClipboardClicked: {
      if (isClipboardPanelVisible) {
        clipboardPanel.isShowing = false
        clipboardCloseTimer.start()
      } else {
        closeSecondaryPanels()
        isClipboardPanelVisible = true
      }
    }
    onPanelClicked: {
      if (isPanelVisible) {
        panelSettings.isShowing = false
        panelCloseTimer.start()   
        notificationServer.clearAll()
      } else {
        closeSecondaryPanels()
        isNotificationPopupVisible = false
        isPanelVisible = true
      }
    }
  }
  
  LeftBar {
    id: leftBar
    menuVisible: isMenuVisible
    launcherVisible: isAppLauncherVisible
  }
  RightBar { id: rightBar }
  BottomBar { id: bottomBar }
  CornerConnector { id: connector }

  Timer {
    id: menuCloseTimer
    interval: 300
    onTriggered: isMenuVisible = false
  }

  Menu {
    id: appMenu
    visible: isMenuVisible
    onRequestClose: {
      appMenu.isShowing = false  
      menuCloseTimer.start()     
    }
    onRequestPowerMenu: {
      appMenu.isShowing = false
      menuCloseTimer.start()
      powerMenuOpenTimer.start()
    }
  }

  Timer {
    id: shellSettingsCloseTimer
    interval: 300
    onTriggered: isShellSettingsVisible = false
  }

  ShellSettings {
    id: shellSettings
    visible: isShellSettingsVisible
    onRequestClose: {
      shellSettings.isShowing = false
      shellSettingsCloseTimer.start()
    }
  }

  Timer {
    id: dashboardCloseTimer
    interval: 300
    onTriggered: isDashboardVisible = false
  }

  Dashboard {
    id: dashboard
    visible: isDashboardVisible
    anchor {
      window: topBar
      edges: Edges.Bottom
      rect: Qt.rect(
        (topBar.width - implicitWidth) / 2 - ( implicitWidth / 2 ),
        -2,
        implicitWidth,
        topBar.implicitHeight
      )
    }
  }

  Timer {
    id: panelCloseTimer
    interval: 300
    onTriggered: isPanelVisible = false
  }

  PanelSettings {
    id: panelSettings
    visible: isPanelVisible
    dndActive: dndEnabled 
    onDndToggled: dndEnabled = !dndEnabled
    onOpenWifi: {
      isPanelVisible = false
      isWifiPanelVisible = true
    }
    onOpenBluetooth: {
      isPanelVisible = false
      isBluetoothPanelVisible = true
    }
    onOpenAudio: {
      isPanelVisible = false
      isAudioPanelVisible = true
    }
    onOpenNotifications: {
      isPanelVisible = false
      isNotificationPanelVisible = true
    }
    notifHistory: notificationServer.history
  }

  Timer {
    id: notificationPanelCloseTimer
    interval: 300
    onTriggered: isNotificationPanelVisible = false
  }

  NotificationPanel {
    id: notificationPanel
    visible: isNotificationPanelVisible
    notifServer: notificationServer
    onRequestClose: {
      notificationPanel.isShowing = false
      notificationPanelCloseTimer.start()
    }
  }

  Timer {
    id: wallpaperCloseTimer
    interval: 300
    onTriggered: isWallpaperPickerVisible = false
  }

  WallpaperPicker {
    id: wallpaperPickerWindow
    visible: isWallpaperPickerVisible
    onRequestClose: {
      wallpaperPickerWindow.isShowing = false
      wallpaperCloseTimer.start()
    }
    onVisibleChanged: if (!visible) isWallpaperPickerVisible = false
  }

  Timer {
    id: clipboardCloseTimer
    interval: 300
    onTriggered: isClipboardPanelVisible = false
  }

  ClipboardPanel {
    id: clipboardPanel
    visible: isClipboardPanelVisible
    onRequestClose: {
      clipboardPanel.isShowing = false
      clipboardCloseTimer.start()
    }
  } 

  Timer {
    id: closeDelayTimer
    interval: 300
    onTriggered: isAppLauncherVisible = false
  }
  
  AppLauncher {
    id: appLauncher
    visible: isAppLauncherVisible
    onRequestClose: {
      isShowing = false
      closeDelayTimer.start()
    }
    onVisibleChanged: if (!visible) isAppLauncherVisible = false
  }

  function startCloseTimer() {
    closeDelayTimer.start()
  }

  OSDPopup {
    id: osdPopup
    visible: isOSDPopupVisible
    onVisibleChanged: if (!visible) isOSDPopupVisible = false
  }
  
  NotificationPopup {
    id: notificationPopup
    notificationServer: notificationServer
    blockingPanelOpen: isPanelVisible || isNotificationPanelVisible 
    shiftDownPanelOpen: isBluetoothPanelVisible || isWifiPanelVisible || isAudioPanelVisible || isClipboardPanelVisible || isWallpaperPickerVisible
    dndActive: dndEnabled
  }

  Timer {
    id: bluetoothCloseTimer
    interval: 300
    onTriggered: isBluetoothPanelVisible = false
  }

  BluetoothPanel {
    id: bluetoothPanel
    visible: isBluetoothPanelVisible
    onRequestClose: {
      bluetoothPanel.isShowing = false
      bluetoothCloseTimer.start()
    }
  }

  Timer {
    id: wifiCloseTimer
    interval: 300
    onTriggered: isWifiPanelVisible = false
  }

  WifiPanel {
    id: wifiPanel
    visible: isWifiPanelVisible
    onRequestClose: {
      wifiPanel.isShowing = false
      wifiCloseTimer.start()
    }
  }

  Timer {
    id: audioCloseTimer
    interval: 300
    onTriggered: isAudioPanelVisible = false
  }

  AudioPanel {
    id: audioPanel
    visible: isAudioPanelVisible
    onRequestClose: {
      audioPanel.isShowing = false
      audioCloseTimer.start()
    }
  }

  Timer {
    id: powerMenuCloseTimer
    interval: 300
    onTriggered: isPowerMenuVisible = false
  }

  Timer {
    id: powerMenuOpenTimer
    interval: 310
    onTriggered: isPowerMenuVisible = true
  }

  // Instance
  PowerMenu {
    id: powerMenu
    visible: isPowerMenuVisible
    onRequestClose: {
      powerMenu.isShowing = false
      powerMenuCloseTimer.start()
    }
  }
}
