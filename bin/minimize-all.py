#!/usr/bin/env python3
"""Minimiza todas as janelas da sessao COSMIC -- o "mostrar area de trabalho".

O cosmic-comp 1.8 nao tem acao de shortcut pra isso: o `Minimize` do
com.system76.CosmicSettings.Shortcuts so vale pra janela em foco. Quem sabe minimizar
qualquer janela e o protocolo zcosmic_toplevel_manager_v1, entao este script fala direto com
ele: lista os toplevels pelo ext_foreign_toplevel_list_v1, converte cada um em handle do
COSMIC e manda set_minimized.

As ligacoes Python sao geradas na hora a partir dos XML (bin/protocols/ mais o
ext-foreign-toplevel-list do wayland-protocols) e ficam em cache no XDG_CACHE_HOME -- gerar
custa ~1 s e so acontece de novo quando algum XML muda.
"""

import os
import pathlib
import sys
import tempfile

RAIZ = pathlib.Path(__file__).resolve().parent
XMLS = [
    # O core entra junto porque o gerador do pywayland resolve wl_seat e wl_output por
    # import relativo: sem ele no mesmo lote, para em KeyError: 'wl_output'.
    pathlib.Path("/usr/share/wayland/wayland.xml"),
    RAIZ / "protocols" / "cosmic-toplevel-info-unstable-v1.xml",
    RAIZ / "protocols" / "cosmic-toplevel-management-unstable-v1.xml",
    # O handle de toplevel referencia workspace nos dois dialetos, entao os dois entram.
    RAIZ / "protocols" / "cosmic-workspace-unstable-v1.xml",
    pathlib.Path("/usr/share/wayland-protocols/staging/ext-workspace/ext-workspace-v1.xml"),
    pathlib.Path("/usr/share/wayland-protocols/staging/ext-foreign-toplevel-list"
                 "/ext-foreign-toplevel-list-v1.xml"),
]


def ligacoes():
    cache = pathlib.Path(os.environ.get("XDG_CACHE_HOME", pathlib.Path.home() / ".cache"))
    # Pacote de verdade: o gerador do pywayland escreve um modulo por protocolo e eles se
    # importam entre si por caminho relativo, o que so funciona dentro de um pacote.
    raiz_cache = cache / "dotfiles" / "wayland-bindings"
    destino = raiz_cache / "wlbind"
    marca = destino / ".gerado"
    assinatura = "".join(f"{x}:{x.stat().st_mtime_ns};" for x in XMLS if x.is_file())

    if not marca.is_file() or marca.read_text() != assinatura:
        from pywayland.scanner import Protocol

        destino.mkdir(parents=True, exist_ok=True)
        tmp = tempfile.mkdtemp(dir=destino.parent)
        protocolos = [Protocol.parse_file(str(x)) for x in XMLS if x.is_file()]
        imports = {i.name: p.name for p in protocolos for i in p.interface}
        for p in protocolos:
            p.output(tmp, imports)
        for item in pathlib.Path(tmp).iterdir():
            alvo = destino / item.name
            if alvo.exists():
                continue
            item.rename(alvo)
        (destino / "__init__.py").write_text("")
        marca.write_text(assinatura)

    sys.path.insert(0, str(raiz_cache))


def main():
    ligacoes()
    from pywayland.client import Display
    from wlbind.cosmic_toplevel_management_unstable_v1 import ZcosmicToplevelManagerV1
    from wlbind.cosmic_toplevel_info_unstable_v1 import ZcosmicToplevelInfoV1
    from wlbind.ext_foreign_toplevel_list_v1 import ExtForeignToplevelListV1

    encontrados = {"info": None, "manager": None, "lista": None}
    janelas = []

    display = Display()
    display.connect()
    registro = display.get_registry()

    # No pywayland o dispatcher e um dicionario, nao um decorador.
    def anunciou(reg, nome, interface, versao):
        if interface == ExtForeignToplevelListV1.name:
            encontrados["lista"] = reg.bind(nome, ExtForeignToplevelListV1, min(versao, 1))
        elif interface == ZcosmicToplevelInfoV1.name:
            encontrados["info"] = reg.bind(nome, ZcosmicToplevelInfoV1, min(versao, 3))
        elif interface == ZcosmicToplevelManagerV1.name:
            encontrados["manager"] = reg.bind(nome, ZcosmicToplevelManagerV1, min(versao, 4))

    registro.dispatcher["global"] = anunciou
    display.roundtrip()

    if not all((encontrados["lista"], encontrados["info"], encontrados["manager"])):
        print("minimize-all: esta sessao nao expoe o protocolo de toplevel do COSMIC",
              file=sys.stderr)
        return 1

    def novo_toplevel(_lista, handle):
        janelas.append(handle)

    encontrados["lista"].dispatcher["toplevel"] = novo_toplevel
    display.roundtrip()
    display.roundtrip()

    for handle in janelas:
        cosmic = encontrados["info"].get_cosmic_toplevel(handle)
        encontrados["manager"].set_minimized(cosmic)

    display.roundtrip()
    display.disconnect()
    return 0


if __name__ == "__main__":
    sys.exit(main())
