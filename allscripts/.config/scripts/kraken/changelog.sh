#!/usr/bin/env bash

cd /mnt/storage/Kraken

changelog=changelog.txt

if [ -f $changelog ]; then
  rm -f $changelog
fi

touch $changelog

echo "Generating changelog..."

for i in $(seq 14); do
  afterDate=$(date --date="$i days ago" +%Y/%m/%d)
  k=$(expr $i - 1)
  untilDate=$(date --date="$k days ago" +%Y/%m/%d)

  # Line with after --- until was too long for a small ListView
  echo '=======================' >> $changelog
  echo "     "$untilDate         >> $changelog
  echo '=======================' >> $changelog
  echo >> $changelog

  # Cycle through every repo to find commits between 2 dates
  while read path; do
    CLOG=$(git --git-dir ./${path}/.git log --oneline --after=$afterDate --until=$untilDate)
    if [ -n "$CLOG" ]; then
       echo project $path >> $changelog
       git --git-dir ./${path}/.git log --oneline --after=$afterDate --until=$untilDate >> $changelog
    fi
  done < ./.repo/project.list
  echo "" >> $changelog
done

sed -i 's/project/   */g' $changelog

cat changelog.txt
