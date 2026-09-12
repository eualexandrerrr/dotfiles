# CLAUDE.md

Pos-instalacao da maquina de desenvolvimento: pacotes, driver, KDE Plasma, servicos e os
arquivos de configuracao que valem versionar, cada um no seu pacote, linkado pelo GNU Stow.
Repo remoto: `github.com/eualexandrerrr/dotfiles`, branch `main`.

## Quem e o que

Xande (`eualexandrerrr`), dev Lua/JS, dono do servidor MichiganRoleplay (RedM). Esta e a
maquina de desenvolvimento dele, Arch Linux com **KDE Plasma** em Wayland. O repo e a
pos-instalacao: pacotes, driver, compositor, servicos e os arquivos de configuracao que
valem versionar, cada um no seu pacote, linkado pelo GNU Stow.

Comunicacao em portugues do Brasil, direto, sem enrolacao. Ele odeia comentario em codigo
novo: mantem so os que ja existem, nunca adiciona. Em troubleshooting, um comando por vez
e espera o resultado antes do proximo. Commits e pushes saem no nome dele, sem co-autor e
sem mencionar Claude na mensagem.

## O que esta acontecendo agora

Ele vai **formatar** e reinstalar pelo instalador proprio (`github.com/eualexandrerrr/myarch`,
opcao 3 da ISO clona este repo e roda o `install.sh`). O objetivo e o desktop sair
configurado inteiro de primeira, sem toque manual.

Em 10/09/2026 o repo voltou pro **KDE Plasma**, e desta vez **de fabrica**: painel, lancador,
notificacao, captura e configuracao de tela sao os nativos do Plasma. Todo o stack Hyprland
saiu -- hyprland, waybar, swaync, fuzzel, uwsm, awww, swayosd, hyprexpose, hyprswitch,
hypridle, hyprlock, hyprsunset -- junto com ~20 scripts de `bin/` que existiam so pra suprir
o que o Plasma ja faz sozinho.

O motivo nao foi tecnico: ele cansou de perder dia com o desktop em vez de trabalhar. Entao
**nao proponha personalizacao de desktop**. Tema pronto, painel padrao, atalho padrao. O que
este repo cuida e do que o Plasma nao faz: passthrough, tuning de sistema, pacotes,
credenciais e as ferramentas de trabalho dele.

A placa-mae nova ja esta montada e em uso desde 08/09/2026: **ASUS TUF Gaming B550M-PLUS**,
sem wifi e sem bluetooth (a variante com wifi tem o sufixo no nome; esta nao tem). A 3090
esta em `0000:07:00.0`, hoje presa no `vfio-pci` para a VM, e a **RX 550** esta em
`0000:04:00.0` (`card2`, driver `amdgpu`).

**Os dois monitores estao na RX 550** -- `DP-1` e `HDMI-A-1` sao saidas do `card2` --, entao
e a AMD que desenha o desktop. A 3090 nao pertence mais ao host: `nvidia-smi` nao existe
aqui, e quem le os sensores dela e o Windows da VM.
Toda variavel de driver grafico tem que seguir a AMD; o
`plasma/.config/plasma-workspace/env/dotfiles.sh` resolve isso no login lendo o driver de
cada `card`, e `dot status` acusa se alguem voltar a fixar `nvidia`.

Com duas GPUs o cenario de single-GPU passthrough (que derruba a sessao) nao se aplica mais
-- ver `vm/game-mode` e `~/Claude/maquina/docs/vm-e-hardware.md`.

## Tres scripts, e so

| | o que faz | quando roda |
|---|---|---|
| `install.sh` | pacotes, driver, kernel, servicos, SDDM | mexeu no `packages.txt` |
| `setup.sh` | configura tudo, VM inclusa -- sem rede, em segundos | mexeu numa config |
| `reload.sh` | recarrega a sessao de pe (telas, audio, plasmashell, KWin) | algo saiu do lugar agora |

```
~/.dotfiles/setup.sh [etapa...]
# links home perfil arquivos sistema graficos wallpaper vm ddcutil energia atalhos audio dns console chrome claude notificacoes painel tema servicos
```

**Nome de pasta, arquivo e unit sempre em ingles.** Este repo e publico: `secrets/`, nao
`segredos/`; `apply-screens.sh`, nao `telas-aplicar.sh`. Vale pra tudo que tem nome no disco,
inclusive comando que ele digita (`vm/play`, `vm/game-mode`). Comentario e mensagem de saida
continuam em portugues, e o `README.pt-BR.md` fica -- o sufixo diz o idioma do conteudo, nao
e nome em portugues.

Config nova entra como **etapa do `setup.sh`**, nunca como script solto novo na raiz. O que
mora em `bin/` e ferramenta chamada pelas etapas (ou pelo Alexandre a mao), nao ponto de
entrada. Etapa que falha vira aviso e as outras seguem. (O `install.sh` hoje so chama a
etapa `home` do `setup.sh`; o resto ele repete por conta propria.)

## Desktop escolhido na instalacao

O `install.sh` abre um menu numerado (mesmo desenho do `myarch-menu` da ISO) com `kde`, `gnome`, `xfce` e `hyprland`, e
grava a resposta em `~/.local/state/dotfiles/de`. O menu aparece toda vez, mesmo com escolha
gravada: ela vem marcada como atual e Enter mantem, entao trocar de desktop e rodar de novo e
escolher outro numero. Sem terminal interativo (a ISO do myarch roda ele sozinho) usa a escolha
gravada, ou `kde` se nao houver; `--de=<nome>` ou `DE=<nome>` pulam a pergunta. No firstboot
do myarch o menu aparece igual: o script le do `/dev/tty` quando o stdin nao e tty, e sem
resposta em 120 s segue no padrao.

## Cache de pacotes

`CacheDir` do pacman e `PKGDEST` do makepkg apontam pra `/home/.pkgcache/` (`pacman/`, do
usuario `alpm`, e `aur/`, do usuario). Fora da home de proposito: o pacman 6.1 baixa como o
`alpm` e `$HOME` e 700, entao dentro dela o download para em permissao negada. Como a `/home`
e a particao `Files`, que a opcao 3 da ISO nao formata, o que ja foi
baixado e o que ja foi compilado atravessam a reinstalacao: o pacman so busca o que mudou de
versao, e o `install_aur` compara a versao publicada no AUR com o `.pkg.tar.zst` guardado e
instala com `pacman -U` quando bate, caindo no `paru` so quando mudou. O `paccache.timer`
ganha um drop-in pra podar esses dois caches em vez de `/var/cache/pacman/pkg`.

`packages.txt` e a base comum a qualquer desktop; cada desktop tem o seu
`packages/<nome>.txt`, e so o escolhido e instalado. A tabela do que muda entre eles
(`de_sessao`, `de_dm`, `de_binarios`) fica no topo do `install.sh` -- desktop novo e uma
linha em cada uma mais um `packages/<nome>.txt`.

**Os desktops disponiveis estao numa tabela so.** `DES_VALIDOS`, `de_sessao`, `de_dm`,
`de_servidor`, `de_binarios`, `de_nome` e `de_desc` no `install.sh` -- acrescentar um desktop
e uma linha em cada uma mais um `packages/<nome>.txt`. O menu e gerado da tabela, entao nada
precisa ser mexido nele. Hoje sao dez: `kde gnome xfce cinnamon mate lxqt budgie cosmic
hyprland nandoroid`.

**`nandoroid` nao e um desktop, e um shell.** E o Hyprland com o shell NAnDoroid
(na-ive/nandoroid-shell) por cima, instalado pelo `bin/nandoroid.sh` na etapa
`install_nandoroid`. A config do Hyprland deles e em Lua; o script copia os modulos deles e
escreve por ultimo o `configs/janelas.lua`, que e o unico arquivo nosso: ele poe toda janela
pra flutuar centralizada, tira os binds de workspace e troca o alt-tab por
`cyclenext + bringactivetotop`. O pedido era desktop de janelas, sem workspace nenhum.

**So o KDE tem configuracao versionada aqui.** As etapas `arquivos atalhos notificacoes
painel tema` e o pacote stow `plasma/` sao puladas em qualquer outro desktop, que sobe de
fabrica.

**O que e hardware vale em todos os dez desktops.** Layout de tela e papel de parede sao
disposicao de monitor, nao personalizacao: o `bin/apply-screens.sh` e o `bin/apply-wallpaper.sh`
tem um backend por familia -- kscreen-doctor no Plasma, D-Bus do mutter no GNOME, xrandr nos
X11 (XFCE, Cinnamon, MATE, LXQt, Budgie), `hl.monitor` e hyprpaper no Hyprland e no NAnDoroid,
cosmic-randr no COSMIC. Qual backend usar sai da sessao de pe e, sem ela (o `setup.sh` logo
depois do format), da escolha gravada em `~/.local/state/dotfiles/de` -- e assim que o
Hyprland e o NAnDoroid ja nascem com o `configs/screens.lua` escrito, antes do primeiro login.
XFCE, MATE, LXQt, Cinnamon e Budgie nao acendem o `graphical-session.target`, entao neles quem
dispara e o `autostart/` mais o `apply-screens.timer`, nao a unit. A disposicao em si esta
escrita uma vez so, no topo do `apply-screens.sh`; qual conector e qual tela sai sempre do `bin/monitor.sh`, pela marca no
EDID. Cuidado: o nome da saida muda de backend pra backend -- o kernel diz `HDMI-A-2`, o
mutter diz `HDMI-2` e o X diz `DisplayPort-0`. Por isso o mutter casa por marca e o X11 casa
o EDID byte a byte (`monitor.sh --xrandr`).

**O que e driver de video vale nos quatro desktops e mora na etapa `graficos`.** Ela le a
GPU que tem monitor ligado pelo `bin/render-gpu.sh` e grava dois arquivos gerados, nenhum
deles versionado: `~/.config/environment.d/50-dotfiles.conf`, com `GTK_IM_MODULE=simple`
(acento em app GTK no ABNT2), `LANGUAGE`, `LIBVA_DRIVER_NAME`, `KWIN_DRM_DEVICES` e
`AQ_DRM_DEVICES`; e `/etc/udev/rules.d/61-dotfiles-gpu.rules`, que marca a AMD como
`mutter-device-preferred-primary` e a 3090 como `mutter-device-ignore`. O mutter nao tem
variavel equivalente ao `KWIN_DRM_DEVICES`: sem essa regra ele elege a GPU primaria pela
Boot VGA, pega a 3090 e desenha o GNOME nos dummy plugs dela, deixando o monitor real na
tela azul (11/09/2026). A regra de udev tambem vale no gdm, que roda como outro usuario e
nao le `environment.d` nenhum. O `plasma/.config/plasma-workspace/env/dotfiles.sh` hoje so
faz source do arquivo gerado, pro caso de uma sessao do Plasma nascer fora do systemd.

**Toda mudanca de config termina aplicada na sessao real dele.** Ele acompanha olhando a
tela e decide vendo; config gravada que so aparece no proximo login e trabalho nao entregue.
No Plasma isso e `kwriteconfig6` mais o sinal certo, ou a propria GUI -- nunca "reinicia e ve".

**A tela dele nao pode cair.** Ele roda o Claude Code num terminal dentro da sessao grafica:
derrubar o compositor mata a conversa junto. Nada de `uwsm stop`, `systemctl restart sddm` ou
logout sem ele mandar, por escrito, naquela mensagem.

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
| Format, o que sobrevive em `/home`, perfil do Chrome, particoes | `~/Claude/maquina/docs/particoes-e-format.md` |
| Pacote do stow, onde um arquivo novo entra, regra do `--no-folding` | `~/Claude/maquina/docs/estrutura-repo.md` |
| Rodar o `install.sh`, entender etapa que falhou | `~/Claude/maquina/docs/install-fluxo.md` |
| Disposicao de telas, marca de cada monitor (`screens.conf`) | `~/Claude/maquina/docs/monitores.md` |
| DNS, keyring, por que NAO instalar gnome-keyring | `~/Claude/maquina/docs/dns-e-keyring.md` |
| Suspender, hibernar, apagar monitor por inatividade | `~/Claude/maquina/docs/energia.md` |
| Desligar travado ou lento, tela preta no shutdown, fonte e cor do console | `~/Claude/maquina/docs/energia.md` |
| Pastas da home, XDG, onde criar projeto novo | `~/Claude/maquina/docs/home-enxuta.md` |
| VM Windows, passthrough, vfio, a placa que vai chegar | `~/Claude/maquina/docs/vm-e-hardware.md` |
| Memoria RAM, frequencia, timings, FCLK, DOCP, 4 pentes | `~/Claude/maquina/docs/memoria-ram.md` |
| RDP no servidor Windows, onde a senha mora | `~/Claude/maquina/docs/rdp.md` |
| Radmin VPN, bandeja XEmbed do Wine, icone que nao aparece na bandeja | `~/Claude/maquina/docs/radmin-vpn.md` |
| Pagina inicial do Chrome, politica gerenciada | `~/Claude/maquina/docs/chrome-inicio.md` |
| Algo quebrado depois do format | `~/Claude/maquina/docs/se-quebrar-no-format.md` |
| Saber por que uma correcao foi feita | `~/Claude/maquina/docs/historico-commits.md` |
| Android SDK, AVD, emulador, `bin/android-sdk.sh` | `~/Claude/maquina/docs/android.md` |
| Settings do Claude Code, o que do `~/.claude` e versionado | `~/Claude/maquina/docs/install-fluxo.md` |
