#!/usr/bin/env bash

clear

read -e -p "
Título com espaços? " title
echo $title

read -e -p "
Nome das pastas? " folder
echo $folder

read -e -p "
Categorias? (09:50) " categories
echo $categories

date=$(date +"%Y%m%d")
hour=$(date +"%H%M")

function create() {
echo "---
layout: post
title:  "$title"
date:   $date $hour:00 +0300
categories: $categories
---
Comece escrever aqui
"
}

mkdir -p $HOME/GitHub/mamutal91.github.io/_posts/$folder
create > $HOME/GitHub/mamutal91.github.io/_posts/$folder/$date-$folder.md
