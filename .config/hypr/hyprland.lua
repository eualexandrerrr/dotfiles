local mod = "SUPER"
local alt = "ALT"

local terminal    = "kitty"
local fileManager = "thunar"
local browser     = "google-chrome-stable"

local monitor_main = "DP-1"
local monitor_side = "DP-2"

hl.monitor({
    output    = monitor_side,
    mode      = "1920x1080",
    position  = "0x0",
    scale     = 1,
    transform = 1,
})

hl.monitor({
    output   = monitor_main,
    mode     = "2560x1440",
    position = "1080x0",
    scale    = 1,
})

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

hl.env("XCURSOR_SIZE",     "24")
hl.env("HYPRCURSOR_SIZE",  "24")
hl.env("GDK_BACKEND",      "wayland,x11,*")
hl.env("QT_QPA_PLATFORM",  "wayland;xcb")
hl.env("SDL_VIDEODRIVER",  "wayland")
hl.env("CLUTTER_BACKEND",  "wayland")
hl.env("TERMINAL",         terminal)
hl.env("BROWSER",          browser)

hl.env("LIBVA_DRIVER_NAME",            "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME",    "nvidia")
hl.env("GBM_BACKEND",                  "nvidia-drm")
hl.env("NVD_BACKEND",                  "direct")
hl.env("__GL_VRR_ALLOWED",             "0")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

pcall(require, "nandoroid/nandoroid")

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

for i = 1, 5  do hl.workspace_rule({ workspace = tostring(i), monitor = monitor_main }) end
for i = 6, 10 do hl.workspace_rule({ workspace = tostring(i), monitor = monitor_side }) end

hl.config({
    general = {
        gaps_in          = 4,
        gaps_out         = 8,
        border_size      = 2,
        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
        col = {
            active_border   = { colors = { "rgba(89b4faee)", "rgba(cba6f7ee)" }, angle = 45 },
            inactive_border = "rgba(45475aaa)",
        },
    },

    decoration = {
        rounding         = 10,
        rounding_power   = 2,
        active_opacity   = 1.0,
        inactive_opacity = 0.94,
        shadow = {
            enabled      = true,
            range        = 12,
            render_power = 3,
            color        = "rgba(11111baa)",
        },
        blur = {
            enabled           = true,
            size              = 6,
            passes            = 3,
            new_optimizations = true,
            vibrancy          = 0.1696,
        },
    },

    animations = { enabled = true },

    dwindle = {
        preserve_split = true,
        smart_resizing = true,
    },

    master = { new_status = "master" },

    input = {
        kb_layout    = "br",
        kb_variant   = "abnt2",
        follow_mouse = 1,
        sensitivity  = 0,
        repeat_rate  = 50,
        repeat_delay = 300,
        numlock_by_default = true,
    },

    xwayland = { force_zero_scaling = true },

    misc = {
        vrr                      = 1,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
        animate_manual_resizes   = true,
        enable_swallow           = true,
        swallow_regex            = "^(kitty)$",
    },
})

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1} } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1} } })
hl.curve("snappy",         { type = "spring", mass = 1, stiffness = 320, dampening = 32 })

hl.animation({ leaf = "global",     enabled = true, speed = 10,   bezier = "easeOutQuint" })
hl.animation({ leaf = "border",     enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",    enabled = true, speed = 4.79, spring = "snappy" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 4.1,  spring = "snappy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fade",       enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",     enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal),    { description = "Terminal" })
hl.bind(mod .. " + Q",      hl.dsp.exec_cmd(terminal),    { description = "Terminal" })
hl.bind(mod .. " + E",      hl.dsp.exec_cmd(fileManager), { description = "Arquivos" })
hl.bind(mod .. " + B",      hl.dsp.exec_cmd(browser),     { description = "Navegador" })
hl.bind(mod .. " + P",      hl.dsp.exec_cmd("hyprpicker -a"), { description = "Conta-gotas" })

hl.bind(mod .. " + C",           hl.dsp.window.close())
hl.bind(mod .. " + X",           hl.dsp.window.close())
hl.bind(mod .. " + V",           hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + F",           hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mod .. " + " .. alt .. " + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mod .. " + G",           hl.dsp.group.toggle())
hl.bind(mod .. " + J",           hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + SHIFT + C",   hl.dsp.window.center())

hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down" }))

hl.bind(mod .. " + SHIFT + left",  hl.dsp.window.swap({ direction = "left" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mod .. " + SHIFT + up",    hl.dsp.window.swap({ direction = "up" }))
hl.bind(mod .. " + SHIFT + down",  hl.dsp.window.swap({ direction = "down" }))

hl.bind(mod .. " + CTRL + left",  hl.dsp.group.prev())
hl.bind(mod .. " + CTRL + right", hl.dsp.group.next())

for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

hl.bind("Print",                  hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | swappy -f -"))
hl.bind(mod .. " + Print",        hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind(mod .. " + SHIFT + Print", hl.dsp.exec_cmd("wf-recorder -g \"$(slurp)\" -f $HOME/Videos/$(date +%s).mp4"))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),       { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),     { locked = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

hl.bind(mod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(alt .. " + F4", hl.dsp.exec_cmd("hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

hl.window_rule({
    name  = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

hl.window_rule({ match = { class = "^(pavucontrol|blueman-manager|nm-connection-editor)$" }, float = true, size = "700 500", center = true })
hl.window_rule({ match = { class = "^(org.gnome.FileRoller|thunar)$" }, float = true, size = "900 600", center = true })
hl.window_rule({ match = { class = "^(steam_app_.*)$" }, immediate = true })

local dialogs = { "^(Open File)(.*)$", "^(Save As)(.*)$", "^(File Upload)(.*)$", "^(Select a File)(.*)$", "^(Open Folder)(.*)$" }
for _, t in ipairs(dialogs) do
    hl.window_rule({ match = { title = t }, float = true, center = true, size = "900 600" })
end
