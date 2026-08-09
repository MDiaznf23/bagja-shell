-- #######################################################################################
-- BAGJA-SHELL HYPRLAND CONFIG (Lua - Hyprland 0.55+)
-- #######################################################################################
--

dofile(os.getenv("HOME") .. "/.config/hypr/colors_hyprland.lua")

hl.config({
    general = {
        col = {
            active_border   = active_border,   
            inactive_border = inactive_border,
        },
    },
})

--------------------
---- MONITORS ----
--------------------

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "dolphin"
local browser     = "brave"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP GDK_BACKEND QT_QPA_PLATFORM")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("dex --autostart --environment Hyprland")
    hl.exec_cmd("~/m3-colors-switch.sh")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd([[sleep 1 && WALL=$(awww query 2>/dev/null | awk -F': ' '{print $NF}' | head -1) && warnaza "${WALL:-~/Pictures/Wallpapers/caelestia.png}"]])
    hl.exec_cmd("qs")
    hl.exec_cmd("kbuildsycoca6 --noincremental")
    hl.exec_cmd("/usr/bin/kded6")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("/usr/lib/pam_kwallet_init")
    hl.exec_cmd("kwalletd6")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE",                        "24")
hl.env("HYPRCURSOR_SIZE",                     "24")
hl.env("QT_QPA_PLATFORM",                     "wayland")
hl.env("XDG_MENU_PREFIX",                     "arch-")
hl.env("QT_QPA_PLATFORMTHEME",                "qt5ct")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR",         "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("XDG_CURRENT_DESKTOP",                 "Hyprland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT",        "wayland")
hl.env("XDG_SESSION_TYPE",                    "wayland")
hl.env("XDG_SESSION_DESKTOP",                 "Hyprland")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in        = 5,
        gaps_out       = 10,
        border_size    = 2,
        col = {
            active_border   = active_border,
            inactive_border = inactive_border,
        },
        resize_on_border = true,
        allow_tearing    = false,
        layout           = "master",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled            = true,
            size               = 4,
            passes             = 2,
            ignore_opacity     = true,
            noise              = 0.0117,
            contrast           = 0.89,
            brightness         = 0.82,
            vibrancy           = 0.17,
            new_optimizations  = true,
            popups             = true,
            popups_ignorealpha = 0.2,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        -- pseudotile dihapus di 0.55
        preserve_split = true,
    },

    master = {
        new_status = "slave",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        -- vfr dipindah ke debug di 0.55
    },

    debug = {
        vfr = true,
    },

    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

-------------------
---- ANIMATIONS ----
-------------------

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default"      })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick"        })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 4,    bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 4,    bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 4,    bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick"        })

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("qs ipc call wallpaper toggle"))
hl.bind(mainMod .. " + Return",    hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + B",         hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("qs ipc call snapshotsession toggle"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("qs ipc call powermenu display"))
hl.bind(mainMod .. " + SHIFT + F",         hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + C",         hl.dsp.exec_cmd("cliphist list | qs ipc call clipboard open"))
hl.bind(mainMod .. " + SHIFT + Q",         hl.dsp.window.close())

-- Float + resize + center
hl.bind(mainMod .. " + V", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.resize({ x = 1300, y = 680, relative = false }))
    hl.dispatch(hl.dsp.window.center({ monitor = true }))
end)

hl.bind(mainMod .. " + D",   hl.dsp.exec_cmd("qs ipc call launcher toggle"))
hl.bind(mainMod .. " + L",   hl.dsp.exec_cmd("qs ipc call lockscreen lock"))
hl.bind(mainMod .. " + F",   hl.dsp.window.fullscreen({ mode = 0 }))
hl.bind(mainMod .. " + TAB", hl.dsp.exec_cmd("qs ipc call workspaceoverview toggle"))

hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("hyprctl keyword general:layout dwindle"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("hyprctl keyword general:layout master"))

hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Screenshots
hl.bind("Print",                   hl.dsp.exec_cmd([[grim ~/Pictures/Screenshots/screenshot_$(date +%Y%m%d_%H%M%S).png]]))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd([[grim -g "$(slurp)" ~/Pictures/Screenshots/screenshot_$(date +%Y%m%d_%H%M%S).png]]))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]))

hl.bind("CTRL + " .. mainMod .. " + left",  hl.dsp.focus({ workspace = "e-1" }))
hl.bind("CTRL + " .. mainMod .. " + right", hl.dsp.focus({ workspace = "e+1" }))

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left"  }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up"    }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down"  }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + S",              hl.dsp.workspace.toggle_special("magic"))
hl.bind("CTRL + " .. mainMod .. " + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+ && qs ipc call osd open"),  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%- && qs ipc call osd open"),       { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),                              { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),                           { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+ && qs ipc call osd open"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%- && qs ipc call osd open"),                  { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

------------------------------
---- WINDOWS & WORKSPACES ----
------------------------------

hl.window_rule({
    name    = "opacity-vscode",
    match   = { class = "code" },
    opacity = "0.95 0.90",
})

hl.window_rule({
    name    = "opacity-dolphin",
    match   = { class = "org.kde.dolphin" },
    opacity = "0.92 0.90",
})

hl.window_rule({
    name    = "opacity-pcmanfm",
    match   = { class = "pcmanfm" },
    opacity = "0.90 0.85",
})

hl.window_rule({
    name    = "opacity-thunar",
    match   = { class = "thunar" },
    opacity = "0.90 0.85",
})

hl.window_rule({
    name    = "opacity-nautilus",
    match   = { class = "org.gnome.Nautilus" },
    opacity = "0.90 0.85",
})

hl.window_rule({
    name  = "float-viewnior",
    match = { class = "viewnior" },
    float = true,
    size  = { 960, 540 },
    center = true,
})

hl.window_rule({
    name  = "float-haruna",
    match = { class = "org.kde.haruna" },
    float  = true,
    size   = { 1090, 615 },
    center = true,
})

hl.window_rule({
    name  = "float-mpv",
    match = { class = "mpv" },
    float  = true,
    size   = { 1090, 615 },
    center = true,
})

hl.window_rule({
    name  = "float-ark",
    match = { class = "org.kde.ark" },
    float  = true,
    size   = { 890, 500 },
    center = true,
})

hl.window_rule({
    name  = "float-portal-gtk",
    match = { class = "xdg-desktop-portal-gtk" },
    float  = true,
    size   = { 890, 500 },
    center = true,
})

hl.window_rule({
    name  = "float-abdownloadmanager",
    match = { class = "com-abdownloadmanager-desktop-AppKt" },
    float  = true,
    center = true,
})

hl.window_rule({
    name  = "float-audacious",
    match = { class = "audacious" },
    float  = true,
    size   = { 550, 410 },
    center = true,
})

hl.window_rule({
    name  = "float-wine",
    match = { class = "wine" },
    float = true,
})

hl.window_rule({
    name = "no-border-quickshell",
    match = { class = "^(org\\.quickshell)$", title = "^(quickshell)$" },
    border_size = 0,
})

hl.workspace_rule({ workspace = "1", persistent = true })
hl.workspace_rule({ workspace = "2", persistent = true })
hl.workspace_rule({ workspace = "3", persistent = true })
hl.workspace_rule({ workspace = "4", persistent = true })
hl.workspace_rule({ workspace = "5", persistent = true })

hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "pes-float",
    match = { class = "^(wine)$" },
    float = true,
})

hl.window_rule({
    name       = "fix-xwayland-drags",
    match      = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})

hl.window_rule({
    name  = "pip",
    match = { title = "Picture in picture" },
    float = true,
    pin   = true,
    size  = { "monitor_w*0.25", "monitor_h*0.25" },
    move  = { "monitor_w-window_w-20", "monitor_h-window_h-20" },
})
