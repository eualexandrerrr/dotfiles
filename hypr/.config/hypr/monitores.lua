local telas = require("telas")

local principal = telas.desc("principal")
local vertical = telas.desc("vertical")

-- NAO trocar por "highrr": ele maximiza a TAXA, nao a resolucao, e cai em 1024x768@180
-- (testado em 07/09/2026). Resolucao e taxa sempre explicitas aqui.
-- A RX 550 desenha o principal pela HDMI 2.0b: o EDID dessa entrada para em 2560x1440@120.
hl.monitor({
    output = principal,
    mode = "2560x1440@120",
    position = "1080x240",
    scale = 1,
})

hl.monitor({
    output = vertical,
    mode = "1920x1080@143.98",
    position = "0x0",
    scale = 1,
    transform = 1,
})

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto",
})

-- persistent segura a workspace no monitor mesmo num desconecte curto -- o modo-jogo
-- (vm/modo-jogo) troca a entrada do ASUS por ddcutil, e a entrada que sai perde o HPD por
-- um instante: sem isso, o Hyprland via o principal sumir e realocava tudo pro vertical por
-- uma fracao de segundo (visto em 09/09/2026, RCode piscando no monitor do RicePanel).
for i = 1, 8 do
    hl.workspace_rule({ workspace = tostring(i), monitor = principal, persistent = true })
end
hl.workspace_rule({ workspace = "1", monitor = principal, default = true, persistent = true })
hl.workspace_rule({ workspace = "9", monitor = vertical, default = true })
