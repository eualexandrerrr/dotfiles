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
| `hypr/.config/hypr/transparencia.lua` | **gerado** pelo menu do `Meta+O`, opacidade por app |
| `hypr/.config/hypr/hypridle.conf` | inatividade (apaga monitor em 5 min) |
| `hypr/.config/hypr/hyprlock.conf` | tela de bloqueio |
| `hypr/.config/hypr/telas.lua` | marcas dos monitores + `telas.nome()`; fonte unica |
| `waybar/.config/waybar/` | barra: `config.jsonc` + `style.css` (sobe pelo `bin/waybar.sh`) |
| `mako/.config/mako/config` | notificacoes |
| `fuzzel/.config/fuzzel/fuzzel.ini` | lancador |
| `hyprexpose/.config/hyprexpose/config.toml` | overview do Alt+Tab (preview ao vivo) |
| `hyprswitch/.config/hyprswitch/style.css` | alternador de janelas do Super+Tab |
| `wlogout/.config/wlogout/` | menu de encerrar |

O `hyprland.lua` faz `require` dos outros. Mexer em atalho e mexer so no `atalhos.lua`.

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
- **waybar** so no monitor principal, resolvido pela marca em `bin/waybar.sh`. A tela
  vertical nunca recebe barra: ela e do RicePanel. Ver `monitores.md`, secao dos wrappers.
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

O `SIGUSR1` abre e, com a tela ja aberta, avanca a selecao; `SIGUSR2` entra na selecionada
e fecha. Os sinais continuam existindo, mas quem realmente fecha o ciclo hoje e o proprio
overlay lendo `Tab` e o release do Alt na sua surface -- ver "o que quebrava o ciclo" mais
abaixo. Os binds `ALT_L`/`ALT_R` com `release = true` ficaram como rede de seguranca, e o
script so age se o overlay estiver aberto, entao soltar Alt em qualquer outra situacao nao
faz nada.

**Esse bind precisa de `non_consuming = true`, senao o `Alt+D` trava tudo.** Bind sem a
flag consome o evento: o Hyprland dispara o dispatcher e **nao repassa a tecla ao cliente
focado**. Como o bind e no *release* do `ALT_L`, quem estava com o teclado nunca recebia o
"soltei o Alt". No `Alt+D` isso e fatal: o fuzzel sobe como layer com teclado exclusivo
enquanto o Alt ainda esta pressionado, recebe o `enter` com o modificador ligado e nunca
recebe o update dizendo que soltou -- da entao cada letra digitada chega como `Alt+letra`,
o fuzzel ignora tudo e a tela parece congelada. Por isso o `Meta+R` e o `Meta+Space`
sempre funcionaram e so o `Alt+D` quebrava: nenhum bind consome o release do Meta.
Conferir com `hyprctl binds -j` -- o `ALT_L` tem que sair com `non_consuming: true`.

Preview ao vivo so existe dentro do compositor ou via `hyprland-toplevel-export`. O
**hyprexpo foi removido** dos `hyprland-plugins` oficiais em maio/2026 ("drop unmaintained
plugins") e o `hyprtasking` do AUR esta desatualizado desde 29/07/2026, antes da 0.56.2 --
por isso a escolha caiu num cliente externo, que ainda por cima nao quebra a cada
atualizacao do Hyprland, como todo plugin de ABI quebra.

O overlay pede o teclado com **`KeyboardInteractivity::Exclusive`** (`main.rs:541`), e um
layer com grab exclusivo **desliga os keybinds do Hyprland enquanto esta aberto**. Era isso
que quebrava o ciclo: o primeiro `Alt+Tab` abria a tela e, dali em diante, nem o `Tab`
seguinte avancava nem soltar o Alt confirmava -- os dois binds simplesmente nao chegavam ao
compositor, e so `Esc` ou `Enter` saiam de la, porque esses o proprio hyprexpose le.

`binds.disable_keybind_grabbing = true` esta no `hyprland.lua` e ajuda, mas **nao resolve
sozinho** -- foi o que se acreditou por duas rodadas ate o log desmentir. Instrumentar o
`expo.sh` com um `printf` de timestamp deu o veredito em uma tentativa: seis `arg=abrir` e
zero `arg=confirmar`. O `Tab` seguinte chegava; o release do Alt nunca.

O motivo e do proprio Hyprland: **bind de release num modificador puro nao dispara depois
que aquele modificador foi combinado com outra tecla**. `ALT_L` com `release = true` roda
quando o Alt e tocado sozinho, e so. Como o ciclo do Alt+Tab e exatamente Alt+outra tecla,
esse bind nunca ia rodar -- nao ha config que conserte.

Quem enxerga o release e a **surface do hyprexpose**, que segura o grab exclusivo do
teclado. Por isso o tratamento foi para dentro do patch (`src/main.rs`): soltar `KEY_LEFTALT`
(56) ou `KEY_RIGHTALT` (100) com a tela visivel entra na workspace selecionada e fecha. O
mesmo patch ensina o overlay a ler `Tab` e `Shift+Tab` na propria surface, avancando e
voltando a selecao, porque com o grab o bind do compositor tambem nao chega ali de forma
confiavel. Os binds `ALT_L`/`ALT_R` no `atalhos.lua` viraram rede de seguranca.

A tela de bloqueio nao e afetada: o hyprlock usa `ext-session-lock-v1`, um caminho separado,
onde so bind com `locked = true` roda.

**Para testar atalho aqui, use `ydotool`, nunca `wtype`.** O `wtype` cria um teclado virtual
que entrega a primeira tecla no keycode 1, e o hyprexpose traduz keycode evdev por uma tabela
fixa no `main.rs` (`1 => Escape`, ...), entao *qualquer* tecla do wtype chega como `Esc` e
fecha a tela. O `ydotool` injeta por `/dev/uinput`, no nivel do teclado real, e o ciclo
inteiro se testa sem tocar no teclado:

```
/usr/bin/systemctl --user start ydotool
ydotool key 56:1; ydotool key 15:1 15:0; ydotool key 15:1 15:0; ydotool key 56:0
```

Deixe **pelo menos meio segundo** entre os eventos: com 0,4s o overlay ainda nao redesenhou e
o teste da falso negativo.

O overlay **abre ja na proxima** workspace, nao na atual: um unico `Alt+Tab` tem que
trocar, como em qualquer alternador. Isso e um `select_next()` logo depois do `refresh_data`
no ramo que abre (`main.rs`), porque o `refresh_data` posiciona a selecao na workspace ativa.

O grid e **sempre uma linha so**. O upstream calculava `cols = ceil(sqrt(n))`, entao com
tres workspaces virava 2x2 e a terceira caia numa segunda linha -- errado para um Alt+Tab,
que se le da esquerda para a direita. O patch fixa `cols = n` nos tres lugares que
recalculam o grid (`render.rs`, `handle_key` e `workspace_at` em `main.rs`); os tres tem que
mudar juntos, senao o clique do mouse cai num card diferente do que aparece na tela. O
`max_card_width` do TOML segura o tamanho quando ha poucas workspaces.

### O "Alt+D nao funciona, a tela so escurece"

Falso positivo classico: o `Alt+D` estava certo o tempo todo. A tela escurecida era o
**overlay do hyprexpose preso aberto** de um `Alt+Tab` anterior -- e com o grab exclusivo do
teclado nenhum atalho respondia, entao o `Alt+D` seguinte parecia nao fazer nada. O log do
`lancador.sh` provou: zero chamadas enquanto ele apertava.

Antes de mexer no lancador, cheque o que ja esta na tela:

```
hyprctl layers -j | grep -o '"namespace": "[^"]*"' | sort -u
```

`launcher` e o fuzzel (o namespace **nao** e "fuzzel" -- a `layer_rule` de blur apontava
para o nome errado e nunca pegava). Se aparecer o hyprexpose, o teclado esta com ele.

O DP-2 fica de fora do overview: o hyprexpose **nao tem filtro de monitor**, ele pega toda
workspace com `id >= 1` de todos os monitores (`ipc/hyprland.rs`), so pulando as special.
Como a tela vertical e do RicePanel e ninguem troca para ela, o repo carrega um patch em
`pacotes/hyprexpose/` que adiciona a chave `ignore_monitors` -- por nome de monitor, nao por
id de workspace, para sobreviver se o painel mudar de numero. Por isso o pacote e
`hyprexpose-xande`, compilado pelo `install.sh` (etapa `install_pacotes_locais`), e nao o
`hyprexpose-git` do AUR: atualizar o upstream exige reaplicar o patch.

`Super+Tab` continua sendo o alternador de **janelas**, ai sim com o hyprswitch (GTK4,
tema em `hyprswitch/.config/hyprswitch/style.css`). O `--mod-key` dele tem que bater com o
modificador do bind: com `--close mod-key-release` o hyprswitch so fecha quando *aquele*
modificador e solto, entao `--mod-key ALT` amarrado num `Super+Tab` deixava a GUI aberta
segurando o teclado -- outro jeito de travar a maquina inteira. Os dois daemons sobem no
`hyprland.start` e sao reiniciados pelo `setup.sh recarregar` -- ambos leem o tema so na
inicializacao, entao mexer no CSS/TOML sem reiniciar o daemon nao muda nada na tela.

## App fixo por workspace

`regras.lua` prende cada app na sua workspace. Desde 08/09/2026 o esquema e
**1 Chrome, 2 Discord, 3 RCode, 4 terminais, 5 Spotify, 6 jogos (VM, Steam, Lutris,
Heroic), 7 acesso remoto (RDP), 8 em diante todo o resto**. As classes vieram do
`StartupWMClass` de cada `.desktop`, nao de chute -- o Chrome grava `google-chrome` e
`Google-chrome` no mesmo arquivo, por isso a regra casa `[Gg]oogle-chrome`.

O "todo o resto na 8" e uma regra so, com **match negativo**: `class = "negative:^(...)$"`,
listando os quatro grupos e os apps que devem flutuar onde estao. Lookahead
(`^(?!...)`) **nao funciona** -- o motor de regex do Hyprland nao suporta, e a regra passa a
casar tudo em silencio. E o match e do comeco ao fim: `class = "pavucontrol"` nunca pegou
nada porque a classe real e `org.pulseaudio.pavucontrol`; por isso os padroes levam `.*` nas
pontas.

Toda regra de workspace leva `silent`. Sem isso, abrir um app joga a sessao inteira para a
workspace dele no meio do trabalho.

As janelas do Chrome que **nao** sao a principal (login do Google, confirmacao) tem titulo
que nao termina em `Google Chrome`. A regra de workspace exige esse sufixo e a regra
`chrome-modal-flutuante` casa o contrario (`title = "negative:.*Google Chrome"`), entao o
modal flutua na workspace onde voce esta, em vez de sumir para a 2.

O **Discord sobe sozinho** no `hyprland.start` e a regra dele e `workspace = "2 silent"`:
sem o `silent` a sessao pularia para a workspace 2 no login, atras do Discord. Regra de
workspace so vale na abertura da janela -- app que ja estava aberto quando a regra mudou
nao se move sozinho; para arrastar o que ja esta na tela:

```
hyprctl dispatch '(function() local w = hl.get_windows({ class = "discord" })[1]; return hl.dsp.window.move({ workspace = 2, follow = false, window = w }) end)()'
```

Os icones na waybar sao glifos da Nerd Font em `format-icons`, na ordem: `f268` Chrome,
`f392` Discord, `f121` codigo, `f489` terminal, `f1bc` Spotify, `f11b` controle de video
game, `f108` monitor para o acesso remoto. A 5 e "jogos", nao "Windows" -- ela sobe a VM, mas ele nao quer o logo da
Microsoft na barra dele. As sete primeiras sao `persistent-workspaces`, entao aparecem
mesmo vazias. Mudou a ordem das workspaces? **Mude os
icones junto** -- foi por eles que a barra continuou anunciando o esquema velho depois que as
regras ja estavam certas.

## Voltar da workspace vazia e Chrome sempre vivo

`eventos.lua` cuida de dois comportamentos, os dois pendurados em `window.destroy`:

- fechou a ultima janela da workspace? a sessao volta para a anterior que ainda tem janela,
  usando um historico curto alimentado por `workspace.active`
- fechou a ultima janela do Chrome ou do Discord? o app sobe de novo -- o Chrome na pagina
  inicial --, com carencia de 10 s cada e uma trava no `hyprland.shutdown` para nao
  ressuscitar no logout. O Discord some da lista de janelas quando vai para a bandeja, e a
  regra o traz de volta: e o que "Discord persistente na 3" quer dizer

Duas pegadinhas da API Lua aqui: `hl.timer(fn, { timeout = 200 })` **nao dispara** sem
`type = "oneshot"`, e o callback de evento so recebe a janela como argumento -- o estado da
workspace ainda nao assentou na hora do evento, dai o timer curto antes de decidir.

## Clique no numero da workspace na barra: por que exige waybar-git

O `hyprland/workspaces` trata o clique em `Workspace::handleClicked`, que manda
`dispatch workspace <id>` pelo socket1. **Na 0.56 esse formato nao existe mais**: o
`dispatch` virou Lua e o Hyprland responde

```
error: [string "return hl.dispatch(workspace 1)"]:1: ')' expected near '1'
```

O clique some sem deixar rastro na tela -- e nao e config: o modulo nem le a chave
`on-click` (ela e do `AModule` base, e viraria um comando de shell chamado `activate`).
Da para provar em duas linhas: clicar num modulo com `on-click`, tipo o de CPU, abre o btop
normalmente, entao o input chega na barra; so o botao de workspace nao age.

A master da waybar ja corrigiu -- detecta o protocolo por `systeminfo` e monta
`/dispatch hl.dsp.focus({ workspace = "1" })` -- mas isso nao esta na 0.15.0 do repo
oficial. Por isso o `packages.txt` traz **`waybar-git`** no `[aur]` e nao `waybar` no
oficial. **Quando sair a 0.16, voltar para o pacote oficial** e tirar o `waybar-git`.
Upstream: Alexays/Waybar issues 5008, 5029, 5198 e 5294.

`sort-by-number` tambem era o nome antigo da chave de ordenacao; hoje e `sort-by: "number"`.

## Contador do Discord na barra

`bin/discord-notificacoes.sh` le o **titulo da janela**: o Discord escreve `(3) #canal | ...`
quando ha mencao ou DM nao lida e tira o `(3)` quando voce le. E a unica fonte local do
numero -- o app nao expoe API, e o icone da bandeja so tem o ponto vermelho, sem quantidade.
O modulo `custom/discord` some da barra quando nao ha nada, porque o script devolve `text`
vazio e o `format` e so `{}`; clicar nele vai para a workspace 2.

## Atalhos que vieram do KDE

Preservados de proposito, porque estao na memoria muscular dele:

- `Shift+Print` e `Meta+Shift+S` -> `bin/recorte-clipboard.sh` (regiao direto pro clipboard)
- `Meta+L` -> bloquear
- `Meta+setas` -> mover foco; `Meta+Shift+setas` -> mover janela
- `Alt+Tab` -> overview das workspaces com preview ao vivo (era alternar janelas)
- `Meta+D` e `Alt+D` -> lancador (fuzzel). Os dois fazem a mesma coisa desde 07/09/2026;
  a workspace especial `rascunho` perdeu o atalho e nao tem outro
- `Meta+1..9` -> workspaces
- `Ctrl+Shift+Home` -> `bin/recarregar.sh`, que e o `setup.sh recarregar` com notificacao:
  recarrega compositor, barra, notificacoes e os dois alternadores sem fechar nenhum app,
  e avisa na tela se o `hyprctl configerrors` acusar alguma coisa

O resto esta em `hypr/.config/hypr/atalhos.lua`, que e curto e legivel.

## Regras de janela que importam

O `ricepanel` recebe: `workspace = "9 silent"` (a tela vertical), `fullscreen`,
`border_size = 0`, `no_shadow`, `no_blur`, `no_focus` e `no_initial_focus`. As duas ultimas
substituem o `skiptaskbar` do `kwinrulesrc`: sem elas o painel rouba foco ao subir.

## Transparencia

A opacidade e **global**, no bloco `decoration` do `hyprland.lua`: `active_opacity = 0.96`,
`inactive_opacity = 0.90` e `fullscreen_opacity = 1.0`. Nao existe mais `opacity` por app --
as regras que o ghostty e o VS Code tinham sairam, senao cada janela seguia um valor
diferente do resto da tela.

O `fullscreen_opacity = 1.0` e o que salva video e jogo: em tela cheia a janela volta a ser
solida sozinha. Fora dele, a regra `sempre-solido` de `regras.lua` tira a transparencia de
quem nao pode ter -- `looking-glass-client`, `virt-manager`, `steam_app.*`, `gamescope`,
`mpv` e `vlc`.

Quem faz a transparencia parecer boa e o `blur` com `ignore_opacity = true`: sem ele o que
aparece atras da janela e a imagem crua, nao o desfoque.

O blur roda com `size = 6` e `passes = 3` -- e o custo real do visual, porque cada `passes`
e uma volta inteira no shader. Numa 3090 nao se sente; **quando a placa for pra VM, e o
primeiro numero a baixar** (`passes = 2` corta quase metade do trabalho e quase nao muda a
imagem).

`popups = true` existe por causa da transparencia: menu de contexto e dropdown tambem
herdam a opacidade, e sem essa chave eles saiam translucidos e **sem** desfoque, que e o
pior dos dois mundos. `special = true` faz o mesmo pela workspace `rascunho`, que hoje nao tem atalho.

`xray = false` de proposito: com `true` a janela mostra o wallpaper borrado em vez das
janelas atras. Fica mais limpo e mais barato, mas some a nocao do que esta embaixo.

### Menu de transparencia por app (Meta+O)

`bin/transparencia.py` (GTK4 + libadwaita) lista **so os apps que estao abertos no
momento** -- um cartao por classe, com icone e nome tirados do `.desktop` pelo
`StartupWMClass`, quantas janelas daquele app existem e dois sliders, ativa e inativa.
A lista se refaz sozinha a cada 2s, entao abrir ou fechar app com o menu na tela ja
aparece. O proprio menu e o `ricepanel` ficam de fora.

Arrastar o slider faz **duas** coisas, e e de proposito:

1. `hl.dsp.window.set_prop` com `prop = "opacity"` em cada janela daquela classe, pelo
   `address` -- e o preview instantaneo, sem reload.
2. Depois de 400ms parado, reescreve `hypr/.config/hypr/transparencia.lua` inteiro.

Fazer as duas garante que o que esta na tela e o que esta gravado nunca divergem. O
`set_prop` sobrevive ao `hyprctl reload` (fica na janela, nao na config), entao confiar
so na window rule deixaria fantasma para tras. Voltar um app ao padrao apaga a linha do
arquivo e reaplica o valor global nas janelas dele.

O prop chama **`opacity`**, nao `alphaactive` como no hyprlang -- os outros nomes
respondem `Invalid prop name`. Ele aceita numero ou a string `"ativa inativa"`.

O arquivo gerado usa long string Lua (`[[^classe$]]`) na `class` para o regex nao precisar
de barra dupla. Ele e versionado: a personalizacao sobrevive ao format, e o `require` dele
vem **depois** do `regras.lua` para vencer a regra `sempre-solido`.

## Pegadinhas

- **`transform` do monitor vertical**: `monitores.lua` usa `transform = 1`. Se a imagem
  aparecer de cabeca pra baixo, o valor certo e `3`. So da pra saber olhando.
- **NVIDIA**: `no_hardware_cursors = true` em `cursor` evita cursor invisivel ou piscando.
  As `hl.env` de `LIBVA_DRIVER_NAME`, `__GLX_VENDOR_LIBRARY_NAME` e `NVD_BACKEND` estao no
  `hyprland.lua` e nao devem sair.
- **`hyprctl reload` nao recarrega a waybar**: e processo separado, e o `SIGUSR2` **nao
  serve** quando ela subiu sem barra nenhuma (output que nao existia) -- ela recarrega a
  config e continua sem criar surface. Por isso o `setup.sh recarregar` hoje **mata e sobe
  de novo** pelo `bin/waybar.sh`, que e quem regenera o `output` a cada vez.
- **Script que le marca de tela le o `telas.lua`, nunca o `monitores.lua`**: o `monitores.lua`
  hoje so chama `telas.desc(...)`, entao `sed` atras de `local principal = "desc:..."` volta
  vazio. Foi assim que o `bin/waybar.sh` quebrou em 08/09/2026: com a marca vazia o fallback
  casava todos os monitores e a barra subia no primeiro da lista, a tela vertical do
  RicePanel. O padrao certo e `telas.principal = "..."`, o mesmo que o `bin/monitor.sh` usa.
  Sem a tela principal presente o script sai sem barra, em vez de cair na vertical.
- **`hyprctl keyword` nao existe mais**: responde "keyword can't work with non-legacy
  parsers. Use eval." Para mudar config em runtime, `hyprctl dispatch` com uma funcao Lua.
- Config errada nao derruba a sessao: o Hyprland ignora e segue. Conferir com
  `Hyprland --verify-config` antes de logar e `hyprctl configerrors` depois.
