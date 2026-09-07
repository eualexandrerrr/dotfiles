# Energia: nunca dorme

Nunca suspende, nunca hiberna, nunca desliga sozinha -- so por pedido explicito. A unica
coisa que a inatividade faz e apagar os monitores em 5 min. Tres camadas:

1. **hypridle** (`hypr/.config/hypr/hypridle.conf`): unico listener, `timeout = 300`, com
   `hyprctl dispatch dpms off/on`. Nao bloqueia a tela e nao suspende -- so apaga.
2. **Alvos do systemd mascarados** (`bin/energia.sh`): `sleep.target`, `suspend.target`,
   `hibernate.target`, `hybrid-sleep.target`, `suspend-then-hibernate.target`. Sem isso um
   `systemctl suspend` na mao ainda funcionaria; mascarado, ele responde "Access denied".
3. **`IdleAction=ignore`** em `/etc/systemd/logind.conf.d/99-nunca-dormir.conf`.

Bloqueio automatico continua **desligado** (era `Autolock=false` no KDE): o `hypridle` nao
tem `lock_cmd` no listener, so no `general` para o caso de um `loginctl lock-session`
explicito. `Meta+L` bloqueia na hora, com senha.

O `bin/energia.sh` roda no `install.sh` (etapa `configure_hyprland`) e no
`setup.sh energia`.
