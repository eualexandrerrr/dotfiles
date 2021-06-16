#!/usr/bin/env bash

# Markup tools
Markup.inlineKeyboard() {
  jq -nc '{$inline_keyboard}' \
    --argjson inline_keyboard "$inlineKeyboardButton"
}

Markup.button_url() {
  if [[ $inlineKeyboardButton ]]; then
    inlineKeyboardButton=$(
      jq '.[$line] += [{$text, $url}]' \
        --arg text "$1" \
        --arg url "$2" \
        --argjson line "$3" <<< "$inlineKeyboardButton")
  else
    inlineKeyboardButton=$(
      jq -n -s '.[$line] += [{$text, $url}]' \
        --arg text "$1" \
        --arg url "$2" \
        --argjson line "$3")
  fi
}
