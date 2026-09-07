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
| `hyprexpose/.config/hyprexpose/config.toml` | overview do Alt+Tab (preview ao vivo) |
| `hyprswitch/.config/hyprswitch/style.css` | alternador de janelas do Super+Tab |
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
- **fuzzel** como lancador (Meta+R, Meta+Space ou Alt+D), sempre pelo `bin/lancador.sh`.
  O script faz toggle porque o fuzzel usa lock de instancia unica: com uma instancia presa
  -- invisivel em outro monitor, ou orfa -- toda tecla seguinte era engolida sem abrir
  nada. Nao existe menu iniciar em arvore: o Windows-Modern era applet do Plasma e morreu
  na migracao.
- **hyprexpose** (Alt+Tab) e **hyprswitch** (Super+Tab), os dois alternadores.
- **hypridle** para apagar monitor, **hyprlock** para bloquear, **hyprsunset** para o filtro
  noturno, **hyprpolkitagent** para a janela de autenticacao.
- **swayosd** desenha o OSD de volume, brilho e Caps Lock.
- **cliphist** guarda o historico do clipboard (Meta+V); `wl-clip-persist` evita que o
  conteudo suma quando o programa que copiou fecha.

## Alt+Tab: overview com preview ao vivo

`Alt+Tab` abre o **hyprexpose** (`bin/expo.sh`), um overlay layer-shell que mostra cada
workspace com **thumbnail real da janela**, capturada pelo protocolo
`hyprland-toplevel-export`. Funciona como o Alt+Tab de sempre: segura o Alt, cada `Tab`
avanca um card, **solta o Alt e entra na selecionada**. Mouse por cima tambem seleciona e
clique entra; setas ou `hjkl` navegam, `1..9` vao direto na workspace, `Enter` entra, `Esc`
fecha sem trocar. Tema em `hyprexpose/.config/hyprexpose/config.toml`.

O "solta e entra" e patch nosso, por **sinal**, nao por tecla: `SIGUSR1` abre e, com a tela
ja aberta, avanca a selecao; `SIGUSR2` entra na selecionada e fecha. O bind que fecha o
ciclo e `hl.bind("ALT_L", ..., { release = true })`, que dispara `expo.sh confirmar` ao
soltar o Alt -- e o script so age se o overlay estiver aberto, entao soltar Alt em qualquer
outra situacao nao faz nada.

Preview ao vivo so existe dentro do compositor ou via `hyprland-toplevel-export`. O
**hyprexpo foi removido** dos `hyprland-plugins` oficiais em maio/2026 ("drop unmaintained
plugins") e o `hyprtasking` do AUR esta desatualizado desde 29/07/2026, antes da 0.56.2 --
por isso a escolha caiu num cliente externo, que ainda por cima nao quebra a cada
atualizacao do Hyprland, como todo plugin de ABI quebra.

**Nunca tente controlar esse overlay sintetizando tecla.** O hyprexpose traduz keycode evdev
por uma tabela fixa no `main.rs` (`1 => Escape`, `105 => Left`, ...), ignorando o keymap. O
teclado virtual do `wtype` entrega a primeira tecla no keycode 1, entao *qualquer* tecla
sintetica chega ali como `Esc` e fecha a tela -- foi assim que `wtype -k Left` fechou o
overlay em vez de andar. Por isso o avancar/confirmar foi feito por sinal, que nao passa
pelo teclado.

O DP-2 fica de fora do overview: o hyprexpose **nao tem filtro de monitor**, ele pega toda
workspace com `id >= 1` de todos os monitores (`ipc/hyprland.rs`), so pulando as special.
Como a tela vertical e do RicePanel e ninguem troca para ela, o repo carrega um patch em
`pacotes/hyprexpose/` que adiciona a chave `ignore_monitors` -- por nome de monitor, nao por
id de workspace, para sobreviver se o painel mudar de numero. Por isso o pacote e
`hyprexpose-xande`, compilado pelo `install.sh` (etapa `install_pacotes_locais`), e nao o
`hyprexpose-git` do AUR: atualizar o upstream exige reaplicar o patch.

`Super+Tab` continua sendo o alternador de **janelas**, ai sim com o hyprswitch (GTK4,
tema em `hyprswitch/.config/hyprswitch/style.css`). Os dois daemons sobem no
`hyprland.start` e sao reiniciados pelo `setup.sh recarregar` -- ambos leem o tema so na
inicializacao, entao mexer no CSS/TOML sem reiniciar o daemon nao muda nada na tela.

## App fixo por workspace

`regras.lua` prende cada app na sua workspace: **1 Chrome, 2 Discord, 3 RCode, 4 VM**
(`virt-manager` e `looking-glass-client`). As classes vieram do `StartupWMClass` de cada
`.desktop`, nao de chute -- o Chrome grava `google-chrome` e `Google-chrome` no mesmo
arquivo, por isso a regra casa `[Gg]oogle-chrome`.

Os icones dessas quatro na waybar sao glifos da Nerd Font em `format-icons`, e o
`tooltip-format` mostra o numero ao passar o mouse. Da 5 em diante fica o numero mesmo.

## Clique no numero da workspace na barra

Funciona sozinho: na waybar 0.15 o `hyprland/workspaces` trata o clique em
`Workspace::handleClicked`, que dispara `dispatch workspace <id>` direto pelo socket. A
chave `on-click` **nao e lida por esse modulo** -- ela pertence ao `AModule` base, que a
trataria como comando de shell e tentaria rodar um binario chamado `activate`. Estava no
`config.jsonc` sem efeito util e saiu. `sort-by-number` tambem era o nome antigo; hoje e
`sort-by: "number"`.

## Atalhos que vieram do KDE

Preservados de proposito, porque estao na memoria muscular dele:

- `Shift+Print` e `Meta+Shift+S` -> `bin/recorte-clipboard.sh` (regiao direto pro clipboard)
- `Meta+L` -> bloquear
- `Meta+setas` -> mover foco; `Meta+Shift+setas` -> mover janela
- `Alt+Tab` -> overview das workspaces com preview ao vivo (era alternar janelas)
- `Meta+1..9` -> workspaces
- `Ctrl+Shift+Home` -> `bin/recarregar.sh`, que e o `setup.sh recarregar` com notificacao:
  recarrega compositor, barra, notificacoes e os dois alternadores sem fechar nenhum app,
  e avisa na tela se o `hyprctl configerrors` acusar alguma coisa

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
