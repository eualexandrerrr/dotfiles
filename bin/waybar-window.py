#!/usr/bin/env python3

import json
import os
import re
import socket
import subprocess
import sys

TITULO_MAX = 46
NOME_MAX = 18
RETICENCIA = "…"

ICONES = {
    "google-chrome": ("", "Chrome"),
    "chromium": ("", "Chromium"),
    "firefox": ("", "Firefox"),
    "discord": ("\U000f0669", "Discord"),
    "vesktop": ("\U000f0669", "Discord"),
    "com.mitchellh.ghostty": ("", "Ghostty"),
    "kitty": ("", "Kitty"),
    "foot": ("", "Foot"),
    "rcode": ("\U000f0a1e", "RCode"),
    "code": ("\U000f0a1e", "VS Code"),
    "cursor": ("\U000f0a1e", "Cursor"),
    "ricepanel": ("\U000f0379", "Mirante"),
    "thunar": ("\U000f024b", "Arquivos"),
    "nautilus": ("\U000f024b", "Arquivos"),
    "virt-manager": ("\U000f0879", "Maquinas"),
    "looking-glass-client": ("\U000f0879", "Looking Glass"),
    "steam": ("\U000f04d3", "Steam"),
    "gamescope": ("\U000f04d3", "Jogo"),
    "mpv": ("\U000f040a", "mpv"),
    "vlc": ("\U000f040a", "VLC"),
    "spotify": ("", "Spotify"),
    "obs": ("\U000f0448", "OBS"),
    "gimp": ("\U000f02e9", "GIMP"),
    "pavucontrol": ("\U000f057e", "Audio"),
    "nwg-look": ("\U000f0331", "Aparencia"),
    "nwg-displays": ("\U000f0379", "Telas"),
    "xarchiver": ("\U000f05c8", "Arquivador"),
    "org.kvantum.kvantummanager": ("\U000f0331", "Kvantum"),
    "qt5ct": ("\U000f0331", "Qt5"),
    "qt6ct": ("\U000f0331", "Qt6"),
    "emulator": ("\U000f0325", "Emulador"),
    "com.freerdp": ("\U000f0879", "RDP"),
    "org.remmina": ("\U000f0879", "Remmina"),
    "obsidian": ("\U000f0c1a", "Obsidian"),
    "zen": ("", "Zen"),
    "org.telegram.desktop": ("", "Telegram"),
}

GENERICO = "\U000f05d0"
VAZIO = ("\U000f02dc", "area de trabalho")

SUFIXOS = [
    re.compile(r"\s*[—–-]\s*(Google Chrome|Chromium|Mozilla Firefox)$"),
    re.compile(r"\s*[—–-]\s*Discord$"),
    re.compile(r"\s*[—–-]\s*Visual Studio Code$"),
]


def corta(texto, limite):
    texto = texto.strip()
    if len(texto) <= limite:
        return texto
    return texto[: limite - 1].rstrip() + RETICENCIA


def bonito(classe):
    base = classe.split(".")[-1] if "." in classe else classe
    base = base.replace("-", " ").replace("_", " ").strip()
    if not base:
        return "janela"
    return corta(base[:1].upper() + base[1:], NOME_MAX)


def identidade(classe):
    chave = classe.strip().lower()
    if chave in ICONES:
        return ICONES[chave]
    for prefixo, par in ICONES.items():
        if chave.startswith(prefixo):
            return par
    return (GENERICO, bonito(classe))


def limpa_titulo(titulo, nome):
    for suf in SUFIXOS:
        titulo = suf.sub("", titulo)
    titulo = titulo.strip()
    if titulo.lower() == nome.lower():
        return ""
    return titulo


def monta(classe, titulo):
    if not classe.strip():
        icone, nome = VAZIO
        return {"text": icone + "  " + nome, "tooltip": nome, "class": "vazia"}

    icone, nome = identidade(classe)
    titulo = limpa_titulo(titulo, nome)
    if titulo:
        texto = "{}  {} ({})".format(icone, nome, corta(titulo, TITULO_MAX))
    else:
        texto = "{}  {}".format(icone, nome)
    return {
        "text": texto,
        "tooltip": "{}\n{}".format(nome, titulo) if titulo else nome,
        "class": classe.strip().lower().replace(".", "-"),
    }


def emite(classe, titulo):
    sys.stdout.write(json.dumps(monta(classe, titulo), ensure_ascii=False) + "\n")
    sys.stdout.flush()


def estado_inicial():
    try:
        bruto = subprocess.run(
            ["hyprctl", "-j", "activewindow"],
            capture_output=True, text=True, timeout=3,
        ).stdout
        dados = json.loads(bruto or "{}")
        return dados.get("class", "") or "", dados.get("title", "") or ""
    except Exception:
        return "", ""


def caminho_socket():
    his = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    runtime = os.environ.get("XDG_RUNTIME_DIR")
    if not his or not runtime:
        return None
    return os.path.join(runtime, "hypr", his, ".socket2.sock")


def acompanha(caminho):
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.connect(caminho)
    resto = ""
    with sock:
        while True:
            pedaco = sock.recv(8192)
            if not pedaco:
                return
            resto += pedaco.decode("utf-8", "replace")
            linhas = resto.split("\n")
            resto = linhas.pop()
            for linha in linhas:
                nome, _, dados = linha.partition(">>")
                if nome == "activewindow":
                    classe, _, titulo = dados.partition(",")
                    emite(classe, titulo)
                elif nome in ("closewindow", "windowtitle", "windowtitlev2"):
                    emite(*estado_inicial())


def main():
    emite(*estado_inicial())
    caminho = caminho_socket()
    if not caminho:
        return 1
    while True:
        try:
            acompanha(caminho)
        except Exception:
            pass
        try:
            import time
            time.sleep(2)
        except KeyboardInterrupt:
            return 0


if __name__ == "__main__":
    sys.exit(main())
