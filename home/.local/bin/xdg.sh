#!/bin/bash
# github.com/mamutal91

# Query filetype:
# xdg-mime query filetype file.txt

# Web
xdg-mime default google-chrome.desktop 'x-scheme-handler/about'
xdg-mime default google-chrome.desktop 'x-scheme-handler/htm'
xdg-mime default google-chrome.desktop 'x-scheme-handler/html'
xdg-mime default google-chrome.desktop 'x-scheme-handler/http'
xdg-mime default google-chrome.desktop 'x-scheme-handler/https'

# Images
xdg-mime default gpicview.desktop image/jpg
xdg-mime default gpicview.desktop image/jpeg
xdg-mime default gpicview.desktop image/png
xdg-mime default gpicview.desktop image/gif

# Text
xdg-mime default gpicview.desktop text/plain
