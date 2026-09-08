# dotfiles

Pós-instalação da máquina de desenvolvimento: Arch Linux, **Hyprland** em Wayland, NVIDIA,
e os arquivos de configuração que valem versionar — cada um no seu pacote, linkado pelo
GNU Stow.

```
git clone https://github.com/eualexandrerrr/dotfiles ~/.dotfiles
bash ~/.dotfiles/install.sh
```

O `install.sh` é idempotente: pode rodar de novo a qualquer hora. Sem placa NVIDIA ele pula
driver e parâmetros de kernel sozinho (ou force com `SKIP_NVIDIA=1`).

---

## install.sh × setup.sh

| | o quê | quando |
|---|---|---|
| `install.sh` | instala pacotes, driver, serviços, SDDM | mexeu no `packages.txt` |
| `setup.sh` | configura e recarrega, sem rede, em segundos | mexeu numa config |

```
~/.dotfiles/setup.sh                  # tudo
~/.dotfiles/setup.sh links wallpaper  # só as etapas citadas
~/.dotfiles/setup.sh --lista          # mostra as etapas
```

Etapas: `links home perfil tema energia audio dns wallpaper claude recarregar`.
Etapa que falha vira aviso; as outras seguem.

---

## A sessão

O SDDM abre a sessão **Hyprland (uwsm)** — `hyprland-uwsm.desktop`, não o `hyprland.desktop`
puro. O [uwsm](https://github.com/Vladimir-csp/uwsm) coloca o compositor dentro de units do
systemd, e é isso que faz o `graphical-session.target` existir de verdade. O
`ricepanel.service` depende dele; com Hyprland pelado o painel do monitor vertical não sobe.

Por isso todo app iniciado pela sessão usa `uwsm app -- <programa>`: cada um vira um scope
do systemd e morre junto com a sessão, em vez de virar processo órfão.

### Peças

| Função | Programa |
|---|---|
| Compositor | `hyprland` |
| Barra | `waybar` (topo, só no monitor principal, casado por marca) |
| Lançador | `fuzzel` |
| Notificações | `mako` |
| Wallpaper | `awww` (o antigo `swww`, renomeado) |
| Inatividade / bloqueio | `hypridle` / `hyprlock` |
| Filtro noturno | `hyprsunset` |
| Autenticação gráfica | `hyprpolkitagent` |
| OSD de volume e brilho | `swayosd` |
| Histórico de clipboard | `cliphist` + `wl-clip-persist` |
| Encerrar sessão | `wlogout` |
| Arquivos | `thunar` (GUI) e `yazi` (terminal) |
| Captura | `grim` + `slurp` + `satty` |
| Imagens / PDF / vídeo | `imv` / `zathura` / `mpv` |

### Configuração

Tudo em arquivo de texto versionado — a razão prática de ter saído do Plasma, que misturava
configuração com estado em `~/.config` e obrigava a aplicar por D-Bus com o shell vivo.

```
hypr/.config/hypr/hyprland.lua     raiz: env, autostart, hl.config, animações
hypr/.config/hypr/telas.lua        marcas dos monitores; fonte única do assunto
hypr/.config/hypr/monitores.lua    telas e workspaces
hypr/.config/hypr/atalhos.lua      todos os hl.bind
hypr/.config/hypr/regras.lua       hl.window_rule e hl.layer_rule
hypr/.config/hypr/transparencia.lua  gerado pelo menu do Meta+O, opacidade por app
hypr/.config/hypr/hypridle.conf    inatividade (hypridle ainda usa hyprlang)
hypr/.config/hypr/hyprlock.conf    tela de bloqueio (idem)
waybar/.config/waybar/             config.jsonc + style.css
mako/.config/mako/config           notificações
fuzzel/.config/fuzzel/fuzzel.ini   lançador
wlogout/.config/wlogout/           menu de encerrar
```

O `hyprland.lua` faz `require` de todos os outros. Mexer em atalho é mexer só no
`atalhos.lua`. Depois de editar:

```
Hyprland --verify-config                # obrigatório: diz "config ok" ou lista os erros
bash ~/.dotfiles/setup.sh recarregar    # hyprctl reload + waybar + mako
```

**A config é Lua, não hyprlang.** Desde o Hyprland 0.55 o formato `.conf` está deprecado; na
0.56 as `windowrule` em hyprlang falham inteiras. A referência offline casada com a versão
instalada é `/usr/share/hypr/stubs/hl.meta.lua` (todos os campos e dispatchers) — consultar
antes da wiki, que descreve a versão mais recente e não necessariamente a sua.

---

## Atalhos

| Tecla | Ação |
|---|---|
| `Meta+Return` | terminal (ghostty) |
| `Meta+R` / `Meta+Space` / `Meta+D` / `Alt+D` | lançador |
| `Meta+E` | arquivos |
| `Meta+B` | navegador |
| `Meta+Q` | fechar janela |
| `Meta+F` | tela cheia |
| `Meta+T` | flutuar |
| `Meta+V` | histórico de clipboard |
| `Meta+L` | bloquear |
| `Meta+Shift+E` | encerrar sessão |
| `Meta+1..9` | workspaces |
| `Meta+Shift+1..9` | mover janela para o workspace |
| `Meta+setas` | mover foco |
| `Meta+Shift+setas` | mover janela |
| `Meta+Alt+setas` | redimensionar |
| `Alt+Tab` | overview com preview ao vivo: segura o Alt, `Tab` avança, solta e entra |
| `Super+Tab` | alternar janelas |
| `Print` | captura do monitor focado |
| `Shift+Print` / `Meta+Shift+S` | recorte direto pro clipboard |
| `Meta+Shift+A` | recorte com anotação (satty) |
| `Meta+Shift+R` | gravar tela (liga/desliga) |
| `Meta+I` / `Meta+Shift+I` | tema GTK / monitores |
| `Ctrl+Shift+Home` | recarregar a sessão sem fechar nada |

`Shift+Print`, `Meta+Shift+S`, `Meta+L`, `Alt+Tab` e `Meta+setas` vieram do KDE de
propósito — memória muscular.

---

## Workspaces

Cada app tem a sua, por regra em `hypr/.config/hypr/regras.lua`, e a barra mostra o ícone
do app no lugar do número — clicar no ícone vai para a workspace.

| Workspace | App |
|---|---|
| 1 | Google Chrome |
| 2 | Discord (contador de menções aparece na barra) |
| 3 | RCode |
| 4 | VM (virt-manager e looking-glass) |
| 9 | RicePanel, na tela vertical — fora do `Alt+Tab` |

## Monitores

ASUS XG27ACS 2560x1440@180 (principal) e LG UltraGear 1920x1080@144 em pé, este
ocupado em tela cheia pelo RicePanel. Os dois são casados por **marca**
(`hypr/.config/hypr/telas.lua`), nunca por conector. O vertical girado ocupa 1080 de
largura, por isso o principal começa em x=1080; o y=240 centraliza os 1440 dele nos 1920
do vertical.

```lua
hl.monitor({ output = telas.desc("principal"), mode = "2560x1440@180.00", position = "1080x240", scale = 1 })
hl.monitor({ output = telas.desc("vertical"), mode = "1920x1080@143.98", position = "0x0", scale = 1, transform = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
```

### Nome de conector não é estável

Trocar a placa-mãe renumerou as portas em 07/09/2026 — o ASUS foi de `DP-1` para `DP-2` e o
LG de `DP-2` para `DP-3`. Com a regra presa ao conector, o `transform` do vertical caiu no
principal, a waybar subiu sem barra nenhuma, o `Alt+Tab` parou de mostrar workspace (o
`ignore_monitors` passou a ignorar o **principal**), as notificações sumiram e a tela de
bloqueio ficou sem campo de senha. Um sintoma só, quatro arquivos.

Hoje **nenhum arquivo versionado guarda `DP-x`**. A marca mora em `telas.lua` e é resolvida
na hora do uso — em Lua por `telas.nome()`, e fora dele por `bin/monitor.sh`, que imprime o
conector atual (ou a descrição inteira, com `--desc`) e sai `!= 0` quando a tela não está
presente. É o que o `ExecCondition` do `ricepanel.service` usa para não subir o painel em
fullscreen por cima do monitor principal quando o vertical está desligado.

Waybar, mako, hyprlock e hyprswitch só aceitam nome de conector — a waybar nem curinga, só a
descrição inteira e exata. Por isso cada um sobe por um wrapper que resolve a marca e gera a
config em `$XDG_RUNTIME_DIR`:

| Programa | Wrapper |
|---|---|
| waybar | `bin/waybar.sh` |
| hyprexpose | `bin/hyprexpose.sh` |
| mako | `bin/mako.sh` |
| hyprlock | `bin/bloquear.sh` |
| hyprswitch | `bin/alternador.sh` |

Ligar ou desligar uma tela no botão renumera os conectores do mesmo jeito, então
`monitor.added` e `monitor.removed` chamam o `bin/telas-mudaram.sh`, que resobe esses daemons
e refaz o wallpaper.

O `bin/wallpaper.sh` lê a geometria por `hyprctl monitors -j` e **desconta o transform**
antes de decidir retrato × paisagem: a imagem em pé vai pro monitor em pé, a paisagem pros
outros. As duas imagens são as mesmas do MyWinISO, pro Windows e o Arch não terem cara
diferente.

Para arrastar em vez de editar, `nwg-displays` — mas ele grava em
`~/.config/hypr/monitors.conf`, em **hyprlang e com nome diferente do nosso**; leia os
números de lá e traduza pro `monitores.lua` do repo à mão, senão a mudança fica fora do git
e em formato deprecado.

---

## Terminal

zsh com plugins dos repos oficiais, sem oh-my-zsh. `starship` no prompt, `atuin` no `Ctrl+R`,
`fzf` no `Ctrl+T`, `zoxide` para pular de pasta.

**Tab progressivo.** O `matcher-list` tenta em ordem: exato, ignorando maiúscula, o pedaço
digitado como prefixo de qualquer trecho separado por `.` `_` `-`, e por fim como substring
em qualquer posição. Só passa pro próximo quando o anterior não acha nada, então match exato
continua ganhando quando existe. Com `_comp_options+=(globdots)` os arquivos ocultos entram
sem precisar digitar o ponto:

```
cd dot<Tab>    -> cd .dot        para no prefixo comum: .dotfiles, .dotfiles-private, .dotnet
cd dotn<Tab>   -> cd .dotnet/    candidato unico, completa inteiro
```

O `globdots` vai só na completion de propósito — `setopt globdots` seria global e faria
`rm *` pegar arquivo oculto junto.

**Seta pra cima filtra pelo que já está escrito.** `up-line-or-beginning-search`: digitar `cd`
e subir passeia só pelos `cd` anteriores, em vez de percorrer o histórico inteiro. É por isso
que o atuin sobe com `--disable-up-arrow` — ele fica com o `Ctrl+R` e deixa a seta livre.
Com o cursor no meio de um comando de várias linhas, a seta anda entre as linhas.

Os `bindkey` ficam no fim do `.zshrc`, depois do atuin e do fzf, que reescrevem bindings.

---

## Energia

Nunca suspende, nunca hiberna. A única coisa que a inatividade faz é apagar os monitores em
5 minutos. Três camadas: `hypridle`, alvos de sono **mascarados** no systemd e
`IdleAction=ignore` no logind (as duas últimas em `bin/energia.sh`). Bloqueio automático
fica desligado; `Meta+L` bloqueia na hora, com senha.

---

## Keyring: não instalar nenhum

**Sem keyring, o Chrome usa o backend `basic`** (cookies `v10`), então o perfil sobrevive ao
format sem depender da senha de login. Instalar `gnome-keyring` passaria os cookies pra
`v11` e criaria essa dependência — por isso ele não está no `packages.txt` e não deve entrar
por conveniência de nenhum app. O `ricepanel.service` sobe o Electron com
`--password-store=basic` pelo mesmo motivo.

No KDE isso custava quatro bloqueios (o KWallet voltava pelo PAM, pelo autostart e pela
ativação D-Bus). Com o Plasma fora, o estado desejado virou o padrão natural.

---

## Estrutura

```
zsh ghostty git xdg apps systemd-user   pacotes stow, viram links no $HOME
hypr waybar mako fuzzel wlogout qt      pacotes da sessão
bin        wallpaper, captura, recorte, energia, audio, dns, wrappers de monitor
claude     settings, CLAUDE.md, skills e a documentação (docs/), copiados pra ~/.claude
pacotes    PKGBUILD e patches dos pacotes locais (hyprexpose-xande)
segredos   credenciais cifradas com age; chave só no pendrive do Ventoy
vm         VM Windows com passthrough (XML do libvirt, hooks)
perfil     avatar, copiado pra ~/.face
wallpaper  paisagem (principal) e retrato (vertical)
workspaces .code-workspace copiados pra ~/Workspaces
```

Stow roda com `--no-folding --restow`. O `--no-folding` é obrigatório: sem ele o stow linka
o diretório inteiro e os apps passam a gravar dentro do repo.

Pacote é a pasta que tem entrada com ponto na raiz (`.config`, `.local`, `.zshrc`) — o
`install.sh` distingue sozinho. Pasta sem isso é ferramenta.

---

## Notas para quem for depurar

- Linha inválida **não derruba a sessão**: o Hyprland ignora e segue. Por isso
  `Hyprland --verify-config` antes de logar é obrigatório — ele roda sem subir sessão.
- `hyprctl reload` não recarrega a waybar — é processo separado. E `SIGUSR2` **não basta**
  quando ela subiu sem barra nenhuma (output que não existia): ela relê a config e continua
  sem criar surface. Por isso o `setup.sh recarregar` mata e sobe de novo pelo
  `bin/waybar.sh`. JSON inválido no `config.jsonc` derruba a barra inteira.
- `hyprctl keyword` não existe mais: responde *"keyword can't work with non-legacy parsers.
  Use eval."* Para mudar config em runtime, `hyprctl dispatch` com uma função Lua.
- `mode = "highrr"` maximiza a **taxa**, não a resolução — derruba a tela pra 1024x768@180.
  Resolução e taxa sempre explícitas no `monitores.lua`.
- `transform = 1` é 90°. Se a tela vertical sair de cabeça pra baixo, o valor certo é `3`.
- Em NVIDIA, `no_hardware_cursors = true` evita cursor invisível ou piscando.
- O shell é zsh: `for p in $var` não faz word splitting. Use array ou `bash -c`.
- `pacman -Q` mente sobre pacote instalado nesta máquina; use `command -v` para binário e
  `pacman -Si` para saber se um pacote existe nos repos.

---

## Créditos

O overview de workspaces do `Alt+Tab` é o **[hyprexpose](https://github.com/ThiagoAVicente/hyprexpose)**,
de ThiagoAVicente, sob licença MIT. Este repo usa uma **versão modificada**: o pacote
`pacotes/hyprexpose/` compila o upstream com o patch `0001-ignorar-monitores-e-alt-tab.patch`,
que faz três coisas: adiciona a chave `ignore_monitors` — ausente no original — para deixar o
monitor vertical de fora do overview; ensina o overlay a ler `Tab` e o release do Alt na
própria surface, porque com grab exclusivo de teclado os binds do compositor não chegam lá; e
fixa o grid em uma linha só, que é como um Alt+Tab se lê. Nada mais foi alterado.

O alternador de janelas do `Super+Tab` é o **[hyprswitch](https://github.com/egnrse/hyprswitch)**
(fork de [H3rmt/hyprshell](https://github.com/H3rmt/hyprshell)), MIT, usado sem modificação.

## Histórico

Em 08/09/2026, com as duas GPUs montadas, o Hyprland subia sem desenhar em tela nenhuma.
Duas causas somadas: o `aquamarine` elegia a NVIDIA como GPU primária e a importação
cross-GPU pra AMD falhava (`GBM: Buffer is marked as multigpu`), deixando as duas saídas da
RX 550 em `enabled=disabled`; e o `monitores.lua` pedia `2560x1440@180`, taxa que existe na
DP da 3090 mas não na HDMI da RX 550, cujo EDID para em `@120`. Entrou o pacote `uwsm`, que
resolve a placa no `amdgpu` em tempo de sessão e exporta `AQ_DRM_DEVICES` antes do Hyprland
subir — resolver na hora em vez de fixar o caminho PCI, porque o endereço muda ao trocar de
slot ou de placa-mãe e um caminho morto ali deixa a sessão sem tela.

Até 07/09/2026 este repo era KDE Plasma, com painel, Layan, Klassy, Windows-Modern e um
`layout-once.sh` que aplicava tudo por D-Bus no primeiro login. Isso saiu inteiro na
migração para Hyprland: pacotes, configs, scripts e vendor. O que sobreviveu foram as
decisões que não eram do Plasma — wallpaper por geometria, DNS medido, sono mascarado,
ausência de keyring e o RicePanel no monitor vertical.
