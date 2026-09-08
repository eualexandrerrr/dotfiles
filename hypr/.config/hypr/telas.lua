-- Fonte unica das telas: a MARCA de cada uma, nunca o conector. Trocar o cabo de porta
-- renumera DP-1/DP-2/DP-3 e quebraria toda config presa ao nome; a descricao do EDID nao muda.
-- Lido tambem pelo bin/monitor.sh, que resolve a mesma coisa para os programas de fora.
local telas = {}

telas.principal = "ASUSTek COMPUTER INC XG27ACS"
telas.vertical = "LG Electronics LG ULTRAGEAR"

function telas.desc(papel)
    return "desc:" .. telas[papel]
end

function telas.nome(papel)
    local marca = telas[papel]
    if type(marca) ~= "string" then
        return nil
    end
    local ok, monitores = pcall(hl.get_monitors)
    if not ok or type(monitores) ~= "table" then
        return nil
    end
    for _, m in ipairs(monitores) do
        if type(m.description) == "string" and m.description:sub(1, #marca) == marca then
            return m.name
        end
    end
    return nil
end

return telas
