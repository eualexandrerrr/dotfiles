#!/bin/bash
# github.com/mamutal91


# Query filetype:
# Para descobrir o formato do arquivo
# xdg-mime query filetype file.txt
# xdg-mime query default video/mp4

# Images
xdg-mime default gpicview.desktop image/gif
xdg-mime default gpicview.desktop image/jpeg
xdg-mime default gpicview.desktop image/jpg
xdg-mime default gpicview.desktop image/png

# Sheel Script
xdg-mime default atom.desktop text/x-shellscript

# Text
xdg-mime default atom.desktop text/plain

# Web
xdg-mime default Google-chrome.desktop 'x-scheme-handler/about'
xdg-mime default Google-chrome.desktop 'x-scheme-handler/htm'
xdg-mime default Google-chrome.desktop 'x-scheme-handler/html'
xdg-mime default Google-chrome.desktop 'x-scheme-handler/http'
xdg-mime default Google-chrome.desktop 'x-scheme-handler/https'
