# CLAUDE.md

Pos-instalacao da maquina de desenvolvimento: pacotes, driver, KDE, servicos e os arquivos
de configuracao que valem versionar, cada um no seu pacote, linkado pelo GNU Stow.
Repo remoto: `github.com/eualexandrerrr/dotfiles`, branch `main`.

## Quem e o que

Xande (`eualexandrerrr`), dev Lua/JS, dono do servidor MichiganRoleplay (RedM). Esta e a
maquina de desenvolvimento dele, Arch Linux com KDE Plasma em Wayland. O repo e a
pos-instalacao: pacotes, driver, KDE, servicos e os arquivos de configuracao que valem
versionar, cada um no seu pacote, linkado pelo GNU Stow.

Comunicacao em portugues do Brasil, direto, sem enrolacao. Ele odeia comentario em codigo
novo: mantem so os que ja existem, nunca adiciona. Em troubleshooting, um comando por vez
e espera o resultado antes do proximo. Commits e pushes saem no nome dele, sem co-autor e
sem mencionar Claude na mensagem.

## O que esta acontecendo agora

Ele vai **formatar** e reinstalar pelo instalador proprio (`github.com/eualexandrerrr/myarch`,
opcao 3 da ISO clona este repo e roda o `install.sh`). O objetivo e o KDE sair configurado
inteiro de primeira: tema, painel, wallpaper, monitores, tudo sem toque manual. Hoje ja
foram 14 commits corrigindo o que impedia isso; a lista esta no fim.

Amanha chega hardware novo (ver "Hardware") e a maquina vira duas GPUs com passthrough.
**Isso e a fase seguinte**, nao mexer ainda: o `kernel-nvidia` do `packages.txt` e o
`configure_nvidia()` do install continuam valendo ate a placa nova estar montada.

## install.sh x setup.sh

`install.sh` instala (pacotes, driver, servicos, SDDM). `setup.sh` configura e recarrega,
sem rede e em segundos. Mexeu numa config? `setup.sh`. Mexeu no `packages.txt`? `install.sh`.

```
~/.dotfiles/setup.sh [etapa...]   # links home kde energia monitores wallpaper painel recarregar
```

O `install.sh` (etapa `home_enxuta`) e o `layout-once.sh` chamam o `setup.sh` em vez de
repetir as etapas. Etapa que falha vira aviso e as outras seguem.

**Toda mudança de config termina com refresh forçado.** Ele acompanha olhando a tela e
decide vendo; config gravada que só aparece no próximo login é trabalho não entregue.
Aplicar sempre na sessão real dele e recarregar no mesmo passo:

```
bash ~/.dotfiles/setup.sh recarregar
```

A etapa faz KWin reconfigure, `kbuildsycoca6` e **restart do plasmashell** -- sem esse
último, tema do Plasma e painel não mudam na tela. O `kde/sessao-teste.sh` serve para
validar script arriscado antes, nunca como substituto de aplicar.

Nesta máquina `systemctl` e `pacman` pelados caem num wrapper com `sudo` que o sandbox
recusa ("sinalizador sem novos privilégios"). Use `/usr/bin/systemctl --user ...`; e não
confie em `pacman -Q` para saber se um pacote existe -- ele responde "não instalado" para
pacote instalado. Procure o binário com `command -v`.

## Indice -- ler o arquivo ANTES de mexer no assunto

| Vou mexer em... | Ler primeiro |
|---|---|
| Format, o que sobrevive em `/home`, perfil do Chrome, particoes | `_CLAUDE/particoes-e-format.md` |
| Pacote do stow, onde um arquivo novo entra, regra do `--no-folding` | `_CLAUDE/estrutura-repo.md` |
| Rodar o `install.sh`, entender etapa que falhou, `layout-once.sh` | `_CLAUDE/install-fluxo.md` |
| Disposicao de telas, `monitores.conf`, wallpaper por geometria | `_CLAUDE/monitores.md` |
| DNS, KWallet, keyring, painel na tela vertical | `_CLAUDE/dns-e-kwallet.md` |
| Suspender, hibernar, apagar monitor por inatividade | `_CLAUDE/energia.md` |
| Dolphin, cursor, menu iniciar -- coisa de KDE que ja falhou | `_CLAUDE/kde-pendencias.md` |
| Pastas da home, XDG, onde criar projeto novo | `_CLAUDE/home-enxuta.md` |
| VM Windows, passthrough, vfio, a placa que vai chegar | `_CLAUDE/vm-e-hardware.md` |
| Algo quebrado depois do format | `_CLAUDE/se-quebrar-no-format.md` |
| Saber por que uma correcao de hoje foi feita | `_CLAUDE/historico-commits.md` |
