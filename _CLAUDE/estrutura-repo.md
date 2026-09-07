# Estrutura do repo

Pacotes do stow na raiz, um por programa, espelhando o `$HOME`. Ferramenta em pasta propria.
O `install.sh` distingue sozinho: pacote e a pasta que tem entrada com ponto na raiz.

```
zsh ghostty git xdg apps systemd-user            <- pacotes, viram links no $HOME
hypr waybar mako fuzzel wlogout qt               <- pacotes da sessao Hyprland
bin        comandos (wallpaper, captura, recorte, energia, audio, dns)
segredos   credenciais cifradas com age; chave so no pendrive do Ventoy
vm         VM Windows com passthrough (XML do libvirt, hooks)
perfil     avatar, copiado pra ~/.face pelo setup.sh
wallpaper  paisagem (principal) e retrato (vertical)
workspaces .code-workspace copiados pra ~/Workspaces
```

Stow roda com `--no-folding --restow`. O `--no-folding` e obrigatorio: sem ele o stow linka
diretorio inteiro e o Chrome/os apps gravam dentro do repo.

O desktop e **Hyprland e so**, desde 07/09/2026. Nao ha sessao KDE alternativa; o Plasma foi
removido inteiro (pacotes, configs, scripts e vendor).

## Onde um arquivo novo entra

Config de programa que vive em `~/.config/<prog>/` -> pacote novo `<prog>/.config/<prog>/`.
Script que voce chama na mao ou por `exec-once` -> `bin/`. Documentacao de decisao -> aqui
em `_CLAUDE/`, nunca comentario no codigo.
