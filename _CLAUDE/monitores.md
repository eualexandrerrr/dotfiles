# Monitores

ASUS XG27ACS **2560x1440@180** (principal) e LG UltraGear **1920x1080@144** (vertical).
O LG aceita 2560x1440, mas escalado e a 75 Hz -- sempre o modo nativo. Principal em paisagem
a direita; secundario em pe a esquerda, ocupado em tela cheia pelo `RicePanel`
(`~/Apps/desktop/RicePanel`). O vertical girado ocupa 1080 de largura (1920 girado), por
isso o principal comeca em x=1080. O y=240 do principal centraliza os 1440 dele nos 1920
do vertical.

`hypr/.config/hypr/monitores.conf`, casado por **nome de conector** porque os dois sao
iguais e resolucao nao separa:

```
monitor = DP-1, 2560x1440@180.00, 1080x240, 1
monitor = DP-2, 1920x1080@143.98, 0x0, 1, transform, 1
monitor = , preferred, auto, 1
```

Nomes confirmados na maquina: DP-2 e o LG UltraGear (o vertical), DP-1 e o ASUS XG27ACS
(o principal). A terceira linha e o curinga: monitor novo entra em `preferred/auto` em vez
de ficar preto.

**`transform, 1`** e 90 graus. Se a imagem sair de cabeca pra baixo, o valor certo e `3`.
Nao da pra decidir isso lendo arquivo -- so olhando a tela.

O mesmo arquivo prende workspace a monitor: 1 a 8 no DP-1, **9 no DP-2** (que e onde a
regra de janela do `ricepanel` joga o painel).

Para mexer arrastando em vez de editar: `nwg-displays` grava em
`~/.config/hypr/monitors.conf` -- **nome diferente do nosso**. Se usar, copiar o resultado
para `monitores.conf` do repo, senao a mudanca fica fora do git.

O `bin/wallpaper.sh` le a geometria por `hyprctl monitors -j` e **desconta o transform**
(1, 3, 5 e 7 trocam largura por altura) antes de decidir retrato x paisagem. Sem isso o
monitor girado receberia a imagem em paisagem.

Nao existe mais nada tipo `~/.local/share/kscreen/`: a disposicao inteira e este arquivo.
