#!/bin/bash

#Handle lid switch

sudo sed -i 's/^#HandleLidSwitch=.*/HandleLidSwitch=ignore/' /etc/systemd/logind.conf

sudo systemctl restart systemd-logind

#Samba Setup

sudo apt install samba

sudo mkdir /media/HDD

sudo chown $USER: /media/HDD

sudo sed -i 's/map to guest = bad user/map to guest = never/' /etc/samba/smb.conf

echo -e "\n[HDD]\n  path = /media/HDD\n  writeable = yes\n  public = no" | sudo tee -a /etc/samba/smb.conf > /dev/null

#Jellyfin Setup
curl https://repo.jellyfin.org/install-debuntu.sh | sudo bash

#Sonarr Setup

curl -o- https://raw.githubusercontent.com/Sonarr/Sonarr/develop/distribution/debian/install.sh | sudo bash


#Radarr Setup

curl -o servarr-install-script.sh https://raw.githubusercontent.com/Servarr/Wiki/master/servarr/servarr-install-script.sh
sudo bash servarr-install-script.sh

#QBittorrent Setup

sudo add-apt-repository ppa:qbittorrent-team/qbittorrent-stable
sudo apt install qbittorrent-nox
sudo adduser --system --group qbittorrent-nox
sudo adduser $USER qbittorrent-nox
sudo touch /etc/systemd/system/qbittorrent-nox.service
sudo tee /etc/systemd/system/qbittorrent-nox.service > /dev/null <<EOF
[Unit]
Description=qBittorrent Command Line Client
After=network.target

[Service]
#Do not change to "simple"
Type=forking
User=$USER           
UMask=007
ExecStart=/usr/bin/qbittorrent-nox -d --webui-port=8080
Restart=on-failure

[Install]
WantedBy=multi-user.target

EOF
sudo systemctl start qbittorrent-nox
sudo systemctl enable qbittorrent-nox


#Prowlarr Setup

sudo bash servarr-install-script.sh


