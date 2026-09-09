local navegador = "uwsm app -- google-chrome-stable"
local mensageiro = "uwsm app -- discord"
local historico = {}
local saindo = false
local ultimo_chrome = 0
local ultimo_discord = 0

local function guardar_workspace()
    local ws = hl.get_active_workspace()
    if not ws or ws.special then return end
    if historico[1] == ws.id then return end
    table.insert(historico, 1, ws.id)
    historico[6] = nil
end

local function voltar_se_vazia()
    local ws = hl.get_active_workspace()
    if not ws or ws.special or not ws.is_empty then return end
    for _, id in ipairs(historico) do
        if id ~= ws.id then
            local alvo = hl.get_workspace(id)
            if alvo and not alvo.is_empty then
                hl.dispatch(hl.dsp.focus({ workspace = id }))
                return
            end
        end
    end
end

local function tem_janela(padrao)
    for _, janela in ipairs(hl.get_windows() or {}) do
        if janela.class and janela.class:match(padrao) then return true end
    end
    return false
end

local function garantir_chrome()
    if saindo or tem_janela("[Gg]oogle%-chrome") then return end
    local agora = os.time()
    if agora - ultimo_chrome < 10 then return end
    ultimo_chrome = agora
    hl.dispatch(hl.dsp.exec_cmd(navegador))
end

local function garantir_discord()
    if saindo or tem_janela("[Dd]iscord") then return end
    local agora = os.time()
    if agora - ultimo_discord < 10 then return end
    ultimo_discord = agora
    hl.dispatch(hl.dsp.exec_cmd(mensageiro))
end

local function ajustar_resize_borda()
    local ws = hl.get_active_workspace()
    if not ws then return end
    hl.config({ general = { resize_on_border = ws.windows > 1 } })
end

hl.on("hyprland.shutdown", function() saindo = true end)
hl.on("workspace.active", guardar_workspace)
hl.on("workspace.active", ajustar_resize_borda)
hl.on("window.open", ajustar_resize_borda)
hl.on("window.destroy", ajustar_resize_borda)
hl.on("window.move_to_workspace", ajustar_resize_borda)

hl.on("window.destroy", function()
    local tarefa = hl.timer(function()
        voltar_se_vazia()
        garantir_chrome()
        garantir_discord()
    end, { timeout = 200, type = "oneshot" })
    if tarefa and tarefa.set_enabled then tarefa:set_enabled(true) end
end)

guardar_workspace()
ajustar_resize_borda()

-- Bandeja XEmbed do Wine: o Radmin VPN so fala systray antigo, entao o xembedsniproxy
-- adota o icone e o repassa pra waybar por SNI. O icone adotado continua sendo uma janela
-- X de 22x22 com a mesma classe e o mesmo titulo da janela real do app, o que nenhum
-- window_rule consegue separar -- so o tamanho distingue. Sai da tela pela special.
local BANDEJA = 48
local candidatos = {}

local function medir(janela)
    -- size vem como { x = ..., y = ... }, nao como lista: size[1] e sempre nil.
    local tamanho = janela.size or {}
    return tamanho.x, tamanho.y
end

-- Duas passadas antes de esconder: a janela real do app tambem nasce pequena e so depois
-- cresce, e engolir ela deixaria o Radmin sem interface nenhuma. So sai da tela o que
-- continua do tamanho de um icone na leitura seguinte.
local function esconder_icones_de_bandeja()
    local vistos = {}
    for _, janela in ipairs(hl.get_windows() or {}) do
        local largura, altura = medir(janela)
        local ws = janela.workspace
        if largura and altura and largura <= BANDEJA and altura <= BANDEJA
            and not (ws and ws.special) then
            vistos[janela.address] = true
            if candidatos[janela.address] then
                hl.dispatch(hl.dsp.window.move({
                    workspace = "special:bandeja",
                    window = "address:" .. janela.address,
                    silent = true,
                }))
            end
        end
    end
    candidatos = vistos
end

hl.on("window.open", function()
    for _, atraso in ipairs({ 400, 1200, 3000 }) do
        local tarefa = hl.timer(esconder_icones_de_bandeja, { timeout = atraso, type = "oneshot" })
        if tarefa and tarefa.set_enabled then tarefa:set_enabled(true) end
    end
end)
