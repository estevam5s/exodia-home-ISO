#!/usr/bin/env bash

#####################################
#                                   #
#  @author      : CyberForge Team   #
#  @description : Customize Script  #
#  Copyright   : CyberForge OS      #
#                                   #
#####################################

## Script to perform several important tasks before `makeCyberForgeISO` create filesystem image. ##

set -e -u

## -------------------------------------------------------------- ##

## Fix Initrd Generation in Installed System ##
cat > "/etc/mkinitcpio.d/linux.preset" <<- _EOF_
	# mkinitcpio preset file for the 'linux' package
	ALL_kver="/boot/vmlinuz-linux"
	ALL_config="/etc/mkinitcpio.conf"
	PRESETS=('default' 'fallback')
	default_image="/boot/initramfs-linux.img"
	fallback_image="/boot/initramfs-linux-fallback.img"
	fallback_options="-S autodetect"    
_EOF_

## Enable Chaotic AUR ##
pacman-key --init
pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
pacman-key --lsign-key FBA220DFC880C036

## Set zsh as default shell for new user ##
sed -i -e 's#SHELL=.*#SHELL=/bin/zsh#g' /etc/default/useradd

## Create cyberforge user directories ##
mkdir -p /home/cyberforge/{Desktop,Documents,Downloads,Pictures,Videos,Tools,Wordlists,Scripts}

## Setup security tools directories ##
mkdir -p /opt/{wordlists,exploits,payloads,scripts,tools}
mkdir -p /usr/share/cyberforge/{scripts,themes,configs}

## Copy wordlists if available ##
if [ -f /usr/share/wordlists/rockyou.txt.gz ]; then
    gunzip /usr/share/wordlists/rockyou.txt.gz
    ln -sf /usr/share/wordlists/rockyou.txt /opt/wordlists/
fi

## Setup Metasploit database ##
systemctl enable postgresql
msfdb init || true

## Configure Tor ##
systemctl enable tor

## Setup wireshark permissions ##
groupadd -f wireshark
usermod -a -G wireshark cyberforge

## Configure custom scripts ##
chmod +x /usr/local/bin/cybersec-tools
chmod +x /usr/local/bin/pentest-setup

## Create desktop shortcuts ##
cat > "/home/cyberforge/Desktop/Security Tools.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Security Tools
Comment=CyberForge Security Tools
Exec=/usr/local/bin/cybersec-tools
Icon=security-medium
Terminal=true
Categories=Security;
EOF

cat > "/home/cyberforge/Desktop/Pentest Setup.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Pentest Setup
Comment=Configure Penetration Testing Environment
Exec=/usr/local/bin/pentest-setup
Icon=preferences-system
Terminal=true
Categories=Security;Settings;
EOF

## Set ownership ##
chown -R cyberforge:cyberforge /home/cyberforge
chmod +x /home/cyberforge/Desktop/*.desktop

## Update xdg-user-dirs ##
runuser -l cyberforge -c 'xdg-user-dirs-update'
xdg-user-dirs-update

## Configure i3 as default session ##
mkdir -p /home/cyberforge/.config/i3
mkdir -p /etc/skel/.config/i3

## Setup custom aliases ##
cat >> "/home/cyberforge/.zshrc" << EOF

# CyberForge Security Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias nmap-quick='nmap -T4 -F'
alias nmap-intense='nmap -T4 -A -v'
alias metasploit='msfconsole'
alias burp='burpsuite'
alias wireshark='sudo wireshark'
alias tools='cybersec-tools'
alias setup='pentest-setup'

# Network aliases
alias myip='curl ipinfo.io/ip'
alias ports='netstat -tulanp'
alias listening='ss -tuln'

# Security shortcuts
alias hashcat-gpu='hashcat -m 0 -a 0 -O'
alias john-zip='zip2john'
alias sqlmap-wizard='sqlmap --wizard'

EOF

## -------------------------------------------------------------- ##