local mod = "SUPER"
local terminal = "uwsm app -- ghostty"
local explorador = "uwsm app -- thunar"
local navegador = "uwsm app -- google-chrome-stable"
local menu = os.getenv("HOME") .. "/.dotfiles/bin/lancador.sh"
local alternador = "hyprswitch gui --mod-key SUPER --key TAB --close mod-key-release --monitors DP-1"
local dotfiles = os.getenv("HOME") .. "/.dotfiles"

hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + E", hl.dsp.exec_cmd(explorador))
hl.bind(mod .. " + B", hl.dsp.exec_cmd(navegador))
hl.bind(mod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + Space", hl.dsp.exec_cmd(menu))
hl.bind("ALT + D", hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + W", hl.dsp.window.close())
hl.bind("ALT + W", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.kill())
hl.bind(mod .. " + L", hl.dsp.exec_cmd("uwsm app -- hyprlock"))
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd("uwsm app -- wlogout"))
hl.bind(mod .. " + I", hl.dsp.exec_cmd("uwsm app -- nwg-look"))
hl.bind(mod .. " + SHIFT + I", hl.dsp.exec_cmd("uwsm app -- nwg-displays"))

hl.bind(mod .. " + V", hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))
hl.bind(mod .. " + P", hl.dsp.exec_cmd("hyprpicker -a"))

hl.bind("Print", hl.dsp.exec_cmd(dotfiles .. "/bin/captura.sh tela"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(dotfiles .. "/bin/recorte-clipboard.sh"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd(dotfiles .. "/bin/recorte-clipboard.sh"))
hl.bind(mod .. " + SHIFT + A", hl.dsp.exec_cmd(dotfiles .. "/bin/captura.sh anotar"))
hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd(dotfiles .. "/bin/captura.sh gravar"))

hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind("CTRL + SHIFT + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + C", hl.dsp.window.center())
hl.bind(mod .. " + D", hl.dsp.workspace.toggle_special("rascunho"))
hl.bind(mod .. " + SHIFT + D", hl.dsp.window.move({ workspace = "special:rascunho" }))

hl.bind(mod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "down" }))

hl.bind(mod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

hl.bind("CTRL + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind("CTRL + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind("CTRL + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind("CTRL + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

hl.bind(mod .. " + ALT + left", hl.dsp.window.resize({ x = -40, y = 0 }), { repeating = true })
hl.bind(mod .. " + ALT + right", hl.dsp.window.resize({ x = 40, y = 0 }), { repeating = true })
hl.bind(mod .. " + ALT + up", hl.dsp.window.resize({ x = 0, y = -40 }), { repeating = true })
hl.bind(mod .. " + ALT + down", hl.dsp.window.resize({ x = 0, y = 40 }), { repeating = true })

hl.bind("ALT + Tab", hl.dsp.exec_cmd(dotfiles .. "/bin/expo.sh"))
hl.bind("ALT_L", hl.dsp.exec_cmd(dotfiles .. "/bin/expo.sh confirmar"), { release = true, non_consuming = true })
hl.bind(mod .. " + Tab", hl.dsp.exec_cmd(alternador .. " --switch-type client --sort-recent"))

for i = 1, 9 do
    hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i, follow = false }))
    hl.bind("CTRL + SHIFT + " .. i, hl.dsp.window.move({ workspace = i, follow = true }))
end

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })
hl.bind(mod .. " + XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness raise"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"), { locked = true, repeating = true })
hl.bind("Caps_Lock", hl.dsp.exec_cmd("swayosd-client --caps-lock"), { locked = true })

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind(mod .. " + CTRL + Escape", hl.dsp.exec_cmd("uwsm app -- ghostty -e btop"))
hl.bind("CTRL + SHIFT + Home", hl.dsp.exec_cmd(dotfiles .. "/bin/recarregar.sh"))

hl.define_submap("resize", function()
    hl.bind("left", hl.dsp.window.resize({ x = -40, y = 0 }), { repeating = true })
    hl.bind("right", hl.dsp.window.resize({ x = 40, y = 0 }), { repeating = true })
    hl.bind("up", hl.dsp.window.resize({ x = 0, y = -40 }), { repeating = true })
    hl.bind("down", hl.dsp.window.resize({ x = 0, y = 40 }), { repeating = true })
    hl.bind("Escape", hl.dsp.submap("reset"))
    hl.bind("Return", hl.dsp.submap("reset"))
    hl.bind("CTRL + SHIFT + R", hl.dsp.submap("reset"))
end)

hl.bind("CTRL + SHIFT + R", hl.dsp.submap("resize"))
