pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property int _reloadTick: 0

    property var d: ({})

    // ================================================================
    // ENGINE — auto-detect from signature key in JSON
    // ================================================================
    readonly property string engine: {
      var _ = _reloadTick
      if (Object.keys(d).length === 0) return "m3"
        if (d["m3primary"] !== undefined) return "m3"
        if (d["dark0"]     !== undefined) return "warnaza"
        console.warn("Colors: unknown engine — add signature key detection")
        return "m3"
    }

    // ================================================================
    // MODE — read from json
    // ================================================================
    readonly property string mode:  {
      var _ = _reloadTick
      d["mode"] ?? "dark"
    }
    readonly property bool isDark: mode === "dark"

    // ================================================================
    // MAPPING TABLE
    // Structure: engine → mode → semantic_key → raw_key in JSON
    // ================================================================
    readonly property var mappings: ({

        // ------------------------------------------------------------
        // M3 ENGINE 
        // ------------------------------------------------------------
        "m3": {
          "dark": {

            // ------------------------------------------------------------
            // Functionality
            // ------------------------------------------------------------
            
            // Background
            "background":          "m3surface",
            "background_variant1": "m3onSecondaryFixed",
            "background_variant2": "m3onPrimaryFixed",
            "background_variant3": "m3onTertiaryFixed",
            "background_variant4": "m3surfaceContainer",
            
            // Header Title
            "header_title":          "m3primary",
            
            // Lock Text
            "lock_text": "m3onSurface",

            // Notification Item
            "notif_app_name":     "m3tertiary",
            "notif_time":         "m3onSurfaceVariant",
            "notif_summary":      "m3secondary",

            // Action Button
            "action_btn_hovered":  "m3primaryContainer",
            "action_btn_icon":     "m3onSurface",
            "action_btn_running":  "m3primary",

            // Close Button
            "close_btn_hovered": "m3onSecondary",
            "close_btn_icon":    "m3onSurface",

            // Scrollbar
            "scrollbar_thumb": "m3outline",
            "scrollbar_track": "m3onSecondary",

            // Toast
            "toast_bg":             "m3surfaceContainerHighest",
            "toast_border":         "m3primary",
            "toast_text":           "m3onSurface",

            // Text
            "text":                "m3onBackground",
            "text_variant1":       "m3onSurfaceVariant",
            "text_variant2":       "m3primary",
            "text_variant3":       "m3primaryFixed",
            "text_variant4":       "m3tertiary",
            "text_variant5":       "m3onPrimaryFixedVariant",
            "text_variant6":       "m3inversePrimary",
            "text_variant7":       "m3onSecondaryContainer",

            // Container Level
            "container_level_1":          "m3surfaceContainerHigh",
            "container_level_1_variant1": "m3onSecondary",
            "container_level_1_variant2": "m3primaryContainer",
            "container_level_2":          "m3primary",
            "container_level_2_variant1": "m3secondaryContainer",
            "icon_on_container":          "m3onSurfaceVariant",
            "text_on_container":          "m3onSurfaceVariant",

            // Outline
            "outline":             "m3outline",
            "outline_variant":     "m3outlineVariant",
            "divider": "m3outlineVariant",

            // Error
            "error":               "m3error",
            "error_on":            "m3onError",

            // Misc
            "shadow":              "m3shadow",
            "scrim":               "m3scrim",

            // ------------------------------------------------------------
            // Topbar
            // ------------------------------------------------------------

            // Topbar
            "topbar_gradient1":   "m3surface",
            "topbar_gradient2":   "m3onTertiaryFixed",
            "topbar_gradient3":   "m3surfaceContainer",
            "topbar_gradient4":   "m3onPrimaryFixed",
            "topbar_gradient5":   "m3surface",
            "topbar_gradient6":   "m3onSecondaryFixed",

            // ------------------------------------------------------------
            // Clipboard Panel
            // ------------------------------------------------------------

            // Clipboard Item
            "clipboard_item_bg":          "m3surfaceContainer",
            "clipboard_item_hovered":     "m3surfaceContainerHigh",
            "clipboard_item_text":        "m3onSurface",
            "clipboard_copy_hovered":     "m3primaryContainer",
            "clipboard_copy_icon":        "m3onPrimaryContainer",
            "clipboard_copy_icon_normal": "m3onSurface",
            "clipboard_delete_hovered":   "m3errorContainer",
            "clipboard_delete_icon_normal": "m3onSurface",

            // ------------------------------------------------------------
            // Dashboard
            // ------------------------------------------------------------

            // Arc System
            "arc_color":          "m3onPrimaryFixed",
            "circle_arc":         "m3onSecondary",
            "background_arc":     "m3surfaceContainer",
            "gauge_normal":       "m3onSurface",
            "gauge_warning":      "m3primary",
            "gauge_critical":     "m3error",

            // Dashboard Clock 
            "text_hour" :         "m3onSurface",
            "text_dots" :         "m3tertiary",
            "text_minute":        "m3onSurface",
            "text_date" :         "m3onSurface",

            // Calendar
            "calendar_today_bg":    "m3tertiary",
            "calendar_today_text":  "m3onTertiary",
            "calendar_muted_text":  "m3outlineVariant",
            "calendar_normal_text": "m3onSurface",

            // ------------------------------------------------------------
            // Dashboard
            // ------------------------------------------------------------

            // Category List
            "category_selected":   "m3onSecondary",      // dark
            "category_hovered":    "m3surfaceContainer", // dark

            // Context Menu
            "context_menu_bg":      "m3surface",              // dark
            "context_menu_hovered": "m3surfaceContainerHigh", // dark

            // ------------------------------------------------------------
            // Panel Settings
            // ------------------------------------------------------------
            
            // Wifi Button
            "wifi_btn_active":   "m3onSecondary",
            "wifi_btn_inactive": "m3surfaceContainerHigh",

            // Bluetooth Button 
            "bt_btn_active":   "m3onTertiary",
            "bt_btn_inactive": "m3surfaceContainerHigh",

            // Night Mode 
            "nightmode_btn_active":   "m3tertiaryContainer",
            "nightmode_btn_inactive": "m3surfaceContainerHigh",

            // DND Button
            "dnd_btn_active":   "m3tertiaryContainer",
            "dnd_btn_inactive": "m3surfaceContainerHigh",

            // Color Picker
            "colorpicker_btn_bg":   "m3onSecondaryFixedVariant",
            "colorpicker_btn_icon": "m3primary",

            // Audio Devices
            "audio_btn_bg":   "m3onTertiary",
            "audio_btn_icon": "m3tertiary",

            // Brightness Slider
            "brightness_slider_track_bg":       "m3surfaceContainerHigh",
            "brightness_slider_track_fill":     "m3onPrimary",
            "brightness_slider_handle":         "m3onPrimary",
            "brightness_slider_handle_pressed": "m3onPrimary",

            // Volume Slider
            "volume_slider_track_bg":       "m3surfaceContainerHigh",
            "volume_slider_track_fill":     "m3onSecondary",
            "volume_slider_handle":         "m3onSecondary",
            "volume_slider_handle_pressed": "m3onTertiary",

            // Notification in Panel
            "notif_btn_hovered": "m3primaryContainer",
            "notif_btn_icon":    "m3onSurface",

            // Notification Item
            "notif_item_bg":      "m3surfaceContainerHigh",

            // ------------------------------------------------------------
            // Panel Wifi
            // ------------------------------------------------------------ 

            // Wifi Network Item
            "net_item_bg":              "m3surfaceContainer",
            "net_item_hovered":         "m3surfaceContainerHigh",
            "net_icon_connected":       "m3tertiary",
            "net_icon_disconnected":    "m3onSurfaceVariant",
            "net_ssid_text":            "m3onSurface",
            "net_connected_text":       "m3primary",
            "net_lock_icon":            "m3tertiary",
            "net_toggle_active_bg":     "m3onPrimary",
            "net_toggle_inactive_bg":   "m3secondaryContainer",
            "net_toggle_active_text":   "m3tertiaryFixed",
            "net_toggle_inactive_text": "m3onSurfaceVariant",

            // Password Form
            "pwd_back_btn_hovered":  "m3surfaceContainerHigh",
            "pwd_back_btn_icon":     "m3onSurface",
            "pwd_ssid_text":         "m3onSurface",
            "pwd_input_bg":          "m3surfaceContainerHigh",
            "pwd_input_border":      "m3primary",
            "pwd_input_text":        "m3onSurface",
            "pwd_input_selection":   "m3primary",
            "pwd_input_selected":    "m3surface",
            "pwd_eye_icon":          "m3onSurfaceVariant",
            "pwd_connect_bg":        "m3primaryContainer",
            "pwd_connect_hovered":   "m3primary",
            "pwd_connect_text":      "m3onPrimaryContainer",
            "pwd_connect_text_hovered": "m3surface", 

            // ------------------------------------------------------------
            // Panel Bluetooth
            // ------------------------------------------------------------

            // Bluetooth Header
            "bt_toggle_active_bg":      "m3onPrimaryFixedVariant",
            "bt_toggle_inactive_bg":    "m3surfaceContainerHigh",
            "bt_toggle_knob":           "m3surfaceContainer",

            // Bluetooth Device Item
            "bt_device_item_bg":             "m3surfaceContainer",
            "bt_device_item_hovered":        "m3surfaceContainerHigh",
            "bt_device_icon_connected":      "m3primary",
            "bt_device_icon_disconnected":   "m3onSurfaceVariant",
            "bt_device_name":                "m3onSurface",
            "bt_device_status_connected":    "m3primary",
            "bt_device_status_processing":   "m3outline",
            "bt_device_status_paired":       "m3onSurfaceVariant",
            "bt_device_toggle_active_bg":    "m3secondaryContainer",
            "bt_device_toggle_inactive_bg":  "m3onSecondary",
            "bt_device_toggle_loading_bg":   "m3surfaceContainerHigh",
            "bt_device_toggle_active_text":  "m3primary",
            "bt_device_toggle_inactive_text":"m3onSurface",
            "bt_device_toggle_loading_text": "m3onSurfaceVariant",

            // ------------------------------------------------------------
            // Panel Audio
            // ------------------------------------------------------------

            // Audio Output List
            "audio_item_active_bg":          "m3onSecondary",
            "audio_item_inactive_bg":        "m3surfaceContainerHigh",
            "audio_item_active_icon":        "m3primary",
            "audio_item_inactive_icon":      "m3onSurface",
            "audio_item_text":               "m3onSurface",
            "audio_toggle_active_bg":        "m3secondaryContainer",
            "audio_toggle_inactive_bg":      "m3surfaceContainerHighest",
            "audio_toggle_active_text":      "m3primary",
            "audio_toggle_inactive_text":    "m3onSurface",

            // ------------------------------------------------------------
            // Panel Notifications
            // ------------------------------------------------------------

            // Notification Tab
            "tab_active_bg":   "m3onPrimary",
            "tab_inactive_bg": "m3surfaceContainer",
            "tab_active_text": "m3primary",
            "tab_inactive_text": "m3onSurface",

            // Notification Panel Item
            "notif_group_dot":           "m3primary",
            "notif_group_title":         "m3primary",
            "notif_group_count":         "m3onSurfaceVariant",
            "notif_panel_item_bg":       "m3surfaceContainer",
            "notif_panel_item_hovered":  "m3surfaceContainerHigh",
            "notif_dismiss_hovered":     "m3onSecondary",
            "notif_dismiss_icon":        "m3onSurface",
            "notif_icon_bg":             "m3primaryContainer",
            "notif_icon":                "m3primary",
            "notif_time_grouped":        "m3onSurfaceVariant",
            "notif_body":                "m3onSurfaceVariant",

            // ------------------------------------------------------------
            // Notification Popup Item
            // ------------------------------------------------------------

            // Notification Popup Item
            "notif_popup_bg":                  "m3surfaceContainerLow",
            "notif_popup_border":              "m3outlineVariant",
            "notif_popup_app_name":            "m3onSurface",
            "notif_popup_close_bg":            "m3surfaceContainerHigh",
            "notif_popup_close_hovered":       "m3errorContainer",
            "notif_popup_close_icon":          "m3onSurface",
            "notif_popup_summary":             "m3onSurface",
            "notif_popup_body":                "m3onSurface",
            "notif_popup_action_bg":           "m3surfaceContainerHigh",
            "notif_popup_action_hovered":      "m3primary",
            "notif_popup_action_text":         "m3primary",
            "notif_popup_action_text_hovered": "m3surface",

            // ------------------------------------------------------------
            // Media
            // ------------------------------------------------------------

            // Media
            "media_status_playing": "m3primary",
            "media_status_other":   "m3onSurface",

            // Media Controls
            "media_progress_remaining":  "m3surfaceContainerHighest",
            "media_progress_wave":       "m3tertiary",
            "media_progress_handle":     "m3tertiary",
            "media_ctrl_icon":           "m3tertiary",
            "media_ctrl_icon_hovered":   "m3onSurface",

            // Media Dropdown
            "media_dropdown_bg":             "m3surface",
            "media_dropdown_item_hovered":   "m3surfaceContainerHigh",
            "media_dropdown_player_active":  "m3primary",
            "media_dropdown_player_inactive":"m3onSurfaceVariant",
            "media_dropdown_dot_playing":    "m3primaryContainer",
            "media_dropdown_dot_stopped":    "m3onSurfaceVariant",
            
            // ------------------------------------------------------------
            // App Launcher Session
            // ------------------------------------------------------------

            // Mode Select
            "mode_select_active_bg":     "m3onSecondary",
            "mode_select_inactive_bg":   "m3surfaceContainerHigh",
            "mode_select_active_border": "m3primary",
            "mode_select_active_text":   "m3onSurface",
            "mode_select_inactive_text": "m3onSurfaceVariant",

            // App Launcher List
            "launcher_list_bg":          "m3surfaceContainerHigh",
            "launcher_back_icon":        "m3onSurfaceVariant",
            "launcher_count_text":       "m3onSurface",
            "launcher_hint_text":        "m3onSurface",
            "launcher_item_active_bg":   "m3onSecondary",
            "launcher_icon_bg":          "m3surfaceContainerHighest",
            "launcher_app_name":         "m3onSurface",
            "launcher_app_desc":         "m3onSurfaceVariant",

            // Session Launcher
            "session_list_bg":                 "m3surfaceContainerHigh",
            "session_back_icon":               "m3onSurfaceVariant",
            "session_count_text":              "m3onSurface",
            "session_hint_text":               "m3onSurface",
            "session_item_active_bg":          "m3onSecondary",
            "session_app_name":                "m3onSurface",
            "session_app_desc":                "m3onSurfaceVariant",
            "session_icon_active_bg":          "m3primaryFixed",
            "session_icon_inactive_bg":        "m3surfaceContainerHighest",
            "session_icon_active":             "m3primary",
            "session_icon_inactive":           "m3onSurfaceVariant",
            "session_chip_bg":                 "m3surfaceContainerLow",
            "session_chip_text":               "m3onSurfaceVariant",
            "session_workspace_active":        "m3primaryFixed",
            "session_workspace_text_active":   "m3primary",
            "session_workspace_text_inactive": "m3onSurfaceVariant",

            // Search Bar
            "search_bg":               "m3surfaceContainerLow",
            "search_border":           "m3outlineVariant",
            "search_border_inactive":  "m3outline",
            "search_icon":             "m3onSurfaceVariant",
            "search_text":             "m3onSurface",
            "search_selection":        "m3primary",
            "search_selected_text":    "m3surfaceContainer",
            "search_placeholder":      "m3primary",

            // ------------------------------------------------------------
            // Rightbar
            // ------------------------------------------------------------

            // Rightbar
            "rightbar_gradient1":   "m3onSecondaryFixed",
            "rightbar_gradient2":   "m3onSecondaryFixed",
            "rightbar_gradient3":   "m3surface",
            "rightbar_gradient4":   "m3surface",
            "rightbar_gradient5":   "m3onPrimaryFixed",

            // Wallpaper Picker Item
            "wallpaper_item_active_bg":     "m3surfaceContainer",
            "wallpaper_item_inactive_bg":   "m3surface",
            "wallpaper_item_active_border": "m3outline",
            "wallpaper_item_inactive_border": "m3outlineVariant",
            "wallpaper_placeholder_bg":     "m3surfaceContainerHighest",

            // ------------------------------------------------------------
            // OSD POPUP
            // ------------------------------------------------------------

            // OSD Volume
            "osd_icon":                "m3primary",
            "osd_value_text":          "m3primary",
            "osd_slider_track_bg":     "m3surfaceContainer",
            "osd_slider_track_fill":   "m3primaryContainer",
            "osd_slider_handle":       "m3primaryContainer",

            // OSD Brightness
            "osd_brightness_icon":              "m3secondary",
            "osd_brightness_value_text":        "m3secondary",
            "osd_brightness_slider_track_bg":   "m3surfaceContainer",
            "osd_brightness_slider_track_fill": "m3secondaryContainer",
            "osd_brightness_slider_handle":     "m3secondaryContainer",

            // ------------------------------------------------------------
            // Leftbar
            // ------------------------------------------------------------

            // Leftbar
            "leftbar_gradient1":  "m3surfaceDim",
            "leftbar_gradient2":  "m3surface",
            "leftbar_gradient3":  "m3surface",
            "leftbar_gradient4":  "m3surface",
            "leftbar_gradient5":  "m3surface",
            "leftbar_gradient6":  "m3onPrimaryFixed",
            "leftbar_gradient7":  "m3onPrimaryFixed",
            "leftbar_gradient8":  "m3surface",
            "leftbar_gradient9":  "m3onPrimaryFixed",
            "leftbar_gradient10": "m3onPrimaryFixed",

            // ------------------------------------------------------------
            // Bottombar
            // ------------------------------------------------------------

            // Bottombar
            "bottombar_gradient1": "m3onPrimaryFixed",
            "bottombar_gradient2": "m3surface",
            "bottombar_gradient3": "m3onSecondaryFixed",
            "bottombar_gradient4": "m3surface",
            "bottombar_gradient5": "m3onPrimaryFixed",
            "bottombar_gradient6": "m3onPrimaryFixed",


            // ------------------------------------------------------------
            // List Apps
            // ------------------------------------------------------------

            // Remove Menu
            "remove_menu_bg":      "m3surfaceContainer",
            "remove_menu_hovered": "m3errorContainer",
            "remove_menu_icon":    "m3onSurface",

            // ------------------------------------------------------------
            // Power Menu
            // ------------------------------------------------------------

            // Power Menu
            "power_item_active_bg":    "m3onPrimaryFixed",
            "power_item_inactive_bg":  "m3surfaceContainerHigh",
            "power_item_active_icon":  "m3onSurfaceVariant",
            "power_item_inactive_icon":"m3onSurface",
            "power_item_active_label": "m3tertiaryFixedDim",
            "power_item_inactive_label":"m3onSurface",

            // ------------------------------------------------------------
            // Shell Settings
            // ------------------------------------------------------------

            // Shell Settings Sidebar
            "settings_sidebar_bg": "m3surfaceContainer",
            "settings_tab_active_bg":   "m3onPrimary",
            "settings_tab_hovered_bg":  "m3surfaceContainerHigh",
            "settings_tab_active_text": "m3primary",
            "settings_tab_inactive_text":"m3onSurfaceVariant",

            // Variant Selector
            "variant_active_bg":    "m3onPrimary",
            "variant_inactive_bg":  "m3surfaceContainer",
            "variant_active_text":  "m3primary",
            "variant_inactive_text":"m3onSurfaceVariant",

            // Mode Selector
            "mode_selector_active_bg":    "m3onPrimary",
            "mode_selector_inactive_bg":  "m3surfaceContainer",
            "mode_selector_active_text":  "m3primary",
            "mode_selector_inactive_text":"m3onSurfaceVariant",

            // ------------------------------------------------------------
            // Workspace Overview
            // ------------------------------------------------------------
            
            // Workspace Overview
            "ws_card_active_bg":        "m3surfaceContainerHigh",
            "ws_card_inactive_bg":      "m3surfaceContainer",
            "ws_card_drop_bg":          "m3primary",
            "ws_card_active_border":    "m3outline",
            "ws_card_key_border":       "m3tertiary",
            "ws_card_drop_border":      "m3primary",
            "ws_card_inactive_border":  "m3outlineVariant",
            "ws_badge_active_bg":       "m3primary",
            "ws_badge_inactive_bg":     "m3surfaceContainerHighest",
            "ws_badge_key_bg":          "m3tertiary",
            "ws_badge_active_text":     "m3surface",
            "ws_badge_inactive_text":   "m3onSurfaceVariant",
            "ws_status_active":         "m3onSurface",
            "ws_status_inactive":       "m3onSurfaceVariant",
            "ws_divider":               "m3outlineVariant",
            "ws_app_hovered_bg":        "m3surfaceContainerHighest",
            "ws_app_title":             "m3onSurface",
            "ws_app_close_icon":        "m3onSurfaceVariant",
            "ws_more_text":             "m3onSurfaceVariant",
            "ws_empty_text":            "m3outlineVariant",

            // Drag Visual
            "drag_visual_bg":     "m3surfaceContainerHighest",
            "drag_visual_border": "m3primary",
            "drag_visual_text":   "m3onSurface",

            // Snapshot Session
            "snapshot_input_bg":           "m3surfaceContainerHigh",
            "snapshot_input_border":       "m3primary",
            "snapshot_input_icon":         "m3onSurfaceVariant",
            "snapshot_input_text":         "m3onSurface",
            "snapshot_input_selection":      "m3primary",
            "snapshot_input_selected_text":  "m3surface",
            "snapshot_input_placeholder":  "m3onSurfaceVariant",
            "snapshot_warning_bg":         "m3error",
            "snapshot_warning_border":     "m3error",
            "snapshot_warning_text":       "m3error",
            "snapshot_info_bg":            "m3primary",
            "snapshot_info_border":        "m3primary",
            "snapshot_info_text":          "m3primary",
            "snapshot_save_bg":            "m3surfaceContainerHigh",
            "snapshot_save_hovered":       "m3onPrimaryFixed",
            "snapshot_save_text":          "m3onSurface",

          }, 

          "light": {
            // ------------------------------------------------------------
            // Functionality
            // ------------------------------------------------------------

            // Background
            "background":          "m3surface",
            "background_variant1": "m3secondaryFixedDim",
            "background_variant2": "m3primaryFixedDim",
            "background_variant3": "m3primaryFixed",

            // Header Title
            "header_title":          "m3secondary",
            
            // Lock Text
            "lock_text": "m3surface",

            // Notification Item
            "notif_app_name":     "m3tertiary",
            "notif_time":         "m3onSurfaceVariant",
            "notif_summary":      "m3secondary",

            // Action Button
            "action_btn_hovered":  "m3secondaryFixed",
            "action_btn_icon":     "m3onSurface",
            "action_btn_running":  "m3secondary",

            // Close Button
            "close_btn_hovered": "m3secondary",
            "close_btn_icon":    "m3onSurface",

            // Scrollbar
            "scrollbar_thumb": "m3outline",
            "scrollbar_track": "m3surfaceContainerHigh",

            // Toast
            "toast_bg":             "m3surfaceContainerHigh",
            "toast_border":         "m3secondary",
            "toast_text":           "m3onSurface",

            // Container on Background 
            "container_level_1":          "m3tertiaryFixedDim",
            "container_level_1_variant1": "m3inversePrimary",
            "container_level_1_variant2": "m3secondaryFixed",
            "container_level_2":          "m3primary",
            "container_level_2_variant1": "m3primaryFixedDim",
            "icon_on_container":          "m3onPrimaryFixedVariant",
            "text_on_container":          "m3onPrimaryFixedVariant",

            // Text
            "text":                "m3onBackground",
            "text_variant1":       "m3onSurfaceVariant",
            "text_variant2":       "m3onPrimaryFixedVariant",
            "text_variant3":       "m3onPrimaryFixed",
            "text_variant4":       "m3secondary",
            "text_variant5":       "m3onSecondaryFixedVariant",
            "text_variant6":       "m3primary",
            "text_variant7":       "m3onSecondaryContainer",

            // Outline
            "outline":             "m3outline",
            "outline_variant":     "m3outlineVariant",
            "divider": "m3primary",

            // Error
            "error":               "m3error",
            "error_on":            "m3onError",

            // Misc
            "shadow":              "m3shadow",
            "scrim":               "m3scrim",

            // ------------------------------------------------------------
            // Topbar
            // ------------------------------------------------------------
                
            // Topbar
            "topbar_gradient1":   "m3surface",
            "topbar_gradient2":   "m3primaryFixed",
            "topbar_gradient3":   "m3surface",
            "topbar_gradient4":   "m3primaryFixed",
            "topbar_gradient5":   "m3surface",
            "topbar_gradient6":   "m3secondaryFixedDim",

            // ------------------------------------------------------------
            // Clipboard Panel
            // ------------------------------------------------------------ 

            // Clipboard Item
            "clipboard_item_bg":          "m3surfaceContainerHigh",
            "clipboard_item_hovered":     "m3primaryFixedDim",
            "clipboard_item_text":        "m3onSurface",
            "clipboard_copy_hovered":     "m3primary",
            "clipboard_copy_icon":        "m3onPrimary",
            "clipboard_copy_icon_normal": "m3onSurface",
            "clipboard_delete_hovered":   "m3error",
            "clipboard_delete_icon_normal": "m3onSurface",

            // ------------------------------------------------------------
            // Dashboard
            // ------------------------------------------------------------

            // Arc System
            "arc_color":          "m3inversePrimary",
            "circle_arc":         "m3inversePrimary",
            "background_arc":     "m3surfaceContainerLow",
            "gauge_normal":   "m3onBackground",
            "gauge_warning":  "m3secondary",
            "gauge_critical": "m3error",

            // Dashboard Clock 
            "text_hour" :         "m3secondary",
            "text_dots" :         "m3tertiaryContainer",
            "text_minute":        "m3secondary",
            "text_date" :         "m3onSurfaceVariant",

            // Calendar
            "calendar_today_bg":    "m3primary",
            "calendar_today_text":  "m3onPrimary",
            "calendar_muted_text":  "m3outline",
            "calendar_normal_text": "m3onBackground",

            // ------------------------------------------------------------
            // Menu
            // ------------------------------------------------------------

            // Category List
            "category_selected":   "m3primaryFixedDim",  // light
            "category_hovered":    "m3inversePrimary",   // light (dengan alpha 0.7)

            // Context Menu
            "context_menu_bg":      "m3surfaceContainerHigh", // light
            "context_menu_hovered": "m3primaryFixedDim",      // light

            // ------------------------------------------------------------
            // Panel Settings
            // ------------------------------------------------------------

            // Wifi Button
            "wifi_btn_active":   "m3primaryFixedDim",
            "wifi_btn_inactive": "m3surfaceDim",

            // Bluetooth Button 
            "bt_btn_active":   "m3secondaryFixedDim",
            "bt_btn_inactive": "m3surfaceDim",

            // Night Mode 
            "nightmode_btn_active":   "m3tertiaryFixedDim",
            "nightmode_btn_inactive": "m3surfaceDim",

            // DND Button
            "dnd_btn_active":   "m3primaryFixed",
            "dnd_btn_inactive": "m3surfaceDim",

            // Color Picker
            "colorpicker_btn_bg":   "m3inversePrimary",
            "colorpicker_btn_icon": "m3secondary",

            // Audio Devices
            "audio_btn_bg":   "m3primaryFixed",
            "audio_btn_icon": "m3secondary",

            // Brightness Slider
            "brightness_slider_track_bg":       "m3surfaceContainerHighest",
            "brightness_slider_track_fill":     "m3inversePrimary",
            "brightness_slider_handle":         "m3secondaryFixedDim",
            "brightness_slider_handle_pressed": "m3primaryFixedDim",

            // Volume Slider 
            "volume_slider_track_bg":       "m3surfaceContainerHighest",
            "volume_slider_track_fill":     "m3tertiaryFixedDim",
            "volume_slider_handle":         "m3primaryFixedDim",
            "volume_slider_handle_pressed": "m3tertiaryFixedDim",

            // Notification in Panel
            "notif_btn_hovered": "m3secondaryFixed",
            "notif_btn_icon":    "m3onSurface",

            // Notification Item
            "notif_item_bg":      "m3surfaceContainerHighest",

            // ------------------------------------------------------------
            // Panel Wifi
            // ------------------------------------------------------------

            // Wifi Network Item
            "net_item_bg":              "m3surfaceContainerHigh",
            "net_item_hovered":         "m3primary",
            "net_icon_connected":       "m3primary",
            "net_icon_disconnected":    "m3outline",
            "net_ssid_text":            "m3onSurface",
            "net_connected_text":       "m3secondary",
            "net_lock_icon":            "m3tertiary",
            "net_toggle_active_bg":     "m3primaryContainer",
            "net_toggle_inactive_bg":   "m3outline",
            "net_toggle_active_text":   "m3onPrimary",
            "net_toggle_inactive_text": "m3onSecondary",

            // Password Form
            "pwd_back_btn_hovered":  "m3primaryFixedDim",
            "pwd_back_btn_icon":     "m3onSurface",
            "pwd_ssid_text":         "m3onSurface",
            "pwd_input_bg":          "m3surfaceContainerHighest",
            "pwd_input_border":      "m3primary",
            "pwd_input_text":        "m3onSurface",
            "pwd_input_selection":   "m3primary",
            "pwd_input_selected":    "m3surface",
            "pwd_eye_icon":          "m3onSurfaceVariant",
            "pwd_connect_bg":        "m3primaryFixedDim",
            "pwd_connect_hovered":   "m3secondary",
            "pwd_connect_text":      "m3primary",
            "pwd_connect_text_hovered": "m3surface",

            // ------------------------------------------------------------
            // Panel Bluetooth
            // ------------------------------------------------------------

            // Bluetooth Header
            "bt_toggle_active_bg":      "m3secondary",
            "bt_toggle_inactive_bg":    "m3surfaceContainer",
            "bt_toggle_knob":           "m3surface",

            // Bluetooth Device Item
            "bt_device_item_bg":             "m3surfaceContainerHigh",
            "bt_device_item_hovered":        "m3primary",
            "bt_device_icon_connected":      "m3tertiary",
            "bt_device_icon_disconnected":   "m3onSurfaceVariant",
            "bt_device_name":                "m3onSurface",
            "bt_device_status_connected":    "m3tertiary",
            "bt_device_status_processing":   "m3outline",
            "bt_device_status_paired":       "m3onSurfaceVariant",
            "bt_device_toggle_active_bg":    "m3primaryContainer",
            "bt_device_toggle_inactive_bg":  "m3outline",
            "bt_device_toggle_loading_bg":   "m3surfaceContainer",
            "bt_device_toggle_active_text":  "m3onSecondary",
            "bt_device_toggle_inactive_text":"m3onPrimary",
            "bt_device_toggle_loading_text": "m3onSurfaceVariant",

            // ------------------------------------------------------------
            // Panel Audio
            // ------------------------------------------------------------

            // Audio Output List
            "audio_item_active_bg":          "m3primary",
            "audio_item_inactive_bg":        "m3surfaceContainerHigh",
            "audio_item_active_icon":        "m3secondary",
            "audio_item_inactive_icon":      "m3onSurface",
            "audio_item_text":               "m3onSurface",
            "audio_toggle_active_bg":        "m3secondaryContainer",
            "audio_toggle_inactive_bg":      "m3tertiaryContainer",
            "audio_toggle_active_text":      "m3onSecondaryContainer",
            "audio_toggle_inactive_text":    "m3onPrimary",

            // ------------------------------------------------------------
            // Panel Notifications
            // ------------------------------------------------------------

            // Tab
            "tab_active_bg":   "m3primaryFixedDim",
            "tab_inactive_bg": "m3surfaceContainerHigh",
            "tab_active_text": "m3primary",
            "tab_inactive_text": "m3onSurface",

            // Notification Panel Item
            "notif_group_dot":           "m3secondary",
            "notif_group_title":         "m3secondary",
            "notif_group_count":         "m3onSurfaceVariant",
            "notif_panel_item_bg":       "m3surfaceContainerHigh",
            "notif_panel_item_hovered":  "m3primaryFixedDim",
            "notif_dismiss_hovered":     "m3secondary",
            "notif_dismiss_icon":        "m3onSurface",
            "notif_icon_bg":             "m3secondaryFixed",
            "notif_icon":                "m3secondary",
            "notif_time_grouped":        "m3onSurfaceVariant",
            "notif_body":                "m3onSurfaceVariant",

            // ------------------------------------------------------------
            // Notification Popup Item
            // ------------------------------------------------------------

            // Notification Popup Item
            "notif_popup_bg":                  "m3surface",
            "notif_popup_border":              "m3outlineVariant",
            "notif_popup_app_name":            "m3onSurface",
            "notif_popup_close_bg":            "m3surfaceContainerHigh",
            "notif_popup_close_hovered":       "m3errorContainer",
            "notif_popup_close_icon":          "m3onSurface",
            "notif_popup_summary":             "m3onSurface",
            "notif_popup_body":                "m3onSurface",
            "notif_popup_action_bg":           "m3surfaceContainerHighest",
            "notif_popup_action_hovered":      "m3secondary",
            "notif_popup_action_text":         "m3secondary",
            "notif_popup_action_text_hovered": "m3surface",

            // ------------------------------------------------------------
            // Media
            // ------------------------------------------------------------
            
            "media_status_playing": "m3secondary",
            "media_status_other":   "m3onSurface",

            // Media Controls
            "media_progress_remaining":  "m3surfaceContainerHigh",
            "media_progress_wave":       "m3onPrimaryFixedVariant",
            "media_progress_handle":     "m3onPrimaryFixedVariant",
            "media_ctrl_icon":           "m3secondary",
            "media_ctrl_icon_hovered":   "m3secondary",

            // Media Dropdown
            "media_dropdown_bg":             "m3surfaceContainer",
            "media_dropdown_item_hovered":   "m3surfaceContainerHighest",
            "media_dropdown_player_active":  "m3secondary",
            "media_dropdown_player_inactive":"m3onSurfaceVariant",
            "media_dropdown_dot_playing":    "m3inversePrimary",
            "media_dropdown_dot_stopped":    "m3onPrimaryFixed",

            // ------------------------------------------------------------
            // App Launcher Sessions
            // ------------------------------------------------------------
            
            // Mode Select
            "mode_select_active_bg":     "m3inversePrimary",
            "mode_select_inactive_bg":   "m3surfaceContainerHighest",
            "mode_select_active_border": "m3primary",
            "mode_select_active_text":   "m3onSurface",
            "mode_select_inactive_text": "m3onSurfaceVariant",

            // App Launcher List
            "launcher_list_bg":          "m3surfaceContainerHighest",
            "launcher_back_icon":        "m3onSurfaceVariant",
            "launcher_count_text":       "m3onSurface",
            "launcher_hint_text":        "m3onSurface",
            "launcher_item_active_bg":   "m3inversePrimary",
            "launcher_icon_bg":          "m3surfaceContainerHighest",
            "launcher_app_name":         "m3onSurface",
            "launcher_app_desc":         "m3onSurfaceVariant",

            // Session Launcher
            "session_list_bg":                 "m3surfaceContainerHighest",
            "session_back_icon":               "m3onSurfaceVariant",
            "session_count_text":              "m3onSurface",
            "session_hint_text":               "m3onSurface",
            "session_item_active_bg":          "m3inversePrimary",
            "session_app_name":                "m3onSurface",
            "session_app_desc":                "m3onSurfaceVariant",
            "session_icon_active_bg":          "m3primary",
            "session_icon_inactive_bg":        "m3surfaceContainer",
            "session_icon_active":             "m3primary",
            "session_icon_inactive":           "m3onSurfaceVariant",
            "session_chip_bg":                 "m3surfaceContainerHighest",
            "session_chip_text":               "m3onSurfaceVariant",
            "session_workspace_active":        "m3primary",
            "session_workspace_text_active":   "m3primary",
            "session_workspace_text_inactive": "m3onSurfaceVariant",

            // Search Bar
            "search_bg":               "m3surfaceContainerHighest",
            "search_border":           "m3outlineVariant",
            "search_border_inactive":  "m3outline",
            "search_icon":             "m3onSurfaceVariant",
            "search_text":             "m3onSurface",
            "search_selection":        "m3secondaryFixed",
            "search_selected_text":    "m3surface",
            "search_placeholder":      "m3onPrimaryFixedVariant",

            // ------------------------------------------------------------
            // Rightbar
            // ------------------------------------------------------------
                
            // Rightbar
            "rightbar_gradient1":   "m3secondaryFixedDim",
            "rightbar_gradient2":   "m3secondaryFixedDim",
            "rightbar_gradient3":   "m3surface",
            "rightbar_gradient4":   "m3surface",
            "rightbar_gradient5":   "m3primaryFixedDim",

            // Wallpaper Picker Item
            "wallpaper_item_active_bg":     "m3surfaceContainer",
            "wallpaper_item_inactive_bg":   "m3surface",
            "wallpaper_item_active_border": "m3outline",
            "wallpaper_item_inactive_border": "m3outlineVariant",
            "wallpaper_placeholder_bg":     "m3surfaceContainerHighest",
            
            // ------------------------------------------------------------
            // OSD POPUP
            // ------------------------------------------------------------

            // OSD Volume
            "osd_icon":                "m3onPrimaryFixed",
            "osd_value_text":          "m3onPrimaryFixed",
            "osd_slider_track_bg":     "m3inversePrimary",
            "osd_slider_track_fill":   "m3primary",
            "osd_slider_handle":       "m3primary",

            // OSD Brightness
            "osd_brightness_icon":              "m3onSecondaryFixed",
            "osd_brightness_value_text":        "m3onSecondaryFixed",
            "osd_brightness_slider_track_bg":   "m3inversePrimary",
            "osd_brightness_slider_track_fill": "m3secondary",
            "osd_brightness_slider_handle":     "m3secondary",

            // ------------------------------------------------------------
            // Leftbar
            // ------------------------------------------------------------

            // Leftbar
            "leftbar_gradient1":  "m3surface",
            "leftbar_gradient2":  "m3surface",
            "leftbar_gradient3":  "m3surface",
            "leftbar_gradient4":  "m3surface",
            "leftbar_gradient5":  "m3surface",
            "leftbar_gradient6":  "m3primaryFixedDim",
            "leftbar_gradient7":  "m3primaryFixedDim",
            "leftbar_gradient8":  "m3surface",
            "leftbar_gradient9":  "m3primaryFixed",
            "leftbar_gradient10": "m3primaryFixed",

            // ------------------------------------------------------------
            // Bottombar
            // ------------------------------------------------------------

            // Bottombar
            "bottombar_gradient1": "m3primaryFixed",
            "bottombar_gradient2": "m3surface",
            "bottombar_gradient3": "m3primaryFixed",
            "bottombar_gradient4": "m3surface",
            "bottombar_gradient5": "m3primaryFixedDim",
            "bottombar_gradient6": "m3primaryFixedDim",

            
            // ------------------------------------------------------------
            // List Apps
            // ------------------------------------------------------------

            // Remove Menu
            "remove_menu_bg":      "m3surfaceContainerHigh",
            "remove_menu_hovered": "m3errorContainer",
            "remove_menu_icon":    "m3onSurface",

            // Power Menu
            "power_item_active_bg":    "m3primaryContainer",
            "power_item_inactive_bg":  "m3surfaceContainerHigh",
            "power_item_active_icon":  "m3onSurfaceVariant",
            "power_item_inactive_icon":"m3onSurface",
            "power_item_active_label": "m3primary",
            "power_item_inactive_label":"m3onSurface",

            // ------------------------------------------------------------
            // Shell Settings
            // ------------------------------------------------------------

            // Shell Settings Sidebar
            "settings_sidebar_bg": "m3surfaceContainerHigh",
            "settings_tab_active_bg":   "m3primaryFixedDim",
            "settings_tab_hovered_bg":  "m3primaryFixedDim",
            "settings_tab_active_text": "m3primary",
            "settings_tab_inactive_text":"m3onSurfaceVariant",

            // Variant Selector
            "variant_active_bg":    "m3primaryFixedDim",
            "variant_inactive_bg":  "m3surfaceContainerHigh",
            "variant_active_text":  "m3primary",
            "variant_inactive_text":"m3onSurfaceVariant",

            // Mode Selector
            "mode_selector_active_bg":    "m3primaryFixedDim",
            "mode_selector_inactive_bg":  "m3surfaceContainerHigh",
            "mode_selector_active_text":  "m3primary",
            "mode_selector_inactive_text":"m3onSurfaceVariant",

            // ------------------------------------------------------------
            // Workspace Overview
            // ------------------------------------------------------------

            // Workspace Overview
            "ws_card_active_bg":        "m3primaryFixedDim",
            "ws_card_inactive_bg":      "m3surfaceContainerLow",
            "ws_card_drop_bg":          "m3primaryContainer",
            "ws_card_active_border":    "m3outline",
            "ws_card_key_border":       "m3tertiary",
            "ws_card_drop_border":      "m3primary",
            "ws_card_inactive_border":  "m3outlineVariant",
            "ws_badge_active_bg":       "m3primary",
            "ws_badge_inactive_bg":     "m3surfaceContainerHighest",
            "ws_badge_key_bg":          "m3tertiary",
            "ws_badge_active_text":     "m3surface",
            "ws_badge_inactive_text":   "m3onSurfaceVariant",
            "ws_status_active":         "m3onSurface",
            "ws_status_inactive":       "m3onSurfaceVariant",
            "ws_divider":               "m3outlineVariant",
            "ws_app_hovered_bg":        "m3inversePrimary",
            "ws_app_title":             "m3onSurface",
            "ws_app_close_icon":        "m3onSurfaceVariant",
            "ws_more_text":             "m3onSurfaceVariant",
            "ws_empty_text":            "m3outlineVariant",

            // Drag Visual
            "drag_visual_bg":     "m3primaryContainer",
            "drag_visual_border": "m3primary",
            "drag_visual_text":   "m3onSurface",

            // Snapshot Session
            "snapshot_input_bg":           "m3surfaceContainerHighest",
            "snapshot_input_border":       "m3primary",
            "snapshot_input_icon":         "m3onSurfaceVariant",
            "snapshot_input_text":         "m3onSurface",
            "snapshot_input_placeholder":  "m3onSurfaceVariant",
            "snapshot_input_selection":      "m3primary",
            "snapshot_input_selected_text":  "m3surface",
            "snapshot_warning_bg":         "m3error",
            "snapshot_warning_border":     "m3error",
            "snapshot_warning_text":       "m3error",
            "snapshot_info_bg":            "m3primary",
            "snapshot_info_border":        "m3primary",
            "snapshot_info_text":          "m3primary",
            "snapshot_save_bg":            "m3surfaceContainerHighest",
            "snapshot_save_hovered":       "m3primaryContainer",
            "snapshot_save_text":          "m3onSurface",

          }
        },

        // ------------------------------------------------------------
        // WARNAZA ENGINE 
        // ------------------------------------------------------------
        "warnaza": {
          "dark": {

              // ------------------------------------------------------------
              // Functionality
              // ------------------------------------------------------------

              // Background
              "background":          "dark0",
              "background_variant1": "dark2",
              "background_variant2": "dark4",
              "background_variant3": "dark6",
              "background_variant4": "dark3",

              // Header Title
              "header_title": "light2",

              "lock_text": "light3",

              // Notification Item
              "notif_app_name": "light1",
              "notif_time":     "mid8",
              "notif_summary":  "light0",

              // Action Button
              "action_btn_hovered": "dark5",
              "action_btn_icon":    "light1",
              "action_btn_running": "light0",

              // Close Button
              "close_btn_hovered": "dark6",
              "close_btn_icon":    "light1",

              // Scrollbar
              "scrollbar_thumb": "mid5",
              "scrollbar_track": "dark4",

              // Toast
              "toast_bg":     "dark4",
              "toast_border": "light0",
              "toast_text":   "light2",

              // Text
              "text":          "light2",
              "text_variant1": "light0",
              "text_variant2": "mid10",
              "text_variant3": "light1",
              "text_variant4": "mid9",
              "text_variant5": "mid8",
              "text_variant6": "mid7",
              "text_variant7": "light0",

              // Container Level
              "container_level_1":          "dark6",
              "container_level_1_variant1": "dark7",
              "container_level_1_variant2": "dark8",
              "container_level_2":          "mid2",
              "container_level_2_variant1": "mid7",
              "icon_on_container":          "mid10",
              "text_on_container":          "light0",

              // Outline
              "outline":         "mid4",
              "outline_variant": "dark8",
              "divider":         "dark7",

              // Error
              "error":    "mid6",
              "error_on": "dark0",

              // Misc
              "shadow": "dark0",
              "scrim":  "dark0",

              // ------------------------------------------------------------
              // Topbar
              // ------------------------------------------------------------

              "topbar_gradient1": "dark0",
              "topbar_gradient2": "dark3",
              "topbar_gradient3": "dark1",
              "topbar_gradient4": "dark4",
              "topbar_gradient5": "dark0",
              "topbar_gradient6": "dark2",

              // ------------------------------------------------------------
              // Clipboard Panel
              // ------------------------------------------------------------

              "clipboard_item_bg":            "dark3",
              "clipboard_item_hovered":       "dark5",
              "clipboard_item_text":          "light1",
              "clipboard_copy_hovered":       "mid3",
              "clipboard_copy_icon":          "dark0",
              "clipboard_copy_icon_normal":   "light1",
              "clipboard_delete_hovered":     "mid6",
              "clipboard_delete_icon_normal": "light1",

              // ------------------------------------------------------------
              // Dashboard
              // ------------------------------------------------------------

              "arc_color":      "mid10",
              "circle_arc":     "dark5",
              "background_arc": "dark3",
              "gauge_normal":   "light1",
              "gauge_warning":  "mid7",
              "gauge_critical": "mid6",

              "text_hour":   "light2",
              "text_dots":   "mid9",
              "text_minute": "light2",
              "text_date":   "light0",

              "calendar_today_bg":    "mid5",
              "calendar_today_text":  "dark0",
              "calendar_muted_text":  "dark8",
              "calendar_normal_text": "light1",

              // ------------------------------------------------------------
              // Menu
              // ------------------------------------------------------------

              "category_selected": "dark5",
              "category_hovered":  "dark3",

              "context_menu_bg":      "dark2",
              "context_menu_hovered": "dark5",

              // ------------------------------------------------------------
              // Panel Settings
              // ------------------------------------------------------------

              "wifi_btn_active":   "dark6",
              "wifi_btn_inactive": "dark4",

              "bt_btn_active":   "dark6",
              "bt_btn_inactive": "dark4",

              "nightmode_btn_active":   "mid2",
              "nightmode_btn_inactive": "dark4",

              "dnd_btn_active":   "mid2",
              "dnd_btn_inactive": "dark4",

              "colorpicker_btn_bg":   "dark5",
              "colorpicker_btn_icon": "light0",

              "audio_btn_bg":   "dark5",
              "audio_btn_icon": "mid9",

              "brightness_slider_track_bg":       "dark4",
              "brightness_slider_track_fill":     "mid7",
              "brightness_slider_handle":         "mid8",
              "brightness_slider_handle_pressed": "mid9",

              "volume_slider_track_bg":       "dark4",
              "volume_slider_track_fill":     "mid5",
              "volume_slider_handle":         "mid6",
              "volume_slider_handle_pressed": "mid7",

              "notif_btn_hovered": "mid3",
              "notif_btn_icon":    "light1",

              "notif_item_bg": "dark4",

              // ------------------------------------------------------------
              // Panel Wifi
              // ------------------------------------------------------------

              "net_item_bg":              "dark3",
              "net_item_hovered":         "dark5",
              "net_icon_connected":       "mid9",
              "net_icon_disconnected":    "mid5",
              "net_ssid_text":            "light1",
              "net_connected_text":       "light0",
              "net_lock_icon":            "mid8",
              "net_toggle_active_bg":     "mid5",
              "net_toggle_inactive_bg":   "dark5",
              "net_toggle_active_text":   "dark0",
              "net_toggle_inactive_text": "mid8",

              "pwd_back_btn_hovered":     "dark5",
              "pwd_back_btn_icon":        "light1",
              "pwd_ssid_text":            "light1",
              "pwd_input_bg":             "dark4",
              "pwd_input_border":         "mid5",
              "pwd_input_text":           "light1",
              "pwd_input_selection":      "mid5",
              "pwd_input_selected":       "dark0",
              "pwd_eye_icon":             "mid7",
              "pwd_connect_bg":           "mid4",
              "pwd_connect_hovered":      "mid6",
              "pwd_connect_text":         "dark0",
              "pwd_connect_text_hovered": "dark0",

              // ------------------------------------------------------------
              // Panel Bluetooth
              // ------------------------------------------------------------

              "bt_toggle_active_bg":   "mid4",
              "bt_toggle_inactive_bg": "dark4",
              "bt_toggle_knob":        "dark2",

              "bt_device_item_bg":              "dark3",
              "bt_device_item_hovered":         "dark5",
              "bt_device_icon_connected":       "mid9",
              "bt_device_icon_disconnected":    "mid5",
              "bt_device_name":                 "light1",
              "bt_device_status_connected":     "mid9",
              "bt_device_status_processing":    "mid5",
              "bt_device_status_paired":        "mid7",
              "bt_device_toggle_active_bg":     "mid3",
              "bt_device_toggle_inactive_bg":   "dark6",
              "bt_device_toggle_loading_bg":    "dark4",
              "bt_device_toggle_active_text":   "light0",
              "bt_device_toggle_inactive_text": "light1",
              "bt_device_toggle_loading_text":  "mid7",

              // ------------------------------------------------------------
              // Panel Audio
              // ------------------------------------------------------------

              "audio_item_active_bg":       "dark6",
              "audio_item_inactive_bg":     "dark4",
              "audio_item_active_icon":     "mid9",
              "audio_item_inactive_icon":   "light1",
              "audio_item_text":            "light1",
              "audio_toggle_active_bg":     "mid3",
              "audio_toggle_inactive_bg":   "dark5",
              "audio_toggle_active_text":   "light0",
              "audio_toggle_inactive_text": "light1",

              // ------------------------------------------------------------
              // Panel Notifications
              // ------------------------------------------------------------

              "tab_active_bg":    "dark6",
              "tab_inactive_bg":  "dark3",
              "tab_active_text":  "light0",
              "tab_inactive_text":"light1",

              "notif_group_dot":          "light0",
              "notif_group_title":        "light0",
              "notif_group_count":        "mid8",
              "notif_panel_item_bg":      "dark3",
              "notif_panel_item_hovered": "dark5",
              "notif_dismiss_hovered":    "dark6",
              "notif_dismiss_icon":       "light1",
              "notif_icon_bg":            "mid3",
              "notif_icon":               "dark0",
              "notif_time_grouped":       "mid8",
              "notif_body":               "mid9",

              // ------------------------------------------------------------
              // Notification Popup
              // ------------------------------------------------------------

              "notif_popup_bg":                  "dark2",
              "notif_popup_border":              "dark7",
              "notif_popup_app_name":            "light1",
              "notif_popup_close_bg":            "dark4",
              "notif_popup_close_hovered":       "mid6",
              "notif_popup_close_icon":          "light1",
              "notif_popup_summary":             "light2",
              "notif_popup_body":                "light0",
              "notif_popup_action_bg":           "dark4",
              "notif_popup_action_hovered":      "mid4",
              "notif_popup_action_text":         "mid9",
              "notif_popup_action_text_hovered": "dark0",

              // ------------------------------------------------------------
              // Media
              // ------------------------------------------------------------

              "media_status_playing": "light0",
              "media_status_other":   "light1",

              "media_progress_remaining": "dark5",
              "media_progress_wave":      "mid9",
              "media_progress_handle":    "mid9",
              "media_ctrl_icon":          "mid9",
              "media_ctrl_icon_hovered":  "light1",

              "media_dropdown_bg":              "dark2",
              "media_dropdown_item_hovered":    "dark5",
              "media_dropdown_player_active":   "light0",
              "media_dropdown_player_inactive": "mid7",
              "media_dropdown_dot_playing":     "mid8",
              "media_dropdown_dot_stopped":     "mid5",

              // ------------------------------------------------------------
              // App Launcher Session
              // ------------------------------------------------------------

              "mode_select_active_bg":     "dark6",
              "mode_select_inactive_bg":   "dark4",
              "mode_select_active_border": "mid5",
              "mode_select_active_text":   "light1",
              "mode_select_inactive_text": "mid8",

              "launcher_list_bg":        "dark4",
              "launcher_back_icon":      "mid8",
              "launcher_count_text":     "light1",
              "launcher_hint_text":      "light1",
              "launcher_item_active_bg": "dark6",
              "launcher_icon_bg":        "dark5",
              "launcher_app_name":       "light1",
              "launcher_app_desc":       "mid8",

              "session_list_bg":                 "dark4",
              "session_back_icon":               "mid8",
              "session_count_text":              "light1",
              "session_hint_text":               "light1",
              "session_item_active_bg":          "dark6",
              "session_app_name":                "light1",
              "session_app_desc":                "mid8",
              "session_icon_active_bg":          "mid4",
              "session_icon_inactive_bg":        "dark5",
              "session_icon_active":             "dark0",
              "session_icon_inactive":           "mid8",
              "session_chip_bg":                 "dark3",
              "session_chip_text":               "mid8",
              "session_workspace_active":        "mid4",
              "session_workspace_text_active":   "dark0",
              "session_workspace_text_inactive": "mid8",

              "search_bg":              "dark2",
              "search_border":          "mid4",
              "search_border_inactive": "dark7",
              "search_icon":            "mid8",
              "search_text":            "light2",
              "search_selection":       "mid4",
              "search_selected_text":   "dark0",
              "search_placeholder":     "mid8",

              // ------------------------------------------------------------
              // Rightbar
              // ------------------------------------------------------------

              "rightbar_gradient1": "dark2",
              "rightbar_gradient2": "dark2",
              "rightbar_gradient3": "dark0",
              "rightbar_gradient4": "dark0",
              "rightbar_gradient5": "dark3",

              "wallpaper_item_active_bg":       "dark4",
              "wallpaper_item_inactive_bg":     "dark2",
              "wallpaper_item_active_border":   "mid5",
              "wallpaper_item_inactive_border": "dark7",
              "wallpaper_placeholder_bg":       "dark5",

              // ------------------------------------------------------------
              // OSD Popup
              // ------------------------------------------------------------

              "osd_icon":              "light0",
              "osd_value_text":        "light0",
              "osd_slider_track_bg":   "dark4",
              "osd_slider_track_fill": "mid6",
              "osd_slider_handle":     "mid7",

              "osd_brightness_icon":              "mid9",
              "osd_brightness_value_text":        "mid9",
              "osd_brightness_slider_track_bg":   "dark4",
              "osd_brightness_slider_track_fill": "mid5",
              "osd_brightness_slider_handle":     "mid6",

              // ------------------------------------------------------------
              // Leftbar
              // ------------------------------------------------------------

              "leftbar_gradient1":  "dark0",
              "leftbar_gradient2":  "dark0",
              "leftbar_gradient3":  "dark0",
              "leftbar_gradient4":  "dark0",
              "leftbar_gradient5":  "dark0",
              "leftbar_gradient6":  "dark3",
              "leftbar_gradient7":  "dark3",
              "leftbar_gradient8":  "dark0",
              "leftbar_gradient9":  "dark4",
              "leftbar_gradient10": "dark4",

              // ------------------------------------------------------------
              // Bottombar
              // ------------------------------------------------------------

              "bottombar_gradient1": "dark4",
              "bottombar_gradient2": "dark0",
              "bottombar_gradient3": "dark2",
              "bottombar_gradient4": "dark0",
              "bottombar_gradient5": "dark3",
              "bottombar_gradient6": "dark3",

              // ------------------------------------------------------------
              // List Apps
              // ------------------------------------------------------------

              "remove_menu_bg":      "dark3",
              "remove_menu_hovered": "mid6",
              "remove_menu_icon":    "light1",

              // ------------------------------------------------------------
              // Power Menu
              // ------------------------------------------------------------

              "power_item_active_bg":     "dark6",
              "power_item_inactive_bg":   "dark3",
              "power_item_active_icon":   "mid8",
              "power_item_inactive_icon": "light1",
              "power_item_active_label":  "mid9",
              "power_item_inactive_label":"light1",

              // ------------------------------------------------------------
              // Shell Settings
              // ------------------------------------------------------------

              "settings_sidebar_bg":       "dark3",
              "settings_tab_active_bg":    "dark6",
              "settings_tab_hovered_bg":   "dark5",
              "settings_tab_active_text":  "light0",
              "settings_tab_inactive_text":"mid8",

              "variant_active_bg":    "dark6",
              "variant_inactive_bg":  "dark3",
              "variant_active_text":  "light0",
              "variant_inactive_text":"mid8",

              "mode_selector_active_bg":     "dark6",
              "mode_selector_inactive_bg":   "dark3",
              "mode_selector_active_text":   "light0",
              "mode_selector_inactive_text": "mid8",

              // ------------------------------------------------------------
              // Workspace Overview
              // ------------------------------------------------------------

              "ws_card_active_bg":       "dark5",
              "ws_card_inactive_bg":     "dark3",
              "ws_card_drop_bg":         "mid4",
              "ws_card_active_border":   "mid5",
              "ws_card_key_border":      "mid8",
              "ws_card_drop_border":     "mid5",
              "ws_card_inactive_border": "dark7",
              "ws_badge_active_bg":      "mid5",
              "ws_badge_inactive_bg":    "dark5",
              "ws_badge_key_bg":         "mid8",
              "ws_badge_active_text":    "dark0",
              "ws_badge_inactive_text":  "mid7",
              "ws_status_active":        "light1",
              "ws_status_inactive":      "mid7",
              "ws_divider":              "dark7",
              "ws_app_hovered_bg":       "dark6",
              "ws_app_title":            "light1",
              "ws_app_close_icon":       "mid7",
              "ws_more_text":            "mid7",
              "ws_empty_text":           "dark8",

              "drag_visual_bg":     "dark5",
              "drag_visual_border": "mid5",
              "drag_visual_text":   "light1",

              "snapshot_input_bg":           "dark4",
              "snapshot_input_border":       "mid5",
              "snapshot_input_icon":         "mid8",
              "snapshot_input_text":         "light1",
              "snapshot_input_placeholder":  "mid7",
              "snapshot_input_selection":      "mid5",
              "snapshot_input_selected_text":  "dark0",
              "snapshot_warning_bg":         "mid6",
              "snapshot_warning_border":     "mid6",
              "snapshot_warning_text":       "mid6",
              "snapshot_info_bg":            "mid5",
              "snapshot_info_border":        "mid5",
              "snapshot_info_text":          "mid5",
              "snapshot_save_bg":            "dark4",
              "snapshot_save_hovered":       "dark6",
              "snapshot_save_text":          "light1"
          },

          "light": {

              // ------------------------------------------------------------
              // Functionality
              // ------------------------------------------------------------

              // Background
              "background":          "light9",
              "background_variant1": "light7",
              "background_variant2": "light5",
              "background_variant3": "light3",
              "background_variant4": "light6",

              // Header Title
              "header_title": "dark2",

              "lock_text": "light2",

              // Notification Item
              "notif_app_name": "dark3",
              "notif_time":     "mid3",
              "notif_summary":  "dark2",

              // Action Button
              "action_btn_hovered": "light5",
              "action_btn_icon":    "dark2",
              "action_btn_running": "dark3",

              // Close Button
              "close_btn_hovered": "light4",
              "close_btn_icon":    "dark2",

              // Scrollbar
              "scrollbar_thumb": "mid5",
              "scrollbar_track": "light6",

              // Toast
              "toast_bg":     "light6",
              "toast_border": "dark3",
              "toast_text":   "dark1",

              // Text
              "text":          "dark1",
              "text_variant1": "dark3",
              "text_variant2": "mid2",
              "text_variant3": "dark2",
              "text_variant4": "mid3",
              "text_variant5": "mid4",
              "text_variant6": "mid5",
              "text_variant7": "dark3",

              // Container Level
              "container_level_1":          "light2",
              "container_level_1_variant1": "light1",
              "container_level_1_variant2": "light0",
              "container_level_2":          "mid3",
              "container_level_2_variant1": "mid9",
              "icon_on_container":          "mid2",
              "text_on_container":          "dark3",

              // Outline
              "outline":         "mid5",
              "outline_variant": "light3",
              "divider":         "light4",

              // Error
              "error":    "mid4",
              "error_on": "light9",

              // Misc
              "shadow": "dark0",
              "scrim":  "dark0",

              // ------------------------------------------------------------
              // Topbar
              // ------------------------------------------------------------

              "topbar_gradient1": "light9",
              "topbar_gradient2": "light6",
              "topbar_gradient3": "light8",
              "topbar_gradient4": "light5",
              "topbar_gradient5": "light9",
              "topbar_gradient6": "light7",

              // ------------------------------------------------------------
              // Clipboard Panel
              // ------------------------------------------------------------

              "clipboard_item_bg":            "light7",
              "clipboard_item_hovered":       "light5",
              "clipboard_item_text":          "dark2",
              "clipboard_copy_hovered":       "mid7",
              "clipboard_copy_icon":          "light9",
              "clipboard_copy_icon_normal":   "dark2",
              "clipboard_delete_hovered":     "mid4",
              "clipboard_delete_icon_normal": "dark2",

              // ------------------------------------------------------------
              // Dashboard
              // ------------------------------------------------------------

              "arc_color":      "mid2",
              "circle_arc":     "light4",
              "background_arc": "light7",
              "gauge_normal":   "dark2",
              "gauge_warning":  "mid4",
              "gauge_critical": "mid4",

              "text_hour":   "dark1",
              "text_dots":   "mid3",
              "text_minute": "dark1",
              "text_date":   "dark3",

              "calendar_today_bg":    "mid6",
              "calendar_today_text":  "light9",
              "calendar_muted_text":  "light3",
              "calendar_normal_text": "dark2",

              // ------------------------------------------------------------
              // Menu
              // ------------------------------------------------------------

              "category_selected": "light5",
              "category_hovered":  "light7",

              "context_menu_bg":      "light8",
              "context_menu_hovered": "light5",

              // ------------------------------------------------------------
              // Panel Settings
              // ------------------------------------------------------------

              "wifi_btn_active":   "light4",
              "wifi_btn_inactive": "light6",

              "bt_btn_active":   "light4",
              "bt_btn_inactive": "light6",

              "nightmode_btn_active":   "mid8",
              "nightmode_btn_inactive": "light6",

              "dnd_btn_active":   "mid8",
              "dnd_btn_inactive": "light6",

              "colorpicker_btn_bg":   "light5",
              "colorpicker_btn_icon": "dark3",

              "audio_btn_bg":   "light5",
              "audio_btn_icon": "mid2",

              "brightness_slider_track_bg":       "light6",
              "brightness_slider_track_fill":     "mid4",
              "brightness_slider_handle":         "mid3",
              "brightness_slider_handle_pressed": "mid2",

              "volume_slider_track_bg":       "light6",
              "volume_slider_track_fill":     "mid6",
              "volume_slider_handle":         "mid5",
              "volume_slider_handle_pressed": "mid4",

              "notif_btn_hovered": "mid7",
              "notif_btn_icon":    "dark2",

              "notif_item_bg": "light6",

              // ------------------------------------------------------------
              // Panel Wifi
              // ------------------------------------------------------------

              "net_item_bg":              "light7",
              "net_item_hovered":         "light5",
              "net_icon_connected":       "mid2",
              "net_icon_disconnected":    "mid5",
              "net_ssid_text":            "dark2",
              "net_connected_text":       "dark3",
              "net_lock_icon":            "mid3",
              "net_toggle_active_bg":     "mid6",
              "net_toggle_inactive_bg":   "light5",
              "net_toggle_active_text":   "light9",
              "net_toggle_inactive_text": "mid3",

              "pwd_back_btn_hovered":     "light5",
              "pwd_back_btn_icon":        "dark2",
              "pwd_ssid_text":            "dark2",
              "pwd_input_bg":             "light6",
              "pwd_input_border":         "mid5",
              "pwd_input_text":           "dark2",
              "pwd_input_selection":      "mid5",
              "pwd_input_selected":       "light9",
              "pwd_eye_icon":             "mid4",
              "pwd_connect_bg":           "mid6",
              "pwd_connect_hovered":      "mid4",
              "pwd_connect_text":         "light9",
              "pwd_connect_text_hovered": "light9",

              // ------------------------------------------------------------
              // Panel Bluetooth
              // ------------------------------------------------------------

              "bt_toggle_active_bg":   "mid6",
              "bt_toggle_inactive_bg": "light6",
              "bt_toggle_knob":        "light8",

              "bt_device_item_bg":              "light7",
              "bt_device_item_hovered":         "light5",
              "bt_device_icon_connected":       "mid2",
              "bt_device_icon_disconnected":    "mid5",
              "bt_device_name":                 "dark2",
              "bt_device_status_connected":     "mid2",
              "bt_device_status_processing":    "mid5",
              "bt_device_status_paired":        "mid4",
              "bt_device_toggle_active_bg":     "mid7",
              "bt_device_toggle_inactive_bg":   "light4",
              "bt_device_toggle_loading_bg":    "light6",
              "bt_device_toggle_active_text":   "dark3",
              "bt_device_toggle_inactive_text": "dark2",
              "bt_device_toggle_loading_text":  "mid4",

              // ------------------------------------------------------------
              // Panel Audio
              // ------------------------------------------------------------

              "audio_item_active_bg":       "light4",
              "audio_item_inactive_bg":     "light6",
              "audio_item_active_icon":     "mid2",
              "audio_item_inactive_icon":   "dark2",
              "audio_item_text":            "dark2",
              "audio_toggle_active_bg":     "mid7",
              "audio_toggle_inactive_bg":   "light5",
              "audio_toggle_active_text":   "dark3",
              "audio_toggle_inactive_text": "dark2",

              // ------------------------------------------------------------
              // Panel Notifications
              // ------------------------------------------------------------

              "tab_active_bg":    "light4",
              "tab_inactive_bg":  "light7",
              "tab_active_text":  "dark3",
              "tab_inactive_text":"dark2",

              "notif_group_dot":          "dark3",
              "notif_group_title":        "dark3",
              "notif_group_count":        "mid3",
              "notif_panel_item_bg":      "light7",
              "notif_panel_item_hovered": "light5",
              "notif_dismiss_hovered":    "light4",
              "notif_dismiss_icon":       "dark2",
              "notif_icon_bg":            "mid7",
              "notif_icon":               "light9",
              "notif_time_grouped":       "mid3",
              "notif_body":               "mid2",

              // ------------------------------------------------------------
              // Notification Popup
              // ------------------------------------------------------------

              "notif_popup_bg":                  "light8",
              "notif_popup_border":              "light3",
              "notif_popup_app_name":            "dark2",
              "notif_popup_close_bg":            "light6",
              "notif_popup_close_hovered":       "mid4",
              "notif_popup_close_icon":          "dark2",
              "notif_popup_summary":             "dark1",
              "notif_popup_body":                "dark3",
              "notif_popup_action_bg":           "light6",
              "notif_popup_action_hovered":      "mid6",
              "notif_popup_action_text":         "mid2",
              "notif_popup_action_text_hovered": "light9",

              // ------------------------------------------------------------
              // Media
              // ------------------------------------------------------------

              "media_status_playing": "dark3",
              "media_status_other":   "dark2",

              "media_progress_remaining": "light5",
              "media_progress_wave":      "mid2",
              "media_progress_handle":    "mid2",
              "media_ctrl_icon":          "mid2",
              "media_ctrl_icon_hovered":  "dark2",

              "media_dropdown_bg":              "light8",
              "media_dropdown_item_hovered":    "light5",
              "media_dropdown_player_active":   "dark3",
              "media_dropdown_player_inactive": "mid4",
              "media_dropdown_dot_playing":     "mid3",
              "media_dropdown_dot_stopped":     "mid6",

              // ------------------------------------------------------------
              // App Launcher Session
              // ------------------------------------------------------------

              "mode_select_active_bg":     "light4",
              "mode_select_inactive_bg":   "light6",
              "mode_select_active_border": "mid5",
              "mode_select_active_text":   "dark2",
              "mode_select_inactive_text": "mid3",

              "launcher_list_bg":        "light6",
              "launcher_back_icon":      "mid3",
              "launcher_count_text":     "dark2",
              "launcher_hint_text":      "dark2",
              "launcher_item_active_bg": "light4",
              "launcher_icon_bg":        "light5",
              "launcher_app_name":       "dark2",
              "launcher_app_desc":       "mid3",

              "session_list_bg":                 "light6",
              "session_back_icon":               "mid3",
              "session_count_text":              "dark2",
              "session_hint_text":               "dark2",
              "session_item_active_bg":          "light4",
              "session_app_name":                "dark2",
              "session_app_desc":                "mid3",
              "session_icon_active_bg":          "mid6",
              "session_icon_inactive_bg":        "light5",
              "session_icon_active":             "light9",
              "session_icon_inactive":           "mid3",
              "session_chip_bg":                 "light7",
              "session_chip_text":               "mid3",
              "session_workspace_active":        "mid6",
              "session_workspace_text_active":   "light9",
              "session_workspace_text_inactive": "mid3",

              "search_bg":              "light8",
              "search_border":          "mid5",
              "search_border_inactive": "light3",
              "search_icon":            "mid3",
              "search_text":            "dark1",
              "search_selection":       "mid5",
              "search_selected_text":   "light9",
              "search_placeholder":     "mid3",

              // ------------------------------------------------------------
              // Rightbar
              // ------------------------------------------------------------

              "rightbar_gradient1": "light7",
              "rightbar_gradient2": "light7",
              "rightbar_gradient3": "light9",
              "rightbar_gradient4": "light9",
              "rightbar_gradient5": "light6",

              "wallpaper_item_active_bg":       "light6",
              "wallpaper_item_inactive_bg":     "light8",
              "wallpaper_item_active_border":   "mid5",
              "wallpaper_item_inactive_border": "light3",
              "wallpaper_placeholder_bg":       "light5",

              // ------------------------------------------------------------
              // OSD Popup
              // ------------------------------------------------------------

              "osd_icon":              "dark3",
              "osd_value_text":        "dark3",
              "osd_slider_track_bg":   "light6",
              "osd_slider_track_fill": "mid5",
              "osd_slider_handle":     "mid4",

              "osd_brightness_icon":              "mid2",
              "osd_brightness_value_text":        "mid2",
              "osd_brightness_slider_track_bg":   "light6",
              "osd_brightness_slider_track_fill": "mid6",
              "osd_brightness_slider_handle":     "mid5",

              // ------------------------------------------------------------
              // Leftbar
              // ------------------------------------------------------------

              "leftbar_gradient1":  "light9",
              "leftbar_gradient2":  "light9",
              "leftbar_gradient3":  "light9",
              "leftbar_gradient4":  "light9",
              "leftbar_gradient5":  "light9",
              "leftbar_gradient6":  "light6",
              "leftbar_gradient7":  "light6",
              "leftbar_gradient8":  "light9",
              "leftbar_gradient9":  "light5",
              "leftbar_gradient10": "light5",

              // ------------------------------------------------------------
              // Bottombar
              // ------------------------------------------------------------

              "bottombar_gradient1": "light6",
              "bottombar_gradient2": "light9",
              "bottombar_gradient3": "light7",
              "bottombar_gradient4": "light9",
              "bottombar_gradient5": "light6",
              "bottombar_gradient6": "light6",

              // ------------------------------------------------------------
              // List Apps
              // ------------------------------------------------------------

              "remove_menu_bg":      "light7",
              "remove_menu_hovered": "mid4",
              "remove_menu_icon":    "dark2",

              // ------------------------------------------------------------
              // Power Menu
              // ------------------------------------------------------------

              "power_item_active_bg":     "light4",
              "power_item_inactive_bg":   "light6",
              "power_item_active_icon":   "mid3",
              "power_item_inactive_icon": "dark2",
              "power_item_active_label":  "mid2",
              "power_item_inactive_label":"dark2",

              // ------------------------------------------------------------
              // Shell Settings
              // ------------------------------------------------------------

              "settings_sidebar_bg":       "light7",
              "settings_tab_active_bg":    "light4",
              "settings_tab_hovered_bg":   "light5",
              "settings_tab_active_text":  "dark3",
              "settings_tab_inactive_text":"mid3",

              "variant_active_bg":    "light4",
              "variant_inactive_bg":  "light7",
              "variant_active_text":  "dark3",
              "variant_inactive_text":"mid3",

              "mode_selector_active_bg":     "light4",
              "mode_selector_inactive_bg":   "light7",
              "mode_selector_active_text":   "dark3",
              "mode_selector_inactive_text": "mid3",

              // ------------------------------------------------------------
              // Workspace Overview
              // ------------------------------------------------------------

              "ws_card_active_bg":       "light5",
              "ws_card_inactive_bg":     "light7",
              "ws_card_drop_bg":         "mid6",
              "ws_card_active_border":   "mid5",
              "ws_card_key_border":      "mid3",
              "ws_card_drop_border":     "mid5",
              "ws_card_inactive_border": "light3",
              "ws_badge_active_bg":      "mid5",
              "ws_badge_inactive_bg":    "light5",
              "ws_badge_key_bg":         "mid3",
              "ws_badge_active_text":    "light9",
              "ws_badge_inactive_text":  "mid4",
              "ws_status_active":        "dark2",
              "ws_status_inactive":      "mid4",
              "ws_divider":              "light3",
              "ws_app_hovered_bg":       "light4",
              "ws_app_title":            "dark2",
              "ws_app_close_icon":       "mid4",
              "ws_more_text":            "mid4",
              "ws_empty_text":           "light3",

              "drag_visual_bg":     "light5",
              "drag_visual_border": "mid5",
              "drag_visual_text":   "dark2",

              "snapshot_input_bg":           "light6",
              "snapshot_input_border":       "mid5",
              "snapshot_input_icon":         "mid3",
              "snapshot_input_text":         "dark2",
              "snapshot_input_placeholder":  "mid4",
              "snapshot_input_selection":      "mid5",
              "snapshot_input_selected_text":  "light9",
              "snapshot_warning_bg":         "mid4",
              "snapshot_warning_border":     "mid4",
              "snapshot_warning_text":       "mid4",
              "snapshot_info_bg":            "mid5",
              "snapshot_info_border":        "mid5",
              "snapshot_info_text":          "mid5",
              "snapshot_save_bg":            "light6",
              "snapshot_save_hovered":       "light4",
              "snapshot_save_text":          "dark2"
          }
      }

    })

    // ================================================================
    // RESOLVER — satu fungsi untuk semua semantic key
    // ================================================================
    function get(semanticKey, fallback) {
      var _ = _reloadTick
        var engineMap = mappings[engine]
        if (!engineMap) return fallback ?? "transparent"
        var modeMap = engineMap[mode]
        if (!modeMap) {
            console.warn("Colors: unknown mode '" + mode + "' for engine '" + engine + "'")
            return fallback ?? "transparent"
        }
        var rawKey = modeMap[semanticKey]
        if (rawKey === undefined) {
            console.warn("Colors: unmapped semantic key '" + semanticKey + "'")
            return fallback ?? "transparent"
        }
        return d[rawKey] ?? fallback ?? "transparent"
    }

    // ================================================================
    // SEMANTIC PROPERTIES 
    // ================================================================
    
    // ------------------------------------------------------------
    // Functionality
    // ------------------------------------------------------------

    // --- Background ---
    readonly property color background:          get("background")
    readonly property color background_variant1: get("background_variant1")
    readonly property color background_variant2: get("background_variant2")
    readonly property color background_variant3: get("background_variant3")

    // --- Action Button ---
    readonly property color action_btn_hovered: get("action_btn_hovered")
    readonly property color action_btn_icon:    get("action_btn_icon")
    readonly property color action_btn_running: get("action_btn_running")

    // --- Header Title ---
    readonly property color header_title:       get("header_title")

    // --- Lock Screen ---
    readonly property color lock_text: get("lock_text")

    // --- Notification Item ---
    readonly property color notif_app_name: get("notif_app_name")
    readonly property color notif_time:     get("notif_time")
    readonly property color notif_summary:  get("notif_summary")
    
    // --- Scrollbar ---
    readonly property color scrollbar_thumb: get("scrollbar_thumb")
    readonly property color scrollbar_track: get("scrollbar_track")

    // --- Close Button ---
    readonly property color close_btn_hovered: get("close_btn_hovered")
    readonly property color close_btn_icon:    get("close_btn_icon")

    // --- Toast ---
    readonly property color toast_bg:     get("toast_bg")
    readonly property color toast_border: get("toast_border")
    readonly property color toast_text:   get("toast_text")

    // --- Text ---
    readonly property color text:          get("text")
    readonly property color text_variant1: get("text_variant1")
    readonly property color text_variant2: get("text_variant2")
    readonly property color text_variant3: get("text_variant3")
    readonly property color text_variant4: get("text_variant4")
    readonly property color text_variant5: get("text_variant5")
    readonly property color text_variant6: get("text_variant6")
    readonly property color text_variant7: get("text_variant7")

    // --- Container Levels ---
    readonly property color container_level_1:          get("container_level_1")
    readonly property color container_level_1_variant1: get("container_level_1_variant1")
    readonly property color container_level_1_variant2: get("container_level_1_variant2") 
    readonly property color container_level_2:          get("container_level_2")
    readonly property color container_level_2_variant1: get("container_level_2_variant1")
    readonly property color icon_on_container:          get("icon_on_container")
    readonly property color text_on_container:          get("text_on_container")

    // --- Outline ---
    readonly property color outline:         get("outline")
    readonly property color outline_variant: get("outline_variant")
    
    // --- Divider ---
    readonly property color divider: get("divider")

    // --- Error ---
    readonly property color error:    get("error")
    readonly property color error_on: get("error_on")

    // --- Misc ---
    readonly property color shadow: get("shadow", "#000000")
    readonly property color scrim:  get("scrim",  "#000000")

    // ------------------------------------------------------------
    // Topbar
    // ------------------------------------------------------------

    // --- Topbar ---
    readonly property color topbar_gradient1: get("topbar_gradient1")
    readonly property color topbar_gradient2: get("topbar_gradient2")
    readonly property color topbar_gradient3: get("topbar_gradient3")
    readonly property color topbar_gradient4: get("topbar_gradient4")
    readonly property color topbar_gradient5: get("topbar_gradient5")
    readonly property color topbar_gradient6: get("topbar_gradient6")

    // ------------------------------------------------------------
    // Clipboard Panel
    // ------------------------------------------------------------

    // --- Clipboard Item ---
    readonly property color clipboard_item_bg:            get("clipboard_item_bg")
    readonly property color clipboard_item_hovered:       get("clipboard_item_hovered")
    readonly property color clipboard_item_text:          get("clipboard_item_text")
    readonly property color clipboard_copy_hovered:       get("clipboard_copy_hovered")
    readonly property color clipboard_copy_icon:          get("clipboard_copy_icon")
    readonly property color clipboard_copy_icon_normal:   get("clipboard_copy_icon_normal")
    readonly property color clipboard_delete_hovered:     get("clipboard_delete_hovered")
    readonly property color clipboard_delete_icon_normal: get("clipboard_delete_icon_normal")

    // ------------------------------------------------------------
    // Dashboard
    // ------------------------------------------------------------

    // --- Arc / Gauge ---
    readonly property color arc_color:      get("arc_color")
    readonly property color circle_arc:     get("circle_arc")
    readonly property color background_arc: get("background_arc")
    readonly property color gauge_normal:   get("gauge_normal")
    readonly property color gauge_warning:  get("gauge_warning")
    readonly property color gauge_critical: get("gauge_critical")

    // --- Dashboard Clock ---
    readonly property color text_hour:   get("text_hour")
    readonly property color text_dots:   get("text_dots")
    readonly property color text_minute: get("text_minute")
    readonly property color text_date:   get("text_date")

    // --- Calendar ---
    readonly property color calendar_today_bg:    get("calendar_today_bg")
    readonly property color calendar_today_text:  get("calendar_today_text")
    readonly property color calendar_muted_text:  get("calendar_muted_text")
    readonly property color calendar_normal_text: get("calendar_normal_text")

    // ------------------------------------------------------------
    // Menu
    // ------------------------------------------------------------

    // --- Category List ---
    readonly property color category_selected: get("category_selected")
    readonly property color category_hovered:  get("category_hovered")

    // --- Context Menu ---
    readonly property color context_menu_bg:      get("context_menu_bg")
    readonly property color context_menu_hovered: get("context_menu_hovered")

    // ------------------------------------------------------------
    // Panel Settings
    // ------------------------------------------------------------

    // --- Wifi Button ---
    readonly property color wifi_btn_active:   get("wifi_btn_active")
    readonly property color wifi_btn_inactive: get("wifi_btn_inactive")

    // --- Bluetooth Button --- 
    readonly property color bt_btn_active:   get("bt_btn_active")
    readonly property color bt_btn_inactive: get("bt_btn_inactive")

    // --- Night Mode Button ---
    readonly property color nightmode_btn_active:   get("nightmode_btn_active")
    readonly property color nightmode_btn_inactive: get("nightmode_btn_inactive")

    // --- DND Button ---
    readonly property color dnd_btn_active:   get("dnd_btn_active")
    readonly property color dnd_btn_inactive: get("dnd_btn_inactive")

    // --- Color Picker Button ---
    readonly property color colorpicker_btn_bg:   get("colorpicker_btn_bg")
    readonly property color colorpicker_btn_icon: get("colorpicker_btn_icon")

    // --- Audio Button ---
    readonly property color audio_btn_bg:   get("audio_btn_bg")
    readonly property color audio_btn_icon: get("audio_btn_icon")

    // --- Brightness Slider ---
    readonly property color brightness_slider_track_bg:       get("brightness_slider_track_bg")
    readonly property color brightness_slider_track_fill:     get("brightness_slider_track_fill")
    readonly property color brightness_slider_handle:         get("brightness_slider_handle")
    readonly property color brightness_slider_handle_pressed: get("brightness_slider_handle_pressed")

    // --- Volume Slider ---
    readonly property color volume_slider_track_bg:       get("volume_slider_track_bg")
    readonly property color volume_slider_track_fill:     get("volume_slider_track_fill")
    readonly property color volume_slider_handle:         get("volume_slider_handle")
    readonly property color volume_slider_handle_pressed: get("volume_slider_handle_pressed")

    // --- Notification Button ---
    readonly property color notif_btn_hovered: get("notif_btn_hovered")
    readonly property color notif_btn_icon:    get("notif_btn_icon")

    // --- Notification Item ---
    readonly property color notif_item_bg:  get("notif_item_bg")

    // ------------------------------------------------------------
    // Panel Wifi
    // ------------------------------------------------------------

    // --- Wifi Network Item ---
    readonly property color net_item_bg:              get("net_item_bg")
    readonly property color net_item_hovered:         get("net_item_hovered")
    readonly property color net_icon_connected:       get("net_icon_connected")
    readonly property color net_icon_disconnected:    get("net_icon_disconnected")
    readonly property color net_ssid_text:            get("net_ssid_text")
    readonly property color net_connected_text:       get("net_connected_text")
    readonly property color net_lock_icon:            get("net_lock_icon")
    readonly property color net_toggle_active_bg:     get("net_toggle_active_bg")
    readonly property color net_toggle_inactive_bg:   get("net_toggle_inactive_bg")
    readonly property color net_toggle_active_text:   get("net_toggle_active_text")
    readonly property color net_toggle_inactive_text: get("net_toggle_inactive_text")

    // --- Password Form ---
    readonly property color pwd_back_btn_hovered:     get("pwd_back_btn_hovered")
    readonly property color pwd_back_btn_icon:        get("pwd_back_btn_icon")
    readonly property color pwd_ssid_text:            get("pwd_ssid_text")
    readonly property color pwd_input_bg:             get("pwd_input_bg")
    readonly property color pwd_input_border:         get("pwd_input_border")
    readonly property color pwd_input_text:           get("pwd_input_text")
    readonly property color pwd_input_selection:      get("pwd_input_selection")
    readonly property color pwd_input_selected:       get("pwd_input_selected")
    readonly property color pwd_eye_icon:             get("pwd_eye_icon")
    readonly property color pwd_connect_bg:           get("pwd_connect_bg")
    readonly property color pwd_connect_hovered:      get("pwd_connect_hovered")
    readonly property color pwd_connect_text:         get("pwd_connect_text")
    readonly property color pwd_connect_text_hovered: get("pwd_connect_text_hovered")

    // ------------------------------------------------------------
    // Panel Bluetooth
    // ------------------------------------------------------------

    // --- Bluetooth Header ---
    readonly property color bt_toggle_active_bg:   get("bt_toggle_active_bg")
    readonly property color bt_toggle_inactive_bg: get("bt_toggle_inactive_bg")
    readonly property color bt_toggle_knob:        get("bt_toggle_knob")

    // --- Bluetooth Device Item ---
    readonly property color bt_device_item_bg:              get("bt_device_item_bg")
    readonly property color bt_device_item_hovered:         get("bt_device_item_hovered")
    readonly property color bt_device_icon_connected:       get("bt_device_icon_connected")
    readonly property color bt_device_icon_disconnected:    get("bt_device_icon_disconnected")
    readonly property color bt_device_name:                 get("bt_device_name")
    readonly property color bt_device_status_connected:     get("bt_device_status_connected")
    readonly property color bt_device_status_processing:    get("bt_device_status_processing")
    readonly property color bt_device_status_paired:        get("bt_device_status_paired")
    readonly property color bt_device_toggle_active_bg:     get("bt_device_toggle_active_bg")
    readonly property color bt_device_toggle_inactive_bg:   get("bt_device_toggle_inactive_bg")
    readonly property color bt_device_toggle_loading_bg:    get("bt_device_toggle_loading_bg")
    readonly property color bt_device_toggle_active_text:   get("bt_device_toggle_active_text")
    readonly property color bt_device_toggle_inactive_text: get("bt_device_toggle_inactive_text")
    readonly property color bt_device_toggle_loading_text:  get("bt_device_toggle_loading_text")

    // ------------------------------------------------------------
    // Panel Audio
    // ------------------------------------------------------------

    // --- Audio Output List ---
    readonly property color audio_item_active_bg:       get("audio_item_active_bg")
    readonly property color audio_item_inactive_bg:     get("audio_item_inactive_bg")
    readonly property color audio_item_active_icon:     get("audio_item_active_icon")
    readonly property color audio_item_inactive_icon:   get("audio_item_inactive_icon")
    readonly property color audio_item_text:            get("audio_item_text")
    readonly property color audio_toggle_active_bg:     get("audio_toggle_active_bg")
    readonly property color audio_toggle_inactive_bg:   get("audio_toggle_inactive_bg")
    readonly property color audio_toggle_active_text:   get("audio_toggle_active_text")
    readonly property color audio_toggle_inactive_text: get("audio_toggle_inactive_text")

    // ------------------------------------------------------------
    // Panel Notifications
    // ------------------------------------------------------------

    // --- Notification Tab ---
    readonly property color tab_active_bg:    get("tab_active_bg")
    readonly property color tab_inactive_bg:  get("tab_inactive_bg")
    readonly property color tab_active_text:  get("tab_active_text")
    readonly property color tab_inactive_text: get("tab_inactive_text")

    // --- Notification Panel Item ---
    readonly property color notif_group_dot:          get("notif_group_dot")
    readonly property color notif_group_title:        get("notif_group_title")
    readonly property color notif_group_count:        get("notif_group_count")
    readonly property color notif_panel_item_bg:      get("notif_panel_item_bg")
    readonly property color notif_panel_item_hovered: get("notif_panel_item_hovered")
    readonly property color notif_dismiss_hovered:    get("notif_dismiss_hovered")
    readonly property color notif_dismiss_icon:       get("notif_dismiss_icon")
    readonly property color notif_icon_bg:            get("notif_icon_bg")
    readonly property color notif_icon:               get("notif_icon")
    readonly property color notif_time_grouped:       get("notif_time_grouped")
    readonly property color notif_body:               get("notif_body")
    

    // ------------------------------------------------------------
    // Notification Popup Item
    // ------------------------------------------------------------

    // --- Notification Popup Item ---
    readonly property color notif_popup_bg:                  get("notif_popup_bg")
    readonly property color notif_popup_border:              get("notif_popup_border")
    readonly property color notif_popup_app_name:            get("notif_popup_app_name")
    readonly property color notif_popup_close_bg:            get("notif_popup_close_bg")
    readonly property color notif_popup_close_hovered:       get("notif_popup_close_hovered")
    readonly property color notif_popup_close_icon:          get("notif_popup_close_icon")
    readonly property color notif_popup_summary:             get("notif_popup_summary")
    readonly property color notif_popup_body:                get("notif_popup_body")
    readonly property color notif_popup_action_bg:           get("notif_popup_action_bg")
    readonly property color notif_popup_action_hovered:      get("notif_popup_action_hovered")
    readonly property color notif_popup_action_text:         get("notif_popup_action_text")
    readonly property color notif_popup_action_text_hovered: get("notif_popup_action_text_hovered")

    // ------------------------------------------------------------
    // Media
    // ------------------------------------------------------------
    
    // --- Media ---
    readonly property color media_status_playing: get("media_status_playing")
    readonly property color media_status_other:   get("media_status_other")

    // --- Media Controls ---
    readonly property color media_progress_remaining: get("media_progress_remaining")
    readonly property color media_progress_wave:      get("media_progress_wave")
    readonly property color media_progress_handle:    get("media_progress_handle")
    readonly property color media_ctrl_icon:          get("media_ctrl_icon")
    readonly property color media_ctrl_icon_hovered:  get("media_ctrl_icon_hovered")

    // --- Media Dropdown ---
    readonly property color media_dropdown_bg:              get("media_dropdown_bg")
    readonly property color media_dropdown_item_hovered:    get("media_dropdown_item_hovered")
    readonly property color media_dropdown_player_active:   get("media_dropdown_player_active")
    readonly property color media_dropdown_player_inactive: get("media_dropdown_player_inactive")
    readonly property color media_dropdown_dot_playing:     get("media_dropdown_dot_playing")
    readonly property color media_dropdown_dot_stopped:     get("media_dropdown_dot_stopped")

    // ------------------------------------------------------------
    // App Launcher Session
    // ------------------------------------------------------------
    
    // --- Mode Select ---
    readonly property color mode_select_active_bg:     get("mode_select_active_bg")
    readonly property color mode_select_inactive_bg:   get("mode_select_inactive_bg")
    readonly property color mode_select_active_border: get("mode_select_active_border")
    readonly property color mode_select_active_text:   get("mode_select_active_text")
    readonly property color mode_select_inactive_text: get("mode_select_inactive_text")

    // --- App Launcher List ---
    readonly property color launcher_list_bg:        get("launcher_list_bg")
    readonly property color launcher_back_icon:      get("launcher_back_icon")
    readonly property color launcher_count_text:     get("launcher_count_text")
    readonly property color launcher_hint_text:      get("launcher_hint_text")
    readonly property color launcher_item_active_bg: get("launcher_item_active_bg")
    readonly property color launcher_icon_bg:        get("launcher_icon_bg")
    readonly property color launcher_app_name:       get("launcher_app_name")
    readonly property color launcher_app_desc:       get("launcher_app_desc")

    // --- Session Launcher ---
    readonly property color session_list_bg:                 get("session_list_bg")
    readonly property color session_back_icon:               get("session_back_icon")
    readonly property color session_count_text:              get("session_count_text")
    readonly property color session_hint_text:               get("session_hint_text")
    readonly property color session_item_active_bg:          get("session_item_active_bg")
    readonly property color session_app_name:                get("session_app_name")
    readonly property color session_app_desc:                get("session_app_desc")
    readonly property color session_icon_active_bg:          get("session_icon_active_bg")
    readonly property color session_icon_inactive_bg:        get("session_icon_inactive_bg")
    readonly property color session_icon_active:             get("session_icon_active")
    readonly property color session_icon_inactive:           get("session_icon_inactive")
    readonly property color session_chip_bg:                 get("session_chip_bg")
    readonly property color session_chip_text:               get("session_chip_text")
    readonly property color session_workspace_active:        get("session_workspace_active")
    readonly property color session_workspace_text_active:   get("session_workspace_text_active")
    readonly property color session_workspace_text_inactive: get("session_workspace_text_inactive")

    // --- Search Bar ---
    readonly property color search_bg:              get("search_bg")
    readonly property color search_border:          get("search_border")
    readonly property color search_border_inactive: get("search_border_inactive")
    readonly property color search_icon:            get("search_icon")
    readonly property color search_text:            get("search_text")
    readonly property color search_selection:       get("search_selection")
    readonly property color search_selected_text:   get("search_selected_text")
    readonly property color search_placeholder:     get("search_placeholder")

    // ------------------------------------------------------------
    // Rightbar
    // ------------------------------------------------------------

    // --- Rightbar ---
    readonly property color rightbar_gradient1: get("rightbar_gradient1")
    readonly property color rightbar_gradient2: get("rightbar_gradient2")
    readonly property color rightbar_gradient3: get("rightbar_gradient3")
    readonly property color rightbar_gradient4: get("rightbar_gradient4")
    readonly property color rightbar_gradient5: get("rightbar_gradient5")

    // --- Wallpaper Picker Item ---
    readonly property color wallpaper_item_active_bg:       get("wallpaper_item_active_bg")
    readonly property color wallpaper_item_inactive_bg:     get("wallpaper_item_inactive_bg")
    readonly property color wallpaper_item_active_border:   get("wallpaper_item_active_border")
    readonly property color wallpaper_item_inactive_border: get("wallpaper_item_inactive_border")
    readonly property color wallpaper_placeholder_bg:       get("wallpaper_placeholder_bg")

    // ------------------------------------------------------------
    // OSD POPUP
    // ------------------------------------------------------------

    // --- OSD Volume ---
    readonly property color osd_icon:              get("osd_icon")
    readonly property color osd_value_text:        get("osd_value_text")
    readonly property color osd_slider_track_bg:   get("osd_slider_track_bg")
    readonly property color osd_slider_track_fill: get("osd_slider_track_fill")
    readonly property color osd_slider_handle:     get("osd_slider_handle")

    // --- OSD Brightness ---
    readonly property color osd_brightness_icon:              get("osd_brightness_icon")
    readonly property color osd_brightness_value_text:        get("osd_brightness_value_text")
    readonly property color osd_brightness_slider_track_bg:   get("osd_brightness_slider_track_bg")
    readonly property color osd_brightness_slider_track_fill: get("osd_brightness_slider_track_fill")
    readonly property color osd_brightness_slider_handle:     get("osd_brightness_slider_handle")

    // ------------------------------------------------------------
    // Leftbar
    // ------------------------------------------------------------

    // --- Leftbar ---
    readonly property color leftbar_gradient1:  get("leftbar_gradient1")
    readonly property color leftbar_gradient2:  get("leftbar_gradient2")
    readonly property color leftbar_gradient3:  get("leftbar_gradient3")
    readonly property color leftbar_gradient4:  get("leftbar_gradient4")
    readonly property color leftbar_gradient5:  get("leftbar_gradient5")
    readonly property color leftbar_gradient6:  get("leftbar_gradient6")
    readonly property color leftbar_gradient7:  get("leftbar_gradient7")
    readonly property color leftbar_gradient8:  get("leftbar_gradient8")
    readonly property color leftbar_gradient9:  get("leftbar_gradient9")
    readonly property color leftbar_gradient10: get("leftbar_gradient10")

    // ------------------------------------------------------------
    // Bottombar
    // ------------------------------------------------------------

    // --- Bottombar ---
    readonly property color bottombar_gradient1: get("bottombar_gradient1")
    readonly property color bottombar_gradient2: get("bottombar_gradient2")
    readonly property color bottombar_gradient3: get("bottombar_gradient3")
    readonly property color bottombar_gradient4: get("bottombar_gradient4")
    readonly property color bottombar_gradient5: get("bottombar_gradient5")
    readonly property color bottombar_gradient6: get("bottombar_gradient6")

    // ------------------------------------------------------------
    // List Apps
    // ------------------------------------------------------------

    // --- Remove Menu ---
    readonly property color remove_menu_bg:      get("remove_menu_bg")
    readonly property color remove_menu_hovered: get("remove_menu_hovered")
    readonly property color remove_menu_icon:    get("remove_menu_icon")

    // ------------------------------------------------------------
    // Power Menu
    // ------------------------------------------------------------

    // --- Power Menu ---
    readonly property color power_item_active_bg:     get("power_item_active_bg")
    readonly property color power_item_inactive_bg:   get("power_item_inactive_bg")
    readonly property color power_item_active_icon:   get("power_item_active_icon")
    readonly property color power_item_inactive_icon: get("power_item_inactive_icon")
    readonly property color power_item_active_label:  get("power_item_active_label")
    readonly property color power_item_inactive_label:get("power_item_inactive_label")

    // ------------------------------------------------------------
    // Shell Settings
    // ------------------------------------------------------------

    // --- Shell Settings ---
    readonly property color settings_sidebar_bg: get("settings_sidebar_bg")

    // --- Shell Settings Tab ---
    readonly property color settings_tab_active_bg:    get("settings_tab_active_bg")
    readonly property color settings_tab_hovered_bg:   get("settings_tab_hovered_bg")
    readonly property color settings_tab_active_text:  get("settings_tab_active_text")
    readonly property color settings_tab_inactive_text:get("settings_tab_inactive_text")

    // --- Variant Selector ---
    readonly property color variant_active_bg:    get("variant_active_bg")
    readonly property color variant_inactive_bg:  get("variant_inactive_bg")
    readonly property color variant_active_text:  get("variant_active_text")
    readonly property color variant_inactive_text:get("variant_inactive_text")

    // --- Mode Selector ---
    readonly property color mode_selector_active_bg:     get("mode_selector_active_bg")
    readonly property color mode_selector_inactive_bg:   get("mode_selector_inactive_bg")
    readonly property color mode_selector_active_text:   get("mode_selector_active_text")
    readonly property color mode_selector_inactive_text: get("mode_selector_inactive_text")

    // ------------------------------------------------------------
    // Workspace Overview
    // ------------------------------------------------------------

    // --- Workspace Overview ---
    readonly property color ws_card_active_bg:      get("ws_card_active_bg")
    readonly property color ws_card_inactive_bg:    get("ws_card_inactive_bg")
    readonly property color ws_card_drop_bg:        get("ws_card_drop_bg")
    readonly property color ws_card_active_border:  get("ws_card_active_border")
    readonly property color ws_card_key_border:     get("ws_card_key_border")
    readonly property color ws_card_drop_border:    get("ws_card_drop_border")
    readonly property color ws_card_inactive_border:get("ws_card_inactive_border")
    readonly property color ws_badge_active_bg:     get("ws_badge_active_bg")
    readonly property color ws_badge_inactive_bg:   get("ws_badge_inactive_bg")
    readonly property color ws_badge_key_bg:        get("ws_badge_key_bg")
    readonly property color ws_badge_active_text:   get("ws_badge_active_text")
    readonly property color ws_badge_inactive_text: get("ws_badge_inactive_text")
    readonly property color ws_status_active:       get("ws_status_active")
    readonly property color ws_status_inactive:     get("ws_status_inactive")
    readonly property color ws_divider:             get("ws_divider")
    readonly property color ws_app_hovered_bg:      get("ws_app_hovered_bg")
    readonly property color ws_app_title:           get("ws_app_title")
    readonly property color ws_app_close_icon:      get("ws_app_close_icon")
    readonly property color ws_more_text:           get("ws_more_text")
    readonly property color ws_empty_text:          get("ws_empty_text")

    // --- Drag Visual ---
    readonly property color drag_visual_bg:     get("drag_visual_bg")
    readonly property color drag_visual_border: get("drag_visual_border")
    readonly property color drag_visual_text:   get("drag_visual_text")

    // --- Snapshot Session ---
    readonly property color snapshot_input_bg:          get("snapshot_input_bg")
    readonly property color snapshot_input_border:      get("snapshot_input_border")
    readonly property color snapshot_input_icon:        get("snapshot_input_icon")
    readonly property color snapshot_input_text:        get("snapshot_input_text")
    readonly property color snapshot_input_placeholder: get("snapshot_input_placeholder")
    readonly property color snapshot_input_selection:     get("snapshot_input_selection")
    readonly property color snapshot_input_selected_text: get("snapshot_input_selected_text")
    readonly property color snapshot_warning_bg:        get("snapshot_warning_bg")
    readonly property color snapshot_warning_border:    get("snapshot_warning_border")
    readonly property color snapshot_warning_text:      get("snapshot_warning_text")
    readonly property color snapshot_info_bg:           get("snapshot_info_bg")
    readonly property color snapshot_info_border:       get("snapshot_info_border")
    readonly property color snapshot_info_text:         get("snapshot_info_text")
    readonly property color snapshot_save_bg:           get("snapshot_save_bg")
    readonly property color snapshot_save_hovered:      get("snapshot_save_hovered")
    readonly property color snapshot_save_text:         get("snapshot_save_text")

    // ================================================================
    // LOADER
    // ================================================================
    FileView {
        id: colorFile
        path: Quickshell.shellDir + "/colors/colors.json"
        blockLoading: true
        watchChanges: true
        onFileChanged: reloadTimer.restart()
        onTextChanged: {
            try {
                root.d = JSON.parse(colorFile.text())
                root._reloadTick++
            } catch(e) { console.error("Colors parse error (watch):", e) }
        }
      }

    Timer {
    id: reloadTimer
    interval: 100
    onTriggered: colorFile.reload()
}

    Component.onCompleted: {
        try {
            root.d = JSON.parse(colorFile.text())
            root._reloadTick++
        } catch(e) { console.error("Colors parse error (init):", e) }
    }
}
