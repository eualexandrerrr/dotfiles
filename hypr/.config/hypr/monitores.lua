hl.monitor({
    output = "DP-1",
    mode = "2560x1440@180.00",
    position = "1080x240",
    scale = 1,
})

hl.monitor({
    output = "DP-2",
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
    hl.workspace_rule({ workspace = tostring(i), monitor = "DP-1" })
end
hl.workspace_rule({ workspace = "1", monitor = "DP-1", default = true })
hl.workspace_rule({ workspace = "9", monitor = "DP-2", default = true })
