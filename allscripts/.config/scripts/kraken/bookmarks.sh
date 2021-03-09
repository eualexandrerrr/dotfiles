#!/usr/bin/env bash

tmp=$(mktemp)

# Extract
grep -Po 'name=\"\K[^"]+(?=\")' $HOME/AOSPK/manifest/snippets/aosp.xml >> $tmp
grep -Po 'name=\"\K[^"]+(?=\")' $HOME/AOSPK/manifest/snippets/extras.xml >> $tmp

# Tags
url="https://review.lineageos.org/q/project:ArrowOS/android_"
url=${url//\//\\/}
branch="+branch:arrow-12.0+status:merged"

# Replace
sed -i "s/Customizer/LineageCustomizer/g" $tmp
sed -i "s/custom/lineage/g" $tmp
sed -i "s/Custom/Lineage/g" $tmp
sed -i "s/aosp/lineage/g" $tmp
sed -i "s/Launcher3/Trebuchet/g" $tmp
sed -i "s/packages_apps_LineageLineageizer/packages_apps_TvCustomizer/g" $tmp

cat $tmp > $HOME/bookmarks_names.txt

# Insert links and branch
sed 's/^/LINK/;s/$/branch/' $tmp > $HOME/bookmarks_link.txt
sed -i "s/LINK/$url/g" $HOME/bookmarks_link.txt
sed -i "s/branch/$branch/g" $HOME/bookmarks_link.txt
