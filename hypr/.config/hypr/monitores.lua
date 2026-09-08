local telas = require("telas")

local principal = telas.desc("principal")
local vertical = telas.desc("vertical")

hl.monitor({
    output = principal,
    mode = "2560x1440@180.00",
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

for i = 1, 8 do
    hl.workspace_rule({ workspace = tostring(i), monitor = principal })
end
hl.workspace_rule({ workspace = "1", monitor = principal, default = true })
hl.workspace_rule({ workspace = "9", monitor = vertical, default = true })
