#!/usr/bin/env python3
"""Move as janelas de um app pra saida pedida, na sessao COSMIC.

    cosmic-move-window.py [--wait SEG] [--fill] <app_id> <saida>
    cosmic-move-window.py --wait 20 --fill RicePanel DP-1

Cliente Wayland nao escolhe em que monitor nasce, e o COSMIC 1.8 nao tem regra de janela
por saida. Quem move e o zcosmic_toplevel_manager_v1 (move_to_ext_workspace), que precisa
de uma area de trabalho daquela saida. O ext_workspace do COSMIC nao anuncia output_enter
nos grupos, entao a relacao area -> saida sai das janelas ja abertas: o handle do COSMIC de
cada toplevel diz em que saida e em que area ele esta. Se nenhuma janela esta na saida alvo,
sobra por eliminacao o grupo que nao pertence a nenhuma outra saida.

Com --fill a janela ainda e maximizada na saida nova: mudar de area de trabalho preserva a
posicao relativa que ela tinha na saida antiga, entao uma janela do tamanho da tela chega
deslocada; maximizar encosta ela no lugar certo.

Fora do COSMIC (sem os protocolos) sai com 0 sem fazer nada, pra poder ficar numa unit.
"""

import os
import sys
import time


def carregar_ligacoes():
    import importlib.util

    caminho = __file__.rsplit("/", 1)[0] + "/minimize-all.py"
    spec = importlib.util.spec_from_file_location("minimize_all", caminho)
    modulo = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(modulo)
    modulo.ligacoes()


def main():
    args = sys.argv[1:]
    espera = 0.0
    encher = False
    while args and args[0].startswith("--"):
        if args[0] == "--wait":
            espera = float(args[1])
            args = args[2:]
        elif args[0] == "--fill":
            encher = True
            args = args[1:]
        else:
            break
    if len(args) != 2:
        print("uso: cosmic-move-window.py [--wait SEG] <app_id> <saida>", file=sys.stderr)
        return 2
    alvo_app, alvo_saida = args

    carregar_ligacoes()
    from pywayland.client import Display
    from wlbind.wayland import WlOutput
    from wlbind.ext_workspace_v1 import ExtWorkspaceManagerV1
    from wlbind.ext_foreign_toplevel_list_v1 import ExtForeignToplevelListV1
    from wlbind.cosmic_toplevel_info_unstable_v1 import ZcosmicToplevelInfoV1
    from wlbind.cosmic_toplevel_management_unstable_v1 import ZcosmicToplevelManagerV1

    saidas = {}          # wl_output -> nome
    areas = {}           # ext_workspace -> grupo
    estado_area = {}     # ext_workspace -> bitmask de estado (1 = ativa)
    janelas = {}         # handle ext -> {"app": str, "cosmic": handle, "saidas": set, "areas": set}
    achados = {}

    display = Display()
    display.connect()
    registro = display.get_registry()

    def anunciou(reg, nome, interface, versao):
        if interface == WlOutput.name:
            saida = reg.bind(nome, WlOutput, min(versao, 4))
            saidas[saida] = None
            saida.dispatcher["name"] = lambda o, n: saidas.__setitem__(o, n)
        elif interface == ExtWorkspaceManagerV1.name:
            achados["areas"] = reg.bind(nome, ExtWorkspaceManagerV1, 1)
        elif interface == ExtForeignToplevelListV1.name:
            achados["lista"] = reg.bind(nome, ExtForeignToplevelListV1, 1)
        elif interface == ZcosmicToplevelInfoV1.name and versao >= 3:
            achados["info"] = reg.bind(nome, ZcosmicToplevelInfoV1, 3)
        elif interface == ZcosmicToplevelManagerV1.name and versao >= 4:
            achados["manager"] = reg.bind(nome, ZcosmicToplevelManagerV1, 4)

    registro.dispatcher["global"] = anunciou
    display.roundtrip()

    if any(k not in achados for k in ("areas", "lista", "info", "manager")):
        display.disconnect()
        return 0

    def novo_grupo(_m, grupo):
        grupo.dispatcher["workspace_enter"] = lambda g, a: areas.__setitem__(a, g)

    def nova_area(_m, area):
        areas.setdefault(area, None)
        area.dispatcher["state"] = lambda a, s: estado_area.__setitem__(a, s)

    achados["areas"].dispatcher["workspace_group"] = novo_grupo
    achados["areas"].dispatcher["workspace"] = nova_area

    def nova_janela(_l, handle):
        info = {"app": None, "cosmic": None, "saidas": set(), "areas": set()}
        janelas[handle] = info
        handle.dispatcher["app_id"] = lambda h, a: info.__setitem__("app", a)
        cosmic = achados["info"].get_cosmic_toplevel(handle)
        info["cosmic"] = cosmic
        cosmic.dispatcher["output_enter"] = lambda c, o: info["saidas"].add(o)
        cosmic.dispatcher["output_leave"] = lambda c, o: info["saidas"].discard(o)
        cosmic.dispatcher["ext_workspace_enter"] = lambda c, a: info["areas"].add(a)
        cosmic.dispatcher["ext_workspace_leave"] = lambda c, a: info["areas"].discard(a)

    achados["lista"].dispatcher["toplevel"] = nova_janela

    limite = time.monotonic() + espera
    while True:
        display.roundtrip()
        display.roundtrip()
        if any(j["app"] == alvo_app for j in janelas.values()) or time.monotonic() >= limite:
            break
        time.sleep(0.5)

    # O cosmic-comp manda o estado do handle do COSMIC um pouco depois de cria-lo, nao no
    # mesmo roundtrip: sem esta espera nenhuma janela diz em que saida esta.
    for _ in range(8):
        time.sleep(0.25)
        display.roundtrip()
        if all(j["saidas"] for j in janelas.values()):
            break

    if os.environ.get("COSMIC_MOVE_DEBUG"):
        for j in janelas.values():
            print(j["app"], [saidas.get(o) for o in j["saidas"]],
                  [areas.get(a) is not None for a in j["areas"]], file=sys.stderr)

    saida_alvo = next((o for o, n in saidas.items() if n == alvo_saida), None)
    if saida_alvo is None:
        print("cosmic-move-window: saida '%s' nao existe" % alvo_saida, file=sys.stderr)
        display.disconnect()
        return 1

    # grupo -> saida, deduzido das janelas que ja estao em algum lugar
    grupo_da_saida = {}
    for j in janelas.values():
        for a in j["areas"]:
            g = areas.get(a)
            if g is None:
                continue
            for o in j["saidas"]:
                grupo_da_saida.setdefault(o, g)

    grupo_alvo = grupo_da_saida.get(saida_alvo)
    if grupo_alvo is None:
        ocupados = set(grupo_da_saida.values())
        livres = [g for g in dict.fromkeys(areas.values()) if g is not None and g not in ocupados]
        if len(livres) == 1:
            grupo_alvo = livres[0]
    if grupo_alvo is None:
        print("cosmic-move-window: nao deu pra saber qual area de trabalho e a da saida '%s'"
              % alvo_saida, file=sys.stderr)
        display.disconnect()
        return 1

    candidatas = [a for a, g in areas.items() if g is grupo_alvo]
    area_alvo = next((a for a in candidatas if estado_area.get(a, 0) & 1), None) or candidatas[0]

    movidas = 0
    for j in janelas.values():
        if j["app"] != alvo_app:
            continue
        if saida_alvo not in j["saidas"]:
            achados["manager"].move_to_ext_workspace(j["cosmic"], area_alvo, saida_alvo)
            movidas += 1
        if encher:
            achados["manager"].set_maximized(j["cosmic"])

    display.roundtrip()
    display.disconnect()
    if not movidas and not encher and not any(j["app"] == alvo_app for j in janelas.values()):
        print("cosmic-move-window: nenhuma janela com app_id '%s'" % alvo_app, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
