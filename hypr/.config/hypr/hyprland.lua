require("monitores")
require("regras")
require("transparencia")
require("atalhos")

hl.env("XCURSOR_THEME", "Fluent-dark-cursors")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")

hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm app -- awww-daemon")
    hl.exec_cmd(os.getenv("HOME") .. "/.dotfiles/bin/wallpaper.sh")
    hl.exec_cmd("uwsm app -- waybar")
    hl.exec_cmd("uwsm app -- mako")
    hl.exec_cmd("uwsm app -- hyprexpose")
    hl.exec_cmd("uwsm app -- hyprswitch init --custom-css " .. os.getenv("HOME") .. "/.config/hyprswitch/style.css --show-title --workspaces-per-row 5 --size-factor 5")
    hl.exec_cmd("uwsm app -- hypridle")
    hl.exec_cmd("uwsm app -- hyprsunset")
    hl.exec_cmd("uwsm app -- swayosd-server")
    hl.exec_cmd("uwsm app -- discord")
    hl.exec_cmd("uwsm app -- nm-applet --indicator")
    hl.exec_cmd("uwsm app -- udiskie --tray")
    hl.exec_cmd("wl-clip-persist --clipboard regular")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd(os.getenv("HOME") .. "/.dotfiles/bin/dns-rapido.sh")
    hl.exec_cmd(os.getenv("HOME") .. "/.dotfiles/bin/nvidia-desempenho.sh")
    hl.exec_cmd(os.getenv("HOME") .. "/.dotfiles/vm/reabrir-apps.sh")
end)

hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 8,
        border_size = 2,
        col = {
            active_border = { colors = { "rgba(cba6f7ff)", "rgba(89b4faff)" }, angle = 45 },
            inactive_border = "rgba(313244aa)",
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = 10,
        rounding_power = 2,
        active_opacity = 0.96,
        inactive_opacity = 0.90,
        fullscreen_opacity = 1.0,

        shadow = {
            enabled = true,
            range = 20,
            render_power = 3,
            color = "rgba(00000055)",
        },

        blur = {
            enabled = true,
            size = 6,
            passes = 3,
            new_optimizations = true,
            ignore_opacity = true,
            xray = false,
            popups = true,
            popups_ignorealpha = 0.2,
            special = true,
        },
    },

    animations = {
        enabled = true,
    },

    binds = {
        disable_keybind_grabbing = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    input = {
        kb_layout = "br",
        repeat_rate = 40,
        repeat_delay = 400,
        follow_mouse = 1,
        sensitivity = 0,
        accel_profile = "flat",
        touchpad = {
            natural_scroll = false,
        },
    },

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        focus_on_activate = true,
    },

    cursor = {
        no_hardware_cursors = true,
        default_monitor = "DP-1",
    },

    xwayland = {
        force_zero_scaling = true,
    },
})

hl.curve("suave", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.0 } } })
hl.curve("seco", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "seco" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "suave", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "seco", style = "slidefade 15%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, bezier = "seco", style = "slidevert" })

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})
