#!/usr/bin/env bash

# systemd Auto Login
sudo rm -rf /etc/systemd/system/getty@tty1.service.d/override.conf
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
echo "[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USER --noclear %I $TERM" | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf &> /dev/null

# Xorg
sudo mkdir -p /etc/X11/xorg.conf.d &> /dev/null
sudo rm -rf /etc/X11/xorg.conf.d/{10.evdev.conf,30-touchpad.conf,40-mouse-acceleration.conf}

echo 'Section "InputClass"
    Identifier "evdev keyboard catchall"
    MatchIsKeyboard "on"
    MatchDevicePath "/dev/input/event*"
    Driver "evdev"
    Option "XkbLayout" "br"
    Option "XkbVariant" "abnt2"
EndSection' | sudo tee /etc/X11/xorg.conf.d/10.evdev.conf &> /dev/null

echo 'Section "InputClass"
    Identifier "touchpad"
    Driver "libinput"
    MatchIsTouchpad "on"
    Option "Tapping" "on"
    Option "TappingButtonMap" "lmr"
    Option "NaturalScrolling" "true"
EndSection' | sudo tee /etc/X11/xorg.conf.d/30-touchpad.conf &> /dev/null

echo 'Section "InputClass"
	Identifier "My Mouse"
	MatchIsPointer "yes"
	Option "AccelerationNumerator" "2"
	Option "AccelerationDenominator" "1"
	Option "AccelerationThreshold" "4"
EndSection' | sudo tee /etc/X11/xorg.conf.d/40-mouse-acceleration.conf &> /dev/null
