# Monitores

ASUS XG27ACS **2560x1440@180** (principal) e LG UltraGear **1920x1080@144** (vertical).
O LG aceita 2560x1440, mas escalado e a 75 Hz -- sempre o modo nativo. Principal em paisagem
a direita; secundario em pe a esquerda, ocupado em tela cheia pelo `RicePanel`
(`~/Apps/desktop/RicePanel`). O vertical girado ocupa 1080 de largura (1920 girado), por
isso o principal comeca em x=1080. O y=240 do principal centraliza os 1440 dele nos 1920
do vertical.

`hypr/.config/hypr/monitores.lua`, casado por **descricao do monitor** (`desc:`), nunca
por conector:

```lua
local principal = "desc:ASUSTek COMPUTER INC XG27ACS"
local vertical = "desc:LG Electronics LG ULTRAGEAR"

hl.monitor({ output = principal, mode = "2560x1440@180.00", position = "1080x240", scale = 1 })
hl.monitor({ output = vertical, mode = "1920x1080@143.98", position = "0x0", scale = 1, transform = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
```

A terceira linha e o curinga: monitor novo entra em `preferred/auto` em vez de ficar preto.

**Nome de conector nao e estavel.** Em 07/09/2026, trocar a placa-mae renomeou as portas
-- o ASUS foi de DP-1 para DP-2 e o LG de DP-2 para DP-3. Com a regra presa ao conector,
o `transform = 1` do vertical caiu no principal, que subiu girado e em 1920x1080@120. A
descricao nao depende de porta, cabo nem placa; as duas marcas sao diferentes, entao
prefixo curto ja separa. Ver a descricao real com `hyprctl monitors -j`, campo
`description`.

**`transform = 1`** e 90 graus. Se a imagem sair de cabeca pra baixo, o valor certo e `3`.
Nao da pra decidir isso lendo arquivo -- so olhando a tela.

O mesmo arquivo prende workspace a monitor: 1 a 8 no principal, **9 no vertical** (que e
onde a regra de janela do `ricepanel` joga o painel). As `workspace_rule` usam as mesmas
variaveis `desc:`, pelo mesmo motivo.

Para mexer arrastando em vez de editar: `nwg-displays` grava em
`~/.config/hypr/monitors.conf`, em **hyprlang e com nome diferente do nosso**. Se usar, ler
os numeros de la e traduzir para o `monitores.lua` do repo a mao -- senao a mudanca fica
fora do git e em formato deprecado.

O `bin/wallpaper.sh` le a geometria por `hyprctl monitors -j` e **desconta o transform**
(1, 3, 5 e 7 trocam largura por altura) antes de decidir retrato x paisagem. Sem isso o
monitor girado receberia a imagem em paisagem.

Nao existe mais nada tipo `~/.local/share/kscreen/`: a disposicao inteira e este arquivo.

Validar sempre com `Hyprland --verify-config` depois de mexer.
