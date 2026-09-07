hl.window_rule({
    name = "ricepanel-vertical",
    match = { class = "ricepanel" },
    workspace = "9 silent",
    fullscreen = true,
    border_size = 0,
    rounding = 0,
    no_shadow = true,
    no_blur = true,
    no_initial_focus = true,
    no_focus = true,
})

hl.window_rule({ name = "chrome-na-1", match = { class = "[Gg]oogle-chrome" }, workspace = "1" })
hl.window_rule({ name = "discord-na-2", match = { class = "discord" }, workspace = "2 silent" })
hl.window_rule({ name = "rcode-na-3", match = { class = "RCode" }, workspace = "3" })
hl.window_rule({ name = "vm-na-4", match = { class = "virt-manager|looking-glass-client" }, workspace = "4" })

hl.window_rule({ match = { class = "pavucontrol" }, float = true })
hl.window_rule({ match = { class = "dev.xande.transparencia" }, float = true, center = true })
hl.window_rule({ match = { class = "nwg-look" }, float = true })
hl.window_rule({ match = { class = "nwg-displays" }, float = true })
hl.window_rule({ match = { class = "qt6ct|qt5ct" }, float = true })
hl.window_rule({ match = { class = "org.kvantum.kvantummanager" }, float = true })
hl.window_rule({ match = { class = "virt-manager" }, float = true })
hl.window_rule({ match = { class = "xarchiver" }, float = true })
hl.window_rule({ match = { class = "thunar", title = ".*Propriedades.*" }, float = true })

hl.window_rule({
    name = "picture-in-picture",
    match = { title = "Picture-in-Picture" },
    float = true,
    pin = true,
    size = { 640, 360 },
})

hl.window_rule({
    name = "dialogos-de-arquivo",
    match = { title = "Abrir arquivo|Salvar como|Selecionar pasta|Open File|Save As" },
    float = true,
    center = true,
})

hl.window_rule({
    name = "thunar-tamanho",
    match = { class = "thunar" },
    size = { 1040, 651 },
    center = true,
})

hl.window_rule({
    name = "sempre-solido",
    match = { class = "looking-glass-client|virt-manager|steam_app.*|gamescope|mpv|vlc" },
    opacity = "1.0 1.0",
})

hl.window_rule({
    name = "sem-idle-em-fullscreen",
    match = { class = ".*" },
    idle_inhibit = "fullscreen",
})

hl.window_rule({ match = { class = "steam_app.*|gamescope" }, immediate = true })

hl.window_rule({
    name = "looking-glass",
    match = { class = "looking-glass-client" },
    float = true,
    fullscreen = true,
})

hl.window_rule({
    name = "suprime-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.layer_rule({ match = { namespace = "waybar" }, blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ match = { namespace = "launcher" }, blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ match = { namespace = "notifications" }, blur = true, ignore_alpha = 0.2 })
