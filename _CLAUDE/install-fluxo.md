# Fluxo do install e o que conferir

```
bash ~/.dotfiles/install.sh
```

13 etapas (15 com NVIDIA). A ordem e: pacman -> oficiais -> paru -> AUR -> node/claude ->
nvidia -> servicos -> clone/pull -> stow -> home enxuta -> segredos -> sddm ->
`configure_hyprland`.

Rodando de TTY (caso do format), a ultima diz "sem sessao do Hyprland agora; wallpaper entra
no primeiro login" -- **isso e o caminho certo**, nao erro. O `hyprland.conf` tem
`exec-once = ~/.dotfiles/bin/wallpaper.sh`, entao o wallpaper entra sozinho quando a sessao
sobe.

Nao existe mais `layout-once.sh` nem marca de "layout aplicado". Aquele mecanismo inteiro
existia porque o Plasma so aceitava configuracao com o shell vivo, por D-Bus, e porque a
ordem entre Layan e Klassy mordia. No Hyprland a configuracao **e** o arquivo: nasce
linkada pelo stow e vale no primeiro frame. Isso apagou a classe de bug mais cara do repo.

`configure_hyprland` faz: avatar (`~/.face`), tema GTK, `bin/energia.sh`,
`systemctl --user enable ricepanel.service` e -- se ja houver sessao -- wallpaper e recarga.

Depois de logar, o que olhar:

```
hyprctl configerrors
systemctl --user status ricepanel.service
cat ~/.local/state/dotfiles/install.log
```

Tempos: primeira rodada paga `mkinitcpio` (~25s). Da segunda em diante e pulado quando nada
que entra na imagem mudou. Nao ha mais compilacao de bandeja em C++ (~30s) -- ela era do
Windows-Modern e saiu junto com o Plasma.
