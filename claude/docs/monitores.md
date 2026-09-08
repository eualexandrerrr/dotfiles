# Monitores

ASUS XG27ACS **2560x1440@180** (principal) e LG UltraGear **1920x1080@144** (vertical).
O LG aceita 2560x1440, mas escalado e a 75 Hz -- sempre o modo nativo. Principal em paisagem
a direita; secundario em pe a esquerda, ocupado em tela cheia pelo `RicePanel`
(`~/Apps/desktop/RicePanel`). O vertical girado ocupa 1080 de largura (1920 girado), por
isso o principal comeca em x=1080. O y=240 do principal centraliza os 1440 dele nos 1920
do vertical.

As marcas moram em **`hypr/.config/hypr/telas.lua`**, que e a fonte unica do assunto:
`telas.principal` e `telas.vertical` guardam o prefixo da descricao, `telas.desc(papel)`
devolve o `desc:` para o Hyprland e `telas.nome(papel)` resolve o conector atual
(`DP-2`...) por `hl.get_monitors()`. Fora do Lua, **`bin/monitor.sh`** le o mesmo arquivo e
faz o mesmo: `bin/monitor.sh principal` imprime o nome, `--desc` imprime a descricao
inteira. Mudou de monitor? Edita `telas.lua` e pronto -- nada mais no repo cita marca.

`hypr/.config/hypr/monitores.lua`, casado por **descricao do monitor** (`desc:`), nunca
por conector:

```lua
local telas = require("telas")
local principal = telas.desc("principal")
local vertical = telas.desc("vertical")

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

## Programas de fora do Hyprland: quem nao entende `desc:`

Waybar, mako, hyprlock e hyprswitch so aceitam **nome de conector**, e a waybar nem curinga
aceita (`"ASUSTek ... XG27ACS*"` nao casa; `desc:` tampouco -- so a descricao **inteira e
exata**, testado em 07/09/2026 na `v0.15.0-1004-g6d60c8e0`). Por isso cada um sobe por um
wrapper em `bin/`, que resolve a marca na hora e gera a config em `$XDG_RUNTIME_DIR`:

| Programa | Wrapper | O que ele resolve |
|---|---|---|
| waybar | `bin/waybar.sh` | reescreve `.output` do `config.jsonc` com a descricao exata |
| hyprexpose | `bin/hyprexpose.sh` | `ignore_monitors` com o nome do vertical; roda com `XDG_CONFIG_HOME` proprio |
| mako | `bin/mako.sh` | passa `--output <nome>` (o `config` versionado nao tem `output`) |
| hyprlock | `bin/bloquear.sh` | preenche `monitor =` dos widgets, deixando o `background` em todas |
| hyprswitch | `bin/alternador.sh` | passa `--monitors <nome>` no `gui` |

Nenhum arquivo versionado guarda `DP-x`. Se um wrapper nao achar a marca (monitor
desligado), ele cai no comportamento padrao do programa em vez de apontar pra um conector
que nao existe -- que era exatamente o modo de falha antigo.

**O que quebrou em 07/09/2026 por causa disso:** depois da troca de placa-mae a waybar
subia sem barra nenhuma (presa em `DP-1`), o `Alt+Tab` nao mostrava workspace alguma (o
`ignore_monitors = ["DP-2"]` passou a ignorar o **principal**), as notificacoes nao
apareciam e a tela de bloqueio ficava sem campo de senha. Um sintoma so, quatro arquivos.

## Desligar um monitor nao pode quebrar nada

Ele desliga uma tela no botao com frequencia, e isso renumera conector para o Hyprland como
se o cabo tivesse mudado de porta. Os wrappers resolvem a marca **quando sobem**, entao um
monitor que entra ou sai depois deixaria a barra, o mako e o Alt+Tab apontando pro estado
velho. Por isso o `hyprland.lua` tem:

```lua
hl.on("monitor.added", telas_mudaram)
hl.on("monitor.removed", telas_mudaram)
```

que chama `bin/telas-mudaram.sh`: ele mata e sobe de novo waybar, mako, hyprexpose e
hyprswitch pelos wrappers, e refaz o wallpaper. O script tem `flock` e um `sleep 1.5` de
proposito -- ligar uma tela dispara varios eventos seguidos, e sem isso a waybar subia no
meio da renumeracao e tinha que subir outra vez.

Com o monitor principal **desligado**, `bin/monitor.sh principal` sai vazio e o
`bin/waybar.sh` deixa o `output` do arquivo versionado como esta: a descricao exata do ASUS.
A waybar fica sem surface (nao ha onde desenhar) em vez de pular pro vertical, e volta
sozinha quando a tela religa, pelo `monitor.added`.
