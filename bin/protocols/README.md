# Protocolos do COSMIC

Os dois XML aqui sao copia de [pop-os/cosmic-protocols](https://github.com/pop-os/cosmic-protocols),
da System76, sob MPL-2.0. Nao sao nossos: estao vendorizados porque o `bin/minimize-all.sh`
precisa gerar as ligacoes Python em tempo de execucao e o pacote `cosmic` do Arch nao instala
os XML em lugar nenhum do sistema.

O `ext-foreign-toplevel-list-v1.xml`, que completa o trio, vem do pacote `wayland-protocols`
em `/usr/share/wayland-protocols/staging/`, entao esse nao precisa de copia.
