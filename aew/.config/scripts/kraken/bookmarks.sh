#!/usr/bin/env bash

tmp=$(mktemp)

# Extract
grep -Po 'name=\"\K[^"]+(?=\")' $HOME/AOSPK/manifest/snippets/aosp.xml >> $tmp
grep -Po 'name=\"\K[^"]+(?=\")' $HOME/AOSPK/manifest/snippets/extras.xml >> $tmp

# Tags
url="https://review.arrowos.net/q/project:ArrowOS/"
url=${url//\//\\/}
branch="+branch:twelve+status:merged"

cat $tmp > $HOME/bookmarks_names.txt

# Insert links and branch
sed 's/^/LINK/;s/$/branch/' $tmp > $HOME/bookmarks_link.txt
sed -i "s/LINK/$url/g" $HOME/bookmarks_link.txt
sed -i "s/branch/$branch/g" $HOME/bookmarks_link.txt
