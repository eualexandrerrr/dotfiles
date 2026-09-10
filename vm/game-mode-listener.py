#!/usr/bin/env python3
# Escuta so no IP da bridge da libvirt: o unico jeito de bater aqui e vindo da VM, que e
# exatamente o caso de uso (Ctrl+Alt+Home dentro do Windows chama isto pra rodar "voltar" no host).
import http.server
import subprocess
import sys

PORT = 8765
IP = "192.168.122.1"
SCRIPT = sys.argv[1]


class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/voltar":
            subprocess.Popen([SCRIPT, "voltar"])
            self.send_response(200)
        else:
            self.send_response(404)
        self.end_headers()

    def log_message(self, *_):
        pass


http.server.HTTPServer((IP, PORT), Handler).serve_forever()
