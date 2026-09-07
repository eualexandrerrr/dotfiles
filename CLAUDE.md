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

Amanha chega hardware novo (ver "Hardware") e a maquina vira duas GPUs com passthrough.
**Isso e a fase seguinte**, nao mexer ainda: o `kernel-nvidia` do `packages.txt` e o
`configure_nvidia()` do install continuam valendo ate a placa nova estar montada.
Atencao: os hooks de single-GPU passthrough dos tutoriais assumem display manager; com
Hyprland o script de start precisa parar a sessao direto (ver `_CLAUDE/vm-e-hardware.md`).

## install.sh x setup.sh

`install.sh` instala (pacotes, driver, servicos, SDDM). `setup.sh` configura e recarrega,
sem rede e em segundos. Mexeu numa config? `setup.sh`. Mexeu no `packages.txt`? `install.sh`.

```
~/.dotfiles/setup.sh [etapa...]   # links home perfil tema energia audio dns wallpaper recarregar
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

Nesta maquina `systemctl` e `pacman` pelados caem num wrapper com `sudo` que o sandbox
recusa ("sinalizador sem novos privilegios"). Use `/usr/bin/systemctl --user ...`; e nao
confie em `pacman -Q` para saber se um pacote existe -- ele responde "nao instalado" para
pacote instalado. Procure o binario com `command -v`. Para saber se um pacote EXISTE nos
repos, `pacman -Si <nome>` funciona.

O shell padrao e **zsh**: `for p in $var` nao faz word splitting. Em script de uso unico,
rode por `bash -c '...'` ou use array.

## Indice -- ler o arquivo ANTES de mexer no assunto

| Vou mexer em... | Ler primeiro |
|---|---|
| Compositor, atalhos, regras de janela, waybar, barra | `_CLAUDE/hyprland.md` |
| Format, o que sobrevive em `/home`, perfil do Chrome, particoes | `_CLAUDE/particoes-e-format.md` |
| Pacote do stow, onde um arquivo novo entra, regra do `--no-folding` | `_CLAUDE/estrutura-repo.md` |
| Rodar o `install.sh`, entender etapa que falhou | `_CLAUDE/install-fluxo.md` |
| Disposicao de telas, `monitores.conf`, wallpaper por geometria | `_CLAUDE/monitores.md` |
| DNS, keyring, por que NAO instalar gnome-keyring | `_CLAUDE/dns-e-keyring.md` |
| Suspender, hibernar, apagar monitor por inatividade | `_CLAUDE/energia.md` |
| Pastas da home, XDG, onde criar projeto novo | `_CLAUDE/home-enxuta.md` |
| VM Windows, passthrough, vfio, a placa que vai chegar | `_CLAUDE/vm-e-hardware.md` |
| Algo quebrado depois do format | `_CLAUDE/se-quebrar-no-format.md` |
| Saber por que uma correcao foi feita | `_CLAUDE/historico-commits.md` |
