hl.window_rule({
    name = "ricepanel-vertical",
    match = { class = "^[Rr]ice[Pp]anel$" },
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
local FLUTUANTES = ".*pavucontrol.*|.*transparencia.*|.*nwg-.*|.*qt5ct.*|.*qt6ct.*|.*kvantum.*|.*xarchiver.*|.*[Tt]hunar.*|[Rr]ice[Pp]anel|.*wlogout.*|.*fuzzel.*|.*portal.*"

hl.window_rule({ name = "chrome-na-1", match = { class = CHROME, title = ".*Google Chrome" }, workspace = "1 silent" })
hl.window_rule({ name = "discord-na-2", match = { class = MENSAGEIRO }, workspace = "2 silent" })
hl.window_rule({ name = "rcode-na-3", match = { class = EDITOR }, workspace = "3 silent" })
hl.window_rule({ name = "jogos-na-4", match = { class = JOGOS, float = false }, workspace = "4 silent" })
hl.window_rule({ name = "spotify-na-5", match = { class = MUSICA }, workspace = "5 silent" })
hl.window_rule({ name = "terminais-na-6", match = { class = TERMINAIS }, workspace = "6 silent" })
hl.window_rule({ name = "rdp-na-7", match = { class = REMOTO, float = false }, workspace = "7 silent" })
hl.window_rule({
    name = "resto-da-8-pra-frente",
    match = { class = "negative:^(" .. TERMINAIS .. "|" .. CHROME .. "|" .. MENSAGEIRO .. "|" .. EDITOR .. "|" .. JOGOS .. "|" .. REMOTO .. "|" .. MUSICA .. "|" .. FLUTUANTES .. ")$", float = false },
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
hl.window_rule({ match = { class = "[Tt]hunar", title = ".*Propriedades.*" }, float = true })

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
    match = { class = "[Tt]hunar" },
    float = true,
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

-- O RicePanel vive em tela cheia no monitor vertical, entao a regra de cima o fazia inibir
-- o idle o tempo todo e a tela nunca apagava. Vem depois dela de proposito: a ultima regra
-- que casa e a que vale.
hl.window_rule({
    name = "ricepanel-nao-segura-a-tela",
    match = { class = "^[Rr]ice[Pp]anel$" },
    idle_inhibit = "none",
})

hl.window_rule({ match = { class = "steam_app.*|gamescope" }, immediate = true })

hl.window_rule({
    name = "looking-glass",
    match = { class = "looking-glass-client" },
    float = true,
    fullscreen = true,
    immediate = true,
    no_blur = true,
    no_shadow = true,
    rounding = 0,
    border_size = 0,
})

hl.window_rule({
    name = "suprime-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.layer_rule({ match = { namespace = "waybar" }, blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ match = { namespace = "launcher" }, blur = true, ignore_alpha = 0.1, blur_popups = true })
hl.layer_rule({ match = { namespace = "notifications" }, blur = true, ignore_alpha = 0.2 })

-- Bandeja XEmbed: o Wine (Radmin VPN) so fala systray antigo, o xembedsniproxy adota o
-- icone e repassa pra waybar por SNI. Sobram duas janelinhas de servico -- o container do
-- proxy, sem classe, e o icone adotado -- que nao podem aparecer em workspace nenhuma.
hl.window_rule({
    name = "bandeja-xembed-container",
    match = { class = "^$" },
    workspace = "special:bandeja silent",
    no_initial_focus = true,
})

-- A janela real do Radmin abre a partir do icone da bandeja: flutuante e no centro da
-- workspace em que ele estiver, senao ela nasce atras do que ja estava aberto.
hl.window_rule({
    name = "radmin-vpn-flutuante",
    match = { class = "^rvrvpngui\\.exe$" },
    float = true,
    center = true,
})
