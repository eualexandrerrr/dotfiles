hl.window_rule({
    name = "ricepanel-vertical",
    match = { class = "^RicePanel$" },
    workspace = "9 silent",
    fullscreen = true,
    opacity = "1.0 1.0",
    border_size = 0,
    rounding = 0,
    no_shadow = true,
    no_blur = true,
    no_initial_focus = true,
})

local TERMINAIS = ".*ghostty.*|.*kitty.*|.*Alacritty.*|.*foot.*"
local CHROME = ".*[Gg]oogle-chrome.*"
local MENSAGEIRO = ".*[Dd]iscord.*|.*[Vv]encord.*"
local EDITOR = ".*[Rr][Cc]ode.*"
local JOGOS = ".*virt-manager.*|.*looking-glass.*|.*[Ss]team.*|steam_app.*|.*gamescope.*|.*lutris.*|.*heroic.*"
local REMOTO = ".*freerdp.*"
local MUSICA = ".*[Ss]potify.*"
local FLUTUANTES = ".*pavucontrol.*|.*transparencia.*|.*nwg-.*|.*qt5ct.*|.*qt6ct.*|.*kvantum.*|.*xarchiver.*|.*[Tt]hunar.*|RicePanel|.*wlogout.*|.*fuzzel.*|.*portal.*"

hl.window_rule({ name = "chrome-na-1", match = { class = CHROME, title = ".*Google Chrome" }, workspace = "1 silent" })
hl.window_rule({ name = "discord-na-2", match = { class = MENSAGEIRO }, workspace = "2 silent" })
hl.window_rule({ name = "rcode-na-3", match = { class = EDITOR }, workspace = "3 silent" })
hl.window_rule({ name = "terminais-na-4", match = { class = TERMINAIS }, workspace = "4 silent" })
hl.window_rule({ name = "spotify-na-5", match = { class = MUSICA }, workspace = "5 silent" })
hl.window_rule({ name = "jogos-na-6", match = { class = JOGOS }, workspace = "6 silent" })
hl.window_rule({ name = "rdp-na-7", match = { class = REMOTO }, workspace = "7 silent" })
hl.window_rule({
    name = "resto-da-8-pra-frente",
    match = { class = "negative:^(" .. TERMINAIS .. "|" .. CHROME .. "|" .. MENSAGEIRO .. "|" .. EDITOR .. "|" .. JOGOS .. "|" .. REMOTO .. "|" .. MUSICA .. "|" .. FLUTUANTES .. ")$" },
    workspace = "8 silent",
})

hl.window_rule({
    name = "chrome-modal-flutuante",
    match = { class = CHROME, title = "negative:.*Google Chrome" },
    float = true,
    center = true,
})

hl.window_rule({ match = { class = ".*pavucontrol.*" }, float = true })
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
    match = { class = "looking-glass-client|virt-manager|com.freerdp.client.*|.*freerdp.*|steam_app.*|gamescope|mpv|vlc" },
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
hl.layer_rule({ match = { namespace = "launcher" }, blur = true, ignore_alpha = 0.1, blur_popups = true })
hl.layer_rule({ match = { namespace = "notifications" }, blur = true, ignore_alpha = 0.2 })
