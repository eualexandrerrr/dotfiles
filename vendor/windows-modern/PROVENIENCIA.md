# Windows Modern, vendorado

Estes arquivos vieram do [KDE-Windows-Modern](https://github.com/Jeysef/KDE-Windows-Modern)
e estão **versionados aqui de propósito**: o `install.sh` deste repo não clona nem roda o
instalador do upstream. Um clone raso do tema são 122 MB e o instalador dele mexe em dez
componentes com `pkexec`; copiar os arquivos que interessam é mais previsível e deixa a
pós-instalação funcionar sem rede depois do `pacman`.

    origem   https://github.com/Jeysef/KDE-Windows-Modern.git
    commit   7ef6bfe99a472f2fc7fa473383eda50f411a8840
    data     2026-07-19

Conferido antes de copiar: o instalador do upstream **copia os arquivos sem transformar**
nenhum, então o que está aqui é idêntico ao que ele instalaria.

## O que ficou de fora

| Descartado | Tamanho | Por quê |
|:--|:--|:--|
| tema de ícones `windows-modern` | 28 MB | o ícone desta máquina é `Tela-dark`, no `kde-settings.conf` |
| toda a variante `light` | 4,7 MB | a máquina roda `org.kde.windowsmodern.dark` |
| applet `icontasks` do tema | — | o painel usa o `org.kde.plasma.icontasks` de fábrica |

> **Cuidado com o `icontasks` do upstream.** O instalador dele não só adiciona: ele
> **apaga** `/usr/share/plasma/plasmoids/org.kde.plasma.icontasks/` do pacote
> `plasma-desktop` e põe no lugar um `.so` binário com o mesmo plugin id, órfão do
> pacman. Além de deixar o sistema com dois arquivos faltando (`pacman -Qkk
> plasma-desktop`), esse fork quebra a tradução em dois pontos: usa o domínio
> `plasma_applet_org.kde.plasma.icontasks` em vez de `…taskmanager`, onde mora o
> catálogo pt_BR do Arch, e removeu o `&` dos msgids (`&Pin to Task Manager` virou
> `Pin to Task Manager`), então nem casaria se o domínio estivesse certo. Achado nesta
> máquina em 05/09/2026, vindo de uma execução manual do instalador do upstream, não
> deste repo. Corrigido com `pacman -S plasma-desktop` e removendo o `.so`.
| `build/` do systray | 33 MB | artefato de compilação |
| capturas, wallpapers, docs | — | não entram na configuração |

Dos 38 MB instalados sobraram 6,2 MB.

## Estrutura

    share/    copiado pra ~/.local/share/
    config/   copiado pra ~/.config/
    src/      único componente em C++: compilado pelo install.sh

O `share/plasma/shells/org.kde.windowsmodern.lockscreen` é caso à parte. O kscreenlocker
lê a tela de bloqueio do pacote da shell **atual** (`org.kde.plasma.desktop`), então o
`install.sh` monta um overlay em `~/.local/share/plasma/shells/org.kde.plasma.desktop`:
symlink pra tudo do pacote do sistema, menos o `lockscreen`, que vem daqui. A shell tem que
ficar completa — se faltar peça, o Plasma cai no visual feio de fallback do Qt.

## Licença

GPL-3.0. O `LICENSE` e o `ATTRIBUTION.md` ao lado são os do upstream e creditam os seis
projetos de onde o tema deriva. Não edite os arquivos deste diretório na mão: para
atualizar, traga de novo do upstream e registre o commit novo aqui.
