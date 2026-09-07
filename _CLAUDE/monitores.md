# Monitores

ASUS XG27ACS **2560x1440@180** (principal) e LG UltraGear **1920x1080@144** (vertical).
O LG aceita 2560x1440, mas escalado e a 75 Hz -- sempre o modo nativo. Principal em paisagem a direita; secundario em pe a esquerda, ocupado em
tela cheia pelo `RicePanel` (`~/Apps/desktop/RicePanel`). O vertical girado ocupa
1080 de largura (1920 girado), por isso o principal comeca em x=1080.

`kde/monitores.conf`, casado por **nome de conector** porque os dois sao iguais e resolucao
nao separa:

```
DP-2|1920x1080|left|0,0|1|nao
DP-1|2560x1440|normal|1080,240|1|sim
```

Nomes confirmados na maquina: DP-2 e o LG UltraGear (o vertical), DP-1 e o ASUS XG27ACS
(o principal). `*` na primeira coluna e curinga por resolucao nativa, pra quando trocar de
placa e os nomes mudarem.

Nao editar o conf a mao: arrasta as telas em Configuracoes do Sistema e roda
`bash ~/.dotfiles/kde/monitores.sh --capturar`, que grava a sessao atual por cima do conf.

O `monitores.sh` roda **antes** do `wallpaper.sh` de proposito: o wallpaper decide retrato
x paisagem pela geometria de cada tela.

Nunca versionar `~/.local/share/kscreen/`: e um arquivo por combinacao de monitores, nome
derivado do hash dos EDIDs, quebra ao trocar cabo ou placa.

