#!/bin/bash
# github.com/mamutal91

storage="/media/storage/github"

function fim() {
  echo
  echo " X Resposta inválida, finalizando script..."
  sleep 4s
  exit
}

echo -e " Repositório?"
echo -e " ----------------------"
echo
echo -e "     1. dotfiles"
echo -e "     2. archlinux"
echo -e "     3. buildroid"
echo -e "     4. mamutal91.github.io"
echo -e "     5. strojects"
echo
echo -n " Reposta: "
read resposta
case "$resposta" in
  1|"")
    cd $storage/dotfiles
  ;;
  2)
    cd $storage/archlinux
  ;;
  3)
    cd $storage/buildroid
  ;;
  4)
   cd $storage/mamutal91.github.io
  ;;
  5)
    cd $storage/strojects
  ;;
  *)
    fim
  ;;
esac
echo
clear

echo -e " Declarar autoria?"
echo -e " ----------------------"
echo
echo -e "     1. Não "
echo -e "     2. Sim [Full Name] <nome@email.com>]"
echo
echo -n " Reposta: "
read resposta
case "$resposta" in
  1|"")
    author="Alexandre Rangel <mamutal91@gmail.com>"
    echo $author
  ;;
  2)
    printf "\n"
    echo "Digite seu nome:"
    read nome
    echo "Autor > $nome"
    author="$nome"
  ;;
  *)
    fim
  ;;
esac
echo
clear

echo -e " Será um novo commit?"
echo -e " ----------------------"
echo
echo -e "     1. New commit"
echo -e "     2. --ammend"
echo
echo -e " Author: $author"
echo
echo -n " Reposta: "
read resposta
case "$resposta" in
  1|"")
    git add .
      if [ "$author" == "Alexandre Rangel <mamutal91@gmail.com>" ]
      then
          git commit -s --author="$author" --date "$(date)"
      else
          git commit --author="$author" --date "$(date)"
      fi
#    git push
  ;;
  2)
    git add .
    git commit --amend --author="$author" --date "$(date)"
    git push
  ;;
  *)
    fim
  ;;
esac
echo

sleep 3s

#DISPLAY=:0 dbus-launch notify-send -i $icon "dotfiles atualizado."
