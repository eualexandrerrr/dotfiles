#!/usr/bin/env bash

lb=$(xgetres background | tr -d ";")      #  Background color for notifications with low urgency
nb=$(xgetres pink | tr -d ";")      #  Background color for notifications with normal urgency
cb=$(xgetres background | tr -d ";")      #  Background color for notifications with critical urgency

lf=$(xgetres white | tr -d ";")           #  Foreground color for notifications with low urgency
nf=$(xgetres white | tr -d ";")           #  Foreground color for notifications with normal urgency
cf=$(xgetres white | tr -d ";")           #  Foreground color for notifications with ciritical urgency

lh=$(xgetres green | tr -d ";")           #  Highlight color for notifications with low urgency
nh=$(xgetres green | tr -d ";")           #  Highlight color for notifications with normal urgency
ch=$(xgetres green | tr -d ";")           #  Highlight color for notifications with ciritical urgency

cfr=$(xgetres red | tr -d ";")            #  Frame color for notifications with critical urgency
nfr=$(xgetres background | tr -d ";")         #  Frame color for notifications with normal urgency
lfr=$(xgetres yellow | tr -d ";")         #  Frame color for notifications with low urgency

dunst -config $HOME/.config/dunst/dunstrc \
  -lb $lb \
  -nb $nb \
  -cb $cb \
  -lf $lf \
  -nf $nf \
  -cf $cf \
  -lh $lh \
  -nh $nh \
  -ch $ch \
  -cfr $cfr \
  -nfr $nfr \
  -lfr $lfr
