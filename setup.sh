#!/bin/bash

# Function to check the status of the last command and exit if it failed
check_status() {
  if [ $? -ne 0 ]; then
    echo "Error: $1 failed. Exiting."
    exit 1
  fi
}

# Handle Lid Switch
echo "Modifying HandleLidSwitch to ignore in logind.conf..."
sudo sed -i 's/^#HandleLidSwitch=.*/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
check_status "Handle Lid Switch configuration"
sudo systemctl restart systemd-logind
check_status "Restarting systemd-logind"

# Samba Setup
echo "Installing Samba..."
sudo apt install -y samba
check_status "Samba installation"

echo "Creating /media/HDD directory..."
sudo mkdir -p /media/HDD
check_status "Creating directory /media/HDD"

echo "Changing ownership of /media/HDD to $USER..."
sudo chown $USER: /media/HDD
check_status "Changing ownership of /media/HDD"

echo "Modifying Samba configuration..."
sudo sed -i 's/map to guest = bad user/map to guest = never/' /etc/samba/smb.conf
check_status "Samba configuration update"
echo -e "\n[HDD]\n  path = /media/HDD\n  writeable = yes\n  public = no" | sudo tee -a /etc/samba/smb.conf > /dev/null
check_status "Adding /media/HDD share to Samba config"

# Jellyfin Setup
echo "Installing Jellyfin..."
curl -s https://repo.jellyfin.org/install-debuntu.sh | sudo bash
check_status "Jellyfin installation"

# Sonarr Setup
echo "Installing Sonarr..."
curl -s -o- https://raw.githubusercontent.com/Sonarr/Sonarr/develop/distribution/debian/install.sh | sudo bash
check_status "Sonarr installation"

# Radarr Setup
echo "Downloading Servarr installation script..."
curl -s -o servarr-install-script.sh https://raw.githubusercontent.com/Servarr/Wiki/master/servarr/servarr-install-script.sh
check_status "Downloading Servarr install script"
echo "Running Servarr installation script for Radarr..."
sudo bash servarr-install-script.sh
check_status "Radarr installation"

# QBittorrent Setup
echo "Adding QBittorrent PPA..."
sudo add-apt-repository -y ppa:qbittorrent-team/qbittorrent-stable
check_status "Adding QBittorrent PPA"
echo "Installing qbittorrent-nox..."
sudo apt install -y qbittorrent-nox
check_status "QBittorrent-nox installation"

echo "Creating qbittorrent-nox system user..."
sudo adduser --system --group qbittorrent-nox
check_status "Creating qbittorrent-nox system user"
sudo adduser $USER qbittorrent-nox
check_status "Adding $USER to qbittorrent-nox group"

echo "Creating systemd service for qbittorrent-nox..."
sudo tee /etc/systemd/system/qbittorrent-nox.service > /dev/null <<EOF
[Unit]
Description=qBittorrent Command Line Client
After=network.target

[Service]
Type=forking
User=$USER
UMask=007
ExecStart=/usr/bin/qbittorrent-nox -d --webui-port=8080
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
check_status "Creating qbittorrent-nox service file"

echo "Starting qbittorrent-nox service..."
sudo systemctl start qbittorrent-nox
check_status "Starting qbittorrent-nox service"
sudo systemctl enable qbittorrent-nox
check_status "Enabling qbittorrent-nox service"

# Prowlarr Setup
echo "Running Servarr installation script for Prowlarr..."
sudo bash servarr-install-script.sh
check_status "Prowlarr installation"

# Cleanup
echo "Cleaning up temporary files..."
rm servarr-install-script.sh
check_status "Cleaning up installation script"

echo "All tasks completed successfully!"