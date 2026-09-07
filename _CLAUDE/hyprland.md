# Hyprland

Compositor Wayland desde 07/09/2026, no lugar do KDE Plasma. Tudo que o Plasma guardava em
banco de estado misturado com configuracao agora e **arquivo de texto versionado** -- essa
foi a maior razao pratica da troca, alem do pedido.

## Onde mora cada coisa

| Arquivo | O que faz |
|---|---|
| `hypr/.config/hypr/hyprland.lua` | raiz: `hl.env`, autostart, `hl.config`, animacoes |
| `hypr/.config/hypr/monitores.lua` | `hl.monitor` e `hl.workspace_rule` |
| `hypr/.config/hypr/atalhos.lua` | todos os `hl.bind` |
| `hypr/.config/hypr/regras.lua` | `hl.window_rule` e `hl.layer_rule` |
| `hypr/.config/hypr/hypridle.conf` | inatividade (apaga monitor em 5 min) |
| `hypr/.config/hypr/hyprlock.conf` | tela de bloqueio |
| `waybar/.config/waybar/` | barra: `config.jsonc` + `style.css` |
| `mako/.config/mako/config` | notificacoes |
| `fuzzel/.config/fuzzel/fuzzel.ini` | lancador |
| `wlogout/.config/wlogout/` | menu de encerrar |

O `hyprland.lua` faz `require` dos outros tres. Mexer em atalho e mexer so no
`atalhos.lua`.

## A config e Lua, nao hyprlang

**Desde o Hyprland 0.55 o formato `.conf` (hyprlang) esta deprecado em favor de Lua**, e na
0.56 o `example/hyprland.conf` nem existe mais no repositorio -- so `hyprland.lua`. Isso nao
e preferencia: `windowrule`/`layerrule` escritos em hyprlang **falham inteiros** na 0.56,
com "invalid field float: missing a value", que nao parece um erro de sintaxe deprecada.

A sintaxe agora e:

```lua
hl.window_rule({ match = { class = "pavucontrol" }, float = true })
hl.layer_rule({ match = { namespace = "waybar" }, blur = true })
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.config({ general = { gaps_in = 4 } })
```

Regras sao `match` (props) + efeitos. Os campos mudaram de nome junto: `noborder` virou
`border_size = 0`, `noinitialfocus` virou `no_initial_focus`, `idleinhibit` virou
`idle_inhibit`, `nofocus` virou `no_focus`.

Fonte da verdade offline, casada com a versao instalada:
`/usr/share/hypr/stubs/hl.meta.lua` (lista todos os campos e dispatchers) e
`/usr/share/hypr/hyprland.lua` (exemplo). Consultar esses dois antes da wiki -- a wiki
descreve a versao mais recente, os stubs descrevem a **sua**.

**Sempre validar antes de entregar:** `Hyprland --verify-config` roda sem subir sessao e
diz `config ok` ou lista os erros. Rodar isso e obrigatorio depois de mexer em qualquer
arquivo `hypr/`; sem ele, config errada so aparece como sessao torta no login.

## uwsm: por que a sessao nao e o hyprland pelado

A sessao do SDDM e **`hyprland-uwsm.desktop`**, nao `hyprland.desktop`. O uwsm
(Universal Wayland Session Manager) poe o compositor dentro de units do systemd e, com
isso, o `graphical-session.target` passa a existir de verdade.

Isso nao e enfeite: o **`ricepanel.service` depende de `graphical-session.target`**. Com
Hyprland pelado esse target nunca fica ativo direito e o painel do monitor vertical nao
sobe sozinho. Por isso todo `exec-once` de app e todo `bind` que abre programa usam
`uwsm app -- <programa>`: assim cada app vira um scope do systemd, aparece no
`systemd-cgls`, e morre junto com a sessao em vez de virar processo orfao.

Se algum dia a sessao voltar a ser `hyprland.desktop`, o RicePanel para de subir e a causa
nao vai ser obvia.

## Stack da sessao

- **awww** (`awww-daemon` + `awww img`) para wallpaper. E o antigo `swww`: o projeto foi
  renomeado e hoje esta no repo oficial `extra`, com `Provides`/`Replaces: swww`. Os
  binarios chamam **awww**, nao swww -- `bin/wallpaper.sh` depende disso.
- **waybar** so no `DP-1`. A tela vertical nunca recebe barra: ela e do RicePanel.
- **mako**, com `[app-name=ricepanel] invisible=1`, que e o equivalente da regra que existia
  no `plasmanotifyrc`.
- **fuzzel** como lancador (Meta+R ou Meta+Space). Nao existe menu iniciar em arvore: o
  Windows-Modern era applet do Plasma e morreu na migracao.
- **hypridle** para apagar monitor, **hyprlock** para bloquear, **hyprsunset** para o filtro
  noturno, **hyprpolkitagent** para a janela de autenticacao.
- **swayosd** desenha o OSD de volume, brilho e Caps Lock.
- **cliphist** guarda o historico do clipboard (Meta+V); `wl-clip-persist` evita que o
  conteudo suma quando o programa que copiou fecha.

## Atalhos que vieram do KDE

Preservados de proposito, porque estao na memoria muscular dele:

- `Shift+Print` e `Meta+Shift+S` -> `bin/recorte-clipboard.sh` (regiao direto pro clipboard)
- `Meta+L` -> bloquear
- `Meta+setas` -> mover foco; `Meta+Shift+setas` -> mover janela
- `Alt+Tab` -> alternar janelas
- `Meta+1..9` -> workspaces

O resto esta em `hypr/.config/hypr/atalhos.lua`, que e curto e legivel.

## Regras de janela que importam

O `ricepanel` recebe: `workspace = "9 silent"` (a tela vertical), `fullscreen`,
`border_size = 0`, `no_shadow`, `no_blur`, `no_focus` e `no_initial_focus`. As duas ultimas
substituem o `skiptaskbar` do `kwinrulesrc`: sem elas o painel rouba foco ao subir.

## Pegadinhas

- **`transform` do monitor vertical**: `monitores.lua` usa `transform = 1`. Se a imagem
  aparecer de cabeca pra baixo, o valor certo e `3`. So da pra saber olhando.
- **NVIDIA**: `no_hardware_cursors = true` em `cursor` evita cursor invisivel ou piscando.
  As `hl.env` de `LIBVA_DRIVER_NAME`, `__GLX_VENDOR_LIBRARY_NAME` e `NVD_BACKEND` estao no
  `hyprland.lua` e nao devem sair.
- **`hyprctl reload` nao recarrega a waybar**: e processo separado. O
  `setup.sh recarregar` manda `SIGUSR2` nela.
- Config errada nao derruba a sessao: o Hyprland ignora e segue. Conferir com
  `Hyprland --verify-config` antes de logar e `hyprctl configerrors` depois.
