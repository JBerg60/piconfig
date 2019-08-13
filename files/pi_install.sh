#!/bin/bash

echo 'root:JBerg60' | chpasswd
echo 'pi:JBerg60' | chpasswd

echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
systemctl enable ssh
systemctl start ssh

echo "alias ls='ls -al --color=auto'" >> /home/pi/.profile
echo "alias ls='ls -al --color=auto'" >> /root/.profile

echo "www-data ALL=(ALL) NOPASSWD: /sbin/reboot" >> /etc/sudoers

echo 'MAILTO=""' | crontab -

apt-get -y update
apt-get -y upgrade

apt install -y ntp
systemctl enable ntp

timedatectl set-local-rtc true
timedatectl set-timezone Europe/Berlin

# install a webserver
apt-get install -y nginx

# use as shared network drive from windows
apt-get install -qq samba

# install git
apt-get install -y git

cd /tmp

git clone https://github.com/JBerg60/piconfig.git

# samba config
mv /etc/samba/smb.conf /etc/samba/smb.org
sudo cp piconfig/files/smb.conf /etc/samba/smb.conf
systemctl restart smbd.service
sudo echo -e "raspberry\nraspberry" | (smbpasswd -as pi)

#nginx config
rm /etc/nginx/sites-enabled/default
sudo cp piconfig/files/ipnginx /etc/nginx/sites-available
sudo ln -s /etc/nginx/sites-available/ipnginx /etc/nginx/sites-enabled/
sudo systemctl restart nginx

# install dotnet core
mkdir -p /usr/share/dotnet
wget https://download.visualstudio.microsoft.com/download/pr/11d6ec80-4d7f-4100-8a54-809ed30b203e/1c0267225b22437aca9fdfe04160d1d5/dotnet-sdk-3.0.100-preview7-012821-linux-arm.tar.gz
sudo tar zxf dotnet-sdk-3.0.100-preview7-012821-linux-arm.tar.gz -C /usr/share/dotnet
ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# prepare opt
sudo chgrp users /opt
sudo chmod 775 /opt


# cleanup
rm -fR *
rm -fR .*

sudo reboot

