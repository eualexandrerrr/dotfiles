#!/usr/bin/env bash

HOSTNAME=$(cat /etc/hostname)

# systemd Auto Login
sudo rm -rf /etc/systemd/system/getty@tty1.service.d/override.conf
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
echo "[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USER --noclear %I $TERM" | sudo tee -a /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null

# Xorg
sudo mkdir -p /etc/X11/xorg.conf.d &> /dev/null

echo 'Section "InputClass"
    Identifier "evdev keyboard catchall"
    MatchIsKeyboard "on"
    MatchDevicePath "/dev/input/event*"
    Driver "evdev"
    Option "XkbLayout" "br"
    Option "XkbVariant" "abnt2"
EndSection' | sudo tee /etc/X11/xorg.conf.d/10.evdev.conf &> /dev/null

echo 'Section "OutputClass"
    Identifier "amd"
    MatchDriver "amdgpu"
    Driver "modesetting"
EndSection

Section "OutputClass"
    Identifier "nvidia"
    MatchDriver "nvidia-drm"
    Driver "nvidia"
    Option "AllowEmptyInitialConfiguration"
    Option "PrimaryGPU" "yes"
    ModulePath "/usr/lib/nvidia/xorg"
    ModulePath "/usr/lib/xorg/modules"
EndSection' | sudo tee /etc/X11/xorg.conf.d/20-nvidia-drm-outputclass.conf &> /dev/null

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
