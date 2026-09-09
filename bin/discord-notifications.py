#!/usr/bin/env python3

# Marca o botao da workspace do Discord na waybar quando ha mensagem nao lida.
#
# Nao imprime nada visivel: o modulo custom que chama este script existe so pelo intervalo,
# e o desenho sai por CSS. O modulo hyprland/workspaces nao aceita marcador vindo de fora,
# entao a unica forma de por o ponto no proprio icone e escrever uma regra e deixar a waybar
# recarregar o estilo -- ela observa o arquivo que recebeu no -s e os @import dele.
#
# De onde vem o estado:
#   - titulo da janela ("(3) #canal | Servidor - Discord"): so ganha o "(3)" em mencao direta
#     e DM. Notificacao de servidor nao aparece la, e era por isso que a barra ficava limpa
#     com o Discord piscando;
#   - icone da bandeja: o Discord desenha um badge vermelho #ED4245 sobre o pixmap, e esse
#     enxerga os dois casos. Nao da o numero, mas da a presenca.
#
# Badge por DBus esta fora: o binario do Discord 1.0.157 nao tem uma ocorrencia sequer de
# com.canonical.Unity.LauncherEntry.

import json
import os
import re
import subprocess

LIMIAR_PIXELS = 8  # o badge tem ~40 px vermelhos num icone de 24x24; anti-alias fica bem abaixo
WORKSPACE_DISCORD = 2

DESTINO = os.path.join(
    os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "waybar", "discord.css"
)

# Ponto com anel na cor do fundo da barra: sem o anel ele encosta no glyph e vira sujeira.
PONTO = (
    "radial-gradient(circle at 78% 22%,"
    " @red 0px, @red 4px,"
    " @base 4px, @base 6px,"
    " transparent 6px)"
)

REGRA = f"""#workspaces button:nth-child({WORKSPACE_DISCORD}) {{
    background-image: {PONTO};
}}

#workspaces button:nth-child({WORKSPACE_DISCORD}).active {{
    background-image: {PONTO},
                      linear-gradient(135deg, @mauve, @blue);
}}
"""


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


def tem_nao_lida():
    titulo = hyprctl_titulo()
    if titulo is None:
        return False
    if re.match(r"^\(\d+\)", titulo):
        return True
    return pixels_vermelhos(icone_do_discord()) >= LIMIAR_PIXELS


def escrever(css):
    # So grava quando muda: cada gravacao acorda o inotify da waybar e refaz o provider de
    # estilo inteiro. Em regime normal o arquivo fica parado.
    try:
        with open(DESTINO) as f:
            if f.read() == css:
                return
    except FileNotFoundError:
        pass
    os.makedirs(os.path.dirname(DESTINO), exist_ok=True)
    provisorio = DESTINO + ".tmp"
    with open(provisorio, "w") as f:
        f.write(css)
    os.replace(provisorio, DESTINO)


def main():
    escrever(REGRA if tem_nao_lida() else "")
    print("")


if __name__ == "__main__":
    main()
