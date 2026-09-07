#!/usr/bin/env python3
"""Menu de transparencia por app. Lista so o que esta aberto agora, aplica na tela
enquanto voce arrasta e grava em hypr/.config/hypr/transparencia.lua, que o Hyprland
carrega depois do regras.lua. Sem linha no arquivo, vale o global do bloco decoration.
Chamado pelo Meta+O (hypr/atalhos.lua) e pelo lancador."""

import json
import os
import re
import subprocess
import sys

import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Adw", "1")
from gi.repository import Adw, GLib, Gtk, Gdk, Pango  # noqa: E402

DOTFILES = os.path.expanduser("~/.dotfiles")
CONFIG = os.path.join(DOTFILES, "hypr/.config/hypr/transparencia.lua")
CABECALHO = """-- Gerado pelo bin/transparencia.py (Meta+O). Editar na mao funciona, mas o menu
-- reescreve o arquivo inteiro na proxima vez que voce mexer num slider.
-- App sem linha aqui usa o global do bloco decoration do hyprland.lua.

"""
IGNORADAS = {"ricepanel", "dev.xande.transparencia"}
MINIMO = 0.30

CSS = b"""
window.background { background: #1e1e2e; }
headerbar {
    background: #181825;
    border-bottom: 1px solid #313244;
    box-shadow: none;
    min-height: 46px;
}
headerbar windowtitle { color: #cdd6f4; font-weight: 700; }
.corpo { background: #1e1e2e; }
.cartao {
    background: #262637;
    border: 1px solid #313244;
    border-radius: 14px;
    padding: 14px 16px;
}
.cartao:hover { border-color: #45475a; }
.nome { color: #cdd6f4; font-size: 15px; font-weight: 700; }
.classe { color: #6c7086; font-size: 11px; }
.contagem {
    color: #cba6f7;
    background: #313244;
    border-radius: 8px;
    padding: 2px 9px;
    font-size: 11px;
    font-weight: 700;
}
.rotulo { color: #a6adc8; font-size: 12px; }
.valor {
    color: #cdd6f4;
    font-size: 12px;
    font-weight: 700;
    font-feature-settings: "tnum";
}
.personalizado .valor { color: #cba6f7; }
.rodape { color: #6c7086; font-size: 12px; }
.vazio { color: #6c7086; font-size: 14px; }
button.restaurar {
    background: transparent;
    border: none;
    box-shadow: none;
    color: #6c7086;
    min-width: 26px;
    min-height: 26px;
    padding: 0;
}
button.restaurar:hover { background: #313244; color: #f38ba8; }
scale trough {
    background: #313244;
    border: none;
    min-height: 5px;
    border-radius: 3px;
}
scale highlight { background: #cba6f7; border-radius: 3px; }
scale slider {
    background: #cdd6f4;
    border: none;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.45);
    min-width: 15px;
    min-height: 15px;
    border-radius: 50%;
    margin: -6px;
}
scale:hover slider { background: #ffffff; }
"""


def hypr(*args):
    try:
        saida = subprocess.run(
            ["hyprctl", *args], capture_output=True, text=True, timeout=3
        )
        return saida.stdout
    except (OSError, subprocess.SubprocessError):
        return ""


def opacidades_globais():
    valores = []
    for chave in ("decoration:active_opacity", "decoration:inactive_opacity"):
        achado = re.search(r"float:\s*([0-9.]+)", hypr("getoption", chave))
        valores.append(round(float(achado.group(1)), 2) if achado else 1.0)
    return valores[0], valores[1]


def indice_desktop():
    indice = {}
    pastas = [
        os.path.expanduser("~/.local/share/applications"),
        "/usr/share/applications",
    ]
    for pasta in pastas:
        if not os.path.isdir(pasta):
            continue
        for arquivo in os.listdir(pasta):
            if not arquivo.endswith(".desktop"):
                continue
            nome = icone = wmclass = None
            try:
                with open(os.path.join(pasta, arquivo), errors="ignore") as f:
                    for linha in f:
                        if linha.startswith("[") and nome and icone:
                            break
                        if linha.startswith("Name=") and not nome:
                            nome = linha[5:].strip()
                        elif linha.startswith("Icon=") and not icone:
                            icone = linha[5:].strip()
                        elif linha.startswith("StartupWMClass="):
                            wmclass = linha[15:].strip()
            except OSError:
                continue
            for chave in filter(None, (wmclass, arquivo[:-8])):
                indice.setdefault(chave.lower(), (nome or chave, icone or chave))
    return indice


def apps_abertos(indice):
    try:
        janelas = json.loads(hypr("clients", "-j") or "[]")
    except json.JSONDecodeError:
        return {}
    apps = {}
    for janela in janelas:
        classe = (janela.get("class") or "").strip()
        if not classe or classe.lower() in IGNORADAS:
            continue
        if classe not in apps:
            nome, icone = indice.get(
                classe.lower(), (classe.split(".")[-1].capitalize(), classe.lower())
            )
            apps[classe] = {"nome": nome, "icone": icone, "enderecos": []}
        apps[classe]["enderecos"].append(janela.get("address", ""))
    return dict(sorted(apps.items(), key=lambda par: par[1]["nome"].lower()))


def ler_config():
    regras = {}
    try:
        with open(CONFIG) as f:
            conteudo = f.read()
    except OSError:
        return regras
    padrao = re.compile(
        r'class\s*=\s*\[\[\^(.+?)\$\]\].*?opacity\s*=\s*"([0-9.]+)\s+([0-9.]+)"'
    )
    for classe, ativa, inativa in padrao.findall(conteudo):
        regras[re.sub(r"\\(.)", r"\1", classe)] = (float(ativa), float(inativa))
    return regras


def escrever_config(regras):
    linhas = [CABECALHO]
    for classe in sorted(regras):
        ativa, inativa = regras[classe]
        linhas.append(
            "hl.window_rule({{ name = \"opacidade-{0}\", "
            "match = {{ class = [[^{1}$]] }}, "
            'opacity = "{2:.2f} {3:.2f}" }})\n'.format(
                re.sub(r"[^a-zA-Z0-9]+", "-", classe).strip("-").lower(),
                re.escape(classe),
                ativa,
                inativa,
            )
        )
    os.makedirs(os.path.dirname(CONFIG), exist_ok=True)
    temporario = CONFIG + ".novo"
    with open(temporario, "w") as f:
        f.write("".join(linhas))
    os.replace(temporario, CONFIG)


def aplicar_ao_vivo(enderecos, ativa, inativa):
    for endereco in enderecos:
        if not endereco:
            continue
        hypr(
            "dispatch",
            '(function() local j = hl.get_windows({{ address = "{0}" }})[1]; '
            "if not j then return end; "
            'return hl.dsp.window.set_prop({{ window = j, prop = "opacity", '
            'value = "{1:.2f} {2:.2f}" }}) end)()'.format(endereco, ativa, inativa),
        )


class Cartao(Gtk.Box):
    def __init__(self, janela, classe, app):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        self.add_css_class("cartao")
        self.janela = janela
        self.classe = classe
        self.app = app
        self.silencioso = False

        topo = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        icone = Gtk.Image.new_from_icon_name(app["icone"])
        icone.set_pixel_size(38)
        topo.append(icone)

        textos = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=1, hexpand=True)
        titulo = Gtk.Label(label=app["nome"], xalign=0)
        titulo.add_css_class("nome")
        titulo.set_ellipsize(Pango.EllipsizeMode.END)
        subtitulo = Gtk.Label(label=classe, xalign=0)
        subtitulo.add_css_class("classe")
        subtitulo.set_ellipsize(Pango.EllipsizeMode.MIDDLE)
        textos.append(titulo)
        textos.append(subtitulo)
        topo.append(textos)

        quantas = len(app["enderecos"])
        selo = Gtk.Label(label="{0} janela{1}".format(quantas, "" if quantas == 1 else "s"))
        selo.add_css_class("contagem")
        selo.set_valign(Gtk.Align.CENTER)
        topo.append(selo)

        self.botao = Gtk.Button(icon_name="edit-undo-symbolic")
        self.botao.add_css_class("restaurar")
        self.botao.set_valign(Gtk.Align.CENTER)
        self.botao.set_tooltip_text("Voltar ao padrão do sistema")
        self.botao.connect("clicked", self.ao_restaurar)
        topo.append(self.botao)
        self.append(topo)

        ativa, inativa = janela.regras.get(classe, (janela.padrao_ativa, janela.padrao_inativa))
        self.escala_ativa, self.valor_ativa = self.linha("Ativa", ativa)
        self.escala_inativa, self.valor_inativa = self.linha("Inativa", inativa)
        self.marcar()

    def linha(self, rotulo, valor):
        caixa = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        nome = Gtk.Label(label=rotulo, xalign=0)
        nome.add_css_class("rotulo")
        nome.set_size_request(60, -1)
        caixa.append(nome)

        escala = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, MINIMO, 1.0, 0.01)
        escala.set_draw_value(False)
        escala.set_hexpand(True)
        escala.set_value(valor)
        escala.connect("value-changed", self.ao_mudar)
        caixa.append(escala)

        percentual = Gtk.Label(label="{0:.0f}%".format(valor * 100))
        percentual.add_css_class("valor")
        percentual.set_size_request(42, -1)
        percentual.set_xalign(1.0)
        caixa.append(percentual)

        self.append(caixa)
        return escala, percentual

    def valores(self):
        return (
            round(self.escala_ativa.get_value(), 2),
            round(self.escala_inativa.get_value(), 2),
        )

    def marcar(self):
        ativa, inativa = self.valores()
        padrao = (ativa, inativa) == (self.janela.padrao_ativa, self.janela.padrao_inativa)
        self.botao.set_sensitive(not padrao)
        if padrao:
            self.remove_css_class("personalizado")
        else:
            self.add_css_class("personalizado")

    def ao_mudar(self, _escala):
        if self.silencioso:
            return
        ativa, inativa = self.valores()
        self.valor_ativa.set_label("{0:.0f}%".format(ativa * 100))
        self.valor_inativa.set_label("{0:.0f}%".format(inativa * 100))
        self.marcar()
        aplicar_ao_vivo(self.app["enderecos"], ativa, inativa)
        self.janela.agendar_gravacao(self.classe, ativa, inativa)

    def ao_restaurar(self, _botao):
        self.silencioso = True
        self.escala_ativa.set_value(self.janela.padrao_ativa)
        self.escala_inativa.set_value(self.janela.padrao_inativa)
        self.silencioso = False
        self.ao_mudar(None)


class Janela(Adw.ApplicationWindow):
    def __init__(self, app):
        super().__init__(application=app, title="Transparência")
        self.set_default_size(600, 720)
        self.padrao_ativa, self.padrao_inativa = opacidades_globais()
        self.regras = ler_config()
        self.indice = indice_desktop()
        self.assinatura = None
        self.gravacao = None

        teclas = Gtk.EventControllerKey()
        teclas.connect("key-pressed", self.ao_teclar)
        self.add_controller(teclas)

        raiz = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        cabecalho = Adw.HeaderBar()
        atualizar = Gtk.Button(icon_name="view-refresh-symbolic")
        atualizar.set_tooltip_text("Reler as janelas abertas")
        atualizar.connect("clicked", lambda _b: self.recarregar(True))
        cabecalho.pack_end(atualizar)
        raiz.append(cabecalho)

        self.pilha = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        self.pilha.set_valign(Gtk.Align.START)
        self.pilha.set_margin_top(16)
        self.pilha.set_margin_bottom(8)
        self.pilha.set_margin_start(16)
        self.pilha.set_margin_end(16)

        rolagem = Gtk.ScrolledWindow(vexpand=True)
        rolagem.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        rolagem.set_child(self.pilha)
        rolagem.add_css_class("corpo")
        raiz.append(rolagem)

        self.rodape = Gtk.Label(xalign=0)
        self.rodape.add_css_class("rodape")
        self.rodape.set_margin_start(18)
        self.rodape.set_margin_end(18)
        self.rodape.set_margin_bottom(14)
        self.rodape.set_margin_top(2)
        raiz.append(self.rodape)

        self.set_content(raiz)
        self.recarregar(True)
        GLib.timeout_add_seconds(2, self.recarregar, False)

    def ao_teclar(self, _controlador, tecla, _codigo, _estado):
        if tecla == Gdk.KEY_Escape:
            self.close()
            return True
        return False

    def recarregar(self, forcar):
        apps = apps_abertos(self.indice)
        assinatura = tuple((classe, tuple(dados["enderecos"])) for classe, dados in apps.items())
        if not forcar and assinatura == self.assinatura:
            return True
        self.assinatura = assinatura

        filho = self.pilha.get_first_child()
        while filho:
            proximo = filho.get_next_sibling()
            self.pilha.remove(filho)
            filho = proximo

        if not apps:
            vazio = Gtk.Label(label="Nenhuma janela aberta agora.")
            vazio.add_css_class("vazio")
            vazio.set_margin_top(40)
            self.pilha.append(vazio)
        else:
            for classe, dados in apps.items():
                self.pilha.append(Cartao(self, classe, dados))

        personalizados = sum(1 for classe in apps if classe in self.regras)
        self.rodape.set_label(
            "Padrão do sistema: ativa {0:.0f}%  ·  inativa {1:.0f}%     "
            "{2} de {3} com ajuste próprio".format(
                self.padrao_ativa * 100, self.padrao_inativa * 100, personalizados, len(apps)
            )
        )
        return True

    def agendar_gravacao(self, classe, ativa, inativa):
        if (ativa, inativa) == (self.padrao_ativa, self.padrao_inativa):
            self.regras.pop(classe, None)
        else:
            self.regras[classe] = (ativa, inativa)
        if self.gravacao:
            GLib.source_remove(self.gravacao)
        self.gravacao = GLib.timeout_add(400, self.gravar)

    def gravar(self):
        self.gravacao = None
        escrever_config(dict(self.regras))
        self.recarregar(True)
        return False


class Aplicativo(Adw.Application):
    def __init__(self):
        super().__init__(application_id="dev.xande.transparencia")

    def do_activate(self):
        estilos = Gtk.CssProvider()
        estilos.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(), estilos, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )
        Janela(self).present()


if __name__ == "__main__":
    Adw.init()
    sys.exit(Aplicativo().run(None))
