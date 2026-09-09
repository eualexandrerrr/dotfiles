local telas = require("telas")

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

-- O Looking Glass so prende o cursor durante mira (autoCapture), pra deixar a barra
-- alcancavel o resto do tempo (fb26f3e, 9d35d7a). Fora da mira o cursor anda livre e pode
-- escorregar pro monitor vertical. So interessa quando o jogo e o que esta na tela do
-- principal -- se ele estiver so rodando em segundo plano, o vertical continua livre.
local function vm_na_tela_do_principal()
    local nome = telas.nome("principal")
    local mon = nome and hl.get_monitor(nome)
    local ws = mon and mon.active_workspace
    if not ws then return false end
    for _, janela in ipairs(ws:get_windows() or {}) do
        if janela.class == "looking-glass-client" then return true end
    end
    return false
end

-- monitor.focused nao dispara em warp programatico (so testei assim), e so segue mouse
-- fisico via misc:mouse_move_focuses_monitor -- e o layout tem faixa de overlap entre os
-- dois monitores (principal comeca em x=1080, vertical vai ate x=1920), entao "qual monitor
-- esta ativo" e ambiguo bem na borda. Poll de posicao com clamp direto no retangulo do
-- principal ignora as duas questoes: nao depende do evento, nao depende de qual monitor o
-- Hyprland decidiu que esta "focado" na faixa cinzenta.
local function manter_cursor_no_principal()
    if not vm_na_tela_do_principal() then return end
    local principal_nome = telas.nome("principal")
    local principal = principal_nome and hl.get_monitor(principal_nome)
    local pos = hl.get_cursor_pos()
    if not principal or not pos then return end
    local x = math.min(math.max(pos.x, principal.x), principal.x + principal.width - 1)
    local y = math.min(math.max(pos.y, principal.y), principal.y + principal.height - 1)
    if x ~= pos.x or y ~= pos.y then
        hl.dispatch(hl.dsp.cursor.move({ x = x, y = y }))
    end
end

-- hl.timer avaliado direto no corpo do arquivo derruba o --verify-config com SIGSEGV
-- (ele roda o parse simulando carga do config). "config.reloaded" TAMBEM dispara durante
-- o --verify-config (achado hoje, 09/09/2026 -- a memoria hyprctl-com-config-lua so cobria
-- o topo do arquivo) entao um hl.timer dentro dele quebra do mesmo jeito. So
-- "hyprland.start" fica de fora do --verify-config -- e ele nao volta a disparar num
-- `hyprctl reload`, so no login de verdade. Por isso fica global: o `setup.sh recarregar`
-- chama ligar_vigia_cursor() direto por `hyprctl eval` depois do reload.
function ligar_vigia_cursor()
    local vigia_cursor = hl.timer(manter_cursor_no_principal, { timeout = 120, type = "repeat" })
    if vigia_cursor and vigia_cursor.set_enabled then vigia_cursor:set_enabled(true) end
end
hl.on("hyprland.start", ligar_vigia_cursor)
