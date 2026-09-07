-- Gerado pelo bin/transparencia.py (Meta+O). Editar na mao funciona, mas o menu
-- reescreve o arquivo inteiro na proxima vez que voce mexer num slider.
-- App sem linha aqui usa o global do bloco decoration do hyprland.lua.

hl.window_rule({ name = "opacidade-rcode", match = { class = [[^RCode$]] }, opacity = "0.97 0.90" })
hl.window_rule({ name = "opacidade-discord", match = { class = [[^discord$]] }, opacity = "0.97 0.90" })
hl.window_rule({ name = "opacidade-google-chrome", match = { class = [[^google\-chrome$]] }, opacity = "0.97 0.90" })
