# Estrutura do repo

Pacotes do stow na raiz, um por programa, espelhando o `$HOME`. Ferramenta em pasta propria.
O `install.sh` distingue sozinho: pacote e a pasta que tem entrada com ponto na raiz.

```
zsh ghostty kwin plasma dolphin powerdevil autostart apps git xdg   <- pacotes, viram links no $HOME
kde        scripts e decisoes do Plasma (settings.conf, monitores.conf, layout-once...)
segredos   credenciais cifradas com age; chave so no pendrive do Ventoy
bin        comandos
vm         VM Windows com passthrough (XML do libvirt, hooks)
vendor     tema Windows Modern, versionado
wallpaper  paisagem (principal) e retrato (vertical)
```

Stow roda com `--no-folding --restow`. O `--no-folding` e obrigatorio: sem ele o stow linka
diretorio inteiro e o KDE/Chrome gravam dentro do repo.

O desktop e **KDE Plasma e so**. Hyprland entrou e saiu hoje; nao volta como sessao
alternativa nem como nada.

