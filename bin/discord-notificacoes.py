#!/usr/bin/env python3

# Indicador de mensagem nao lida do Discord para a waybar, em JSON.
#
# O titulo da janela ("(3) #canal | Servidor - Discord") so ganha o "(3)" quando ha mencao
# direta ou DM. Notificacao de servidor nao aparece la, e era por isso que a barra ficava
# limpa com o Discord piscando. A fonte que enxerga os dois casos e o icone da bandeja:
# o Discord desenha um badge vermelho sobre ele, e o pixmap vem pelo DBus.
#
# O binario nao fala com.canonical.Unity.LauncherEntry (conferido no 1.0.157), entao badge
# por DBus esta fora -- so sobra ler o desenho.

import json
import re
import subprocess

VERMELHO = "\U000f0669"  # nf-md-discord
LIMIAR_PIXELS = 8  # o badge tem ~40 px vermelhos num icone de 24x24; ruido de anti-alias fica bem abaixo


def hyprctl_titulo():
    try:
        saida = subprocess.run(
            ["hyprctl", "clients", "-j"], capture_output=True, text=True, timeout=4
        ).stdout
        for janela in json.loads(saida):
            if janela.get("class") == "discord":
                return janela.get("title") or ""
    except Exception:
        pass
    return None


def itens_da_bandeja():
    try:
        saida = subprocess.run(
            [
                "gdbus", "call", "--session",
                "--dest", "org.kde.StatusNotifierWatcher",
                "--object-path", "/StatusNotifierWatcher",
                "--method", "org.freedesktop.DBus.Properties.Get",
                "org.kde.StatusNotifierWatcher", "RegisteredStatusNotifierItems",
            ],
            capture_output=True, text=True, timeout=4,
        ).stdout
    except Exception:
        return []
    return re.findall(r"'([^']+)'", saida)


def propriedade(dest, caminho, nome):
    try:
        return subprocess.run(
            [
                "gdbus", "call", "--session",
                "--dest", dest, "--object-path", caminho,
                "--method", "org.freedesktop.DBus.Properties.Get",
                "org.kde.StatusNotifierItem", nome,
            ],
            capture_output=True, text=True, timeout=4,
        ).stdout
    except Exception:
        return ""


def icone_do_discord():
    # O nome do bus (":1.58") muda a cada vez que o Discord sobe, entao o item e procurado
    # pelo Id, que e estavel.
    for item in itens_da_bandeja():
        dest, _, caminho = item.partition("/")
        caminho = "/" + caminho
        if "discord" not in propriedade(dest, caminho, "Id").lower():
            continue
        return propriedade(dest, caminho, "IconPixmap")
    return ""


def pixels_vermelhos(pixmap):
    # ARGB32, largura e altura vem no proprio retorno. O badge do Discord e #ED4245.
    m = re.search(r"\((\d+), (\d+), \[byte (.*?)\]\)", pixmap, re.S)
    if not m:
        return 0
    largura, altura = int(m.group(1)), int(m.group(2))
    try:
        bytes_ = [int(x, 16) for x in m.group(3).replace("0x", "").split(",")]
    except ValueError:
        return 0
    if len(bytes_) < largura * altura * 4:
        return 0
    conta = 0
    for i in range(0, largura * altura * 4, 4):
        a, r, g, b = bytes_[i], bytes_[i + 1], bytes_[i + 2], bytes_[i + 3]
        if a > 40 and r > 150 and g < 110 and b < 110:
            conta += 1
    return conta


def diz(texto, tooltip, classe):
    print(json.dumps({"text": texto, "tooltip": tooltip, "class": classe}))


def main():
    titulo = hyprctl_titulo()
    if titulo is None:
        diz("", "Discord fechado", "fechado")
        return

    # O numero exato so existe no titulo; quando ele esta la, e a melhor resposta.
    conta = re.match(r"^\((\d+)\)", titulo)
    if conta:
        n = int(conta.group(1))
        plural = "1 mensagem" if n == 1 else f"{n} mensagens"
        diz(f"{VERMELHO} {n}", f"{plural} no Discord", "pendente")
        return

    # Sem numero no titulo, o badge da bandeja ainda denuncia notificacao de servidor.
    if pixels_vermelhos(icone_do_discord()) >= LIMIAR_PIXELS:
        diz(f"{VERMELHO} •", "Discord com mensagem nao lida", "pendente")
        return

    diz("", "Discord sem mensagem nova", "limpo")


if __name__ == "__main__":
    main()
