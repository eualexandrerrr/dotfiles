#!/bin/bash

## Author : Aditya Shakya
## Github : adi1090x

PDIR="$HOME/.config/polybar"
LAUNCH="polybar-msg cmd restart"


elif  [[ ${1} = "-deep-purple" ]]; then
sed -i -e 's/shade1 = .*/shade1 = #512DA8/g' $PDIR/config
sed -i -e 's/shade2 = .*/shade2 = #5E35B1/g' $PDIR/config
sed -i -e 's/shade3 = .*/shade3 = #673AB7/g' $PDIR/config
sed -i -e 's/shade4 = .*/shade4 = #7E57C2/g' $PDIR/config
sed -i -e 's/shade5 = .*/shade5 = #9575CD/g' $PDIR/config
sed -i -e 's/shade6 = .*/shade6 = #B39DDB/g' $PDIR/config
sed -i -e 's/accent = .*/accent = #5E35B1/g' $PDIR/config
sed -i -e 's/bg = .*/bg = #141C21/g' $PDIR/config
$LAUNCH &

elif  [[ ${1} = "-orange" ]]; then
sed -i -e 's/shade1 = .*/shade1 = #F57C00/g' $PDIR/config
sed -i -e 's/shade2 = .*/shade2 = #FB8C00/g' $PDIR/config
sed -i -e 's/shade3 = .*/shade3 = #FF9800/g' $PDIR/config
sed -i -e 's/shade4 = .*/shade4 = #FFA726/g' $PDIR/config
sed -i -e 's/shade5 = .*/shade5 = #FFB74D/g' $PDIR/config
sed -i -e 's/shade6 = .*/shade6 = #FFCC80/g' $PDIR/config
sed -i -e 's/accent = .*/accent = #FB8C00/g' $PDIR/config
sed -i -e 's/bg = .*/bg = #141C21/g' $PDIR/config
$LAUNCH &

else
echo "Available options:
-deep-purple
-orang"
fi
