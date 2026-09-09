# CLAUDE.md

Pos-instalacao da maquina de desenvolvimento: pacotes, driver, Hyprland, servicos e os
arquivos de configuracao que valem versionar, cada um no seu pacote, linkado pelo GNU Stow.
Repo remoto: `github.com/eualexandrerrr/dotfiles`, branch `main`.

## Quem e o que

Xande (`eualexandrerrr`), dev Lua/JS, dono do servidor MichiganRoleplay (RedM). Esta e a
maquina de desenvolvimento dele, Arch Linux com **Hyprland** em Wayland. O repo e a
pos-instalacao: pacotes, driver, compositor, servicos e os arquivos de configuracao que
valem versionar, cada um no seu pacote, linkado pelo GNU Stow.

Comunicacao em portugues do Brasil, direto, sem enrolacao. Ele odeia comentario em codigo
novo: mantem so os que ja existem, nunca adiciona. Em troubleshooting, um comando por vez
e espera o resultado antes do proximo. Commits e pushes saem no nome dele, sem co-autor e
sem mencionar Claude na mensagem.

## O que esta acontecendo agora

Ele vai **formatar** e reinstalar pelo instalador proprio (`github.com/eualexandrerrr/myarch`,
opcao 3 da ISO clona este repo e roda o `install.sh`). O objetivo e o desktop sair
configurado inteiro de primeira: compositor, barra, wallpaper, monitores, tudo sem toque
manual.

Em 07/09/2026 o KDE Plasma foi **removido inteiro** e o repo passou a ser Hyprland. Nada
de Plasma, KWin, powerdevil, Dolphin, Spectacle ou Windows-Modern sobrou. A decisao anterior
(04/09/2026, "no dotfiles quero usar KDE") esta revogada.

A placa-mae nova ja esta montada e em uso desde 08/09/2026: **ASUS TUF Gaming B550M-PLUS**,
sem wifi e sem bluetooth (a variante com wifi tem o sufixo no nome; esta nao tem). A 3090
esta em `0000:07:00.0`, hoje presa no `vfio-pci` para a VM, e a **RX 550** esta em
`0000:04:00.0` (`card2`, driver `amdgpu`).

**Os dois monitores estao na RX 550** -- `DP-1` e `HDMI-A-1` sao saidas do `card2` --, entao
e a AMD que desenha o desktop. A 3090 nao pertence mais ao host: `nvidia-smi` nao existe
aqui, e quem le os sensores dela e o Windows da VM.
Toda variavel de driver grafico tem que seguir a AMD; o `uwsm/env` resolve isso no login
lendo o driver de cada `card`, e `dot status` acusa se alguem voltar a fixar `nvidia`.

Atencao: os hooks de single-GPU passthrough dos tutoriais assumem display manager; com
Hyprland o script de start precisa parar a sessao direto (ver `~/Claude/maquina/docs/vm-e-hardware.md`).

## install.sh x setup.sh

`install.sh` instala (pacotes, driver, servicos, SDDM). `setup.sh` configura e recarrega,
sem rede e em segundos. Mexeu numa config? `setup.sh`. Mexeu no `packages.txt`? `install.sh`.

```
~/.dotfiles/setup.sh [etapa...]   # links home perfil tema energia audio dns wallpaper console claude recarregar
```

O `install.sh` (etapas `home_enxuta` e `configure_hyprland`) chama o `setup.sh` em vez de
repetir as etapas. Etapa que falha vira aviso e as outras seguem.

**Toda mudanca de config termina com refresh forcado.** Ele acompanha olhando a tela e
decide vendo; config gravada que so aparece no proximo login e trabalho nao entregue.
Aplicar sempre na sessao real dele e recarregar no mesmo passo:

```
bash ~/.dotfiles/setup.sh recarregar
```

A etapa faz `hyprctl reload`, reinicia a waybar (SIGUSR2) e recarrega o mako. Diferente do
Plasma, o Hyprland aplica a config na hora e sem reiniciar nada -- entao nao existe mais
desculpa de "so no proximo login".

**A config do Hyprland e Lua, nao hyprlang.** Desde a 0.55 o `.conf` esta deprecado; na
0.56 as `windowrule` em hyprlang falham inteiras. Antes de entregar qualquer mexida em
`hypr/`, rodar **`Hyprland --verify-config`** -- ele valida sem subir sessao e responde
`config ok`. Config errada nao da erro na cara: e ignorada, e a sessao sobe torta. A
referencia offline da versao instalada e `/usr/share/hypr/stubs/hl.meta.lua`; consultar
ela antes da wiki, que descreve a versao mais nova. Detalhe em `~/Claude/maquina/docs/hyprland.md`.

Nesta maquina `systemctl` e `pacman` pelados caem num wrapper com `sudo` que o sandbox
recusa ("sinalizador sem novos privilegios"). Use `/usr/bin/systemctl --user ...`; e nao
confie em `pacman -Q` para saber se um pacote existe -- ele responde "nao instalado" para
pacote instalado. Procure o binario com `command -v`. Para saber se um pacote EXISTE nos
repos, `pacman -Si <nome>` funciona.

O shell padrao e **zsh**: `for p in $var` nao faz word splitting. Em script de uso unico,
rode por `bash -c '...'` ou use array.

## Indice -- ler o arquivo ANTES de mexer no assunto

Os docs desta maquina moram no repositorio **privado** `~/Claude` (`maquina/docs/`), nunca
aqui: este repo e publico. Sem o clone, `git clone git@github.com:eualexandrerrr/Claude.git
~/Claude` -- o `install.sh` ja faz isso na etapa `clonar_central`.


| Vou mexer em... | Ler primeiro |
|---|---|
| Compositor, atalhos, regras de janela, waybar, barra | `~/Claude/maquina/docs/hyprland.md` |
| Format, o que sobrevive em `/home`, perfil do Chrome, particoes | `~/Claude/maquina/docs/particoes-e-format.md` |
| Pacote do stow, onde um arquivo novo entra, regra do `--no-folding` | `~/Claude/maquina/docs/estrutura-repo.md` |
| Rodar o `install.sh`, entender etapa que falhou | `~/Claude/maquina/docs/install-fluxo.md` |
| Disposicao de telas, `monitores.lua`, wallpaper por geometria | `~/Claude/maquina/docs/monitores.md` |
| DNS, keyring, por que NAO instalar gnome-keyring | `~/Claude/maquina/docs/dns-e-keyring.md` |
| Suspender, hibernar, apagar monitor por inatividade | `~/Claude/maquina/docs/energia.md` |
| Desligar travado, tela preta no shutdown, fonte e cor do console | `~/Claude/maquina/docs/energia.md` |
| Pastas da home, XDG, onde criar projeto novo | `~/Claude/maquina/docs/home-enxuta.md` |
| VM Windows, passthrough, vfio, a placa que vai chegar | `~/Claude/maquina/docs/vm-e-hardware.md` |
| RDP no servidor Windows, onde a senha mora | `~/Claude/maquina/docs/rdp.md` |
| Radmin VPN, bandeja XEmbed do Wine, icone que nao aparece na waybar | `~/Claude/maquina/docs/radmin-vpn.md` |
| Pagina inicial do Chrome, politica gerenciada | `~/Claude/maquina/docs/chrome-inicio.md` |
| Algo quebrado depois do format | `~/Claude/maquina/docs/se-quebrar-no-format.md` |
| Saber por que uma correcao foi feita | `~/Claude/maquina/docs/historico-commits.md` |
| Android SDK, AVD, emulador, `bin/android-sdk.sh` | `~/Claude/maquina/docs/android.md` |
| Settings do Claude Code, o que do `~/.claude` e versionado | `~/Claude/maquina/docs/install-fluxo.md` |
