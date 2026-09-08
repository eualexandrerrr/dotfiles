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

hl.on("hyprland.shutdown", function() saindo = true end)
hl.on("workspace.active", guardar_workspace)

hl.on("window.destroy", function()
    local tarefa = hl.timer(function()
        voltar_se_vazia()
        garantir_chrome()
        garantir_discord()
    end, { timeout = 200, type = "oneshot" })
    if tarefa and tarefa.set_enabled then tarefa:set_enabled(true) end
end)

guardar_workspace()
