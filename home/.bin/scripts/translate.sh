#!/usr/bin/env bash
# github.com/mamutal91

typing="$HOME/.tmp/.translate_typing.txt"
result="$HOME/.tmp/.translate_result.txt"

rm -rf $typing $result
nano $typing

trans -b :en -i $typing > $result

git add . && git commit --message $result --author "Alexandre Rangel <mamutal91@gmail.com>" && git push -f
