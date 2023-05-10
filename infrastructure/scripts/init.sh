#!/bin/bash

sudo yum update -y
sudo yum -y install jq

[[ -d minecraft_server ]] || mkdir -p minecraft_server/world/region

cd minecraft_server

# install JAVA 17
sudo wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm 
sudo rpm -ivh jdk-17_linux-x64_bin.rpm
java -version

# install forge and serverpack
sudo aws s3 cp s3://glupp-metrics-storage/LITV3-Serverpack-1.10.zip ./lts.zip
sudo unzip lts.zip
sudo cp -a LITV3-Serverpack-1.10/. ./

# grab config files
sudo wget https://github.com/gluppshitto/craft/raw/main/assets/serverpack_config.tar.gz
sudo tar xvf serverpack_config.tar.gz 
sudo cp -a serverpack_config/. ./

# grab world files
if [[ $(aws s3 ls s3://glupp-metrics-storage/world/) ]]; then
    aws s3 cp s3://glupp-metrics-storage/world/ world --recursive
else
    sudo wget https://github.com/gluppshitto/craft/raw/main/assets/serverpack_world.tar.gz 
    sudo tar xvf serverpack_world.tar.gz
    sudo cp -a serverpack_world/. world/

    sudo wget https://github.com/gluppshitto/craft/raw/main/assets/serverpack_region_1.tar.gz 
    sudo tar xvf serverpack_region_1.tar.gz
    cp -a serverpack_region_1/region/. world/region/

    sudo wget https://github.com/gluppshitto/craft/raw/main/assets/serverpack_region_2.tar.gz 
    sudo tar xvf serverpack_region_2.tar.gz
    cp -a serverpack_region_2/region/. world/region/
fi

# Setup crons
sudo -i

# Hourly backup cron

touch ../etc/cron.d/backup_hourly
echo "*/10 * * * * root /minecraft_server/backup.sh" > ../etc/cron.d/backup_hourly

touch backup.sh
echo "aws s3 cp /minecraft_server/world/ s3://glupp-metrics-storage/world/ --recursive" > backup.sh

# Online checker cron

touch ../etc/cron.d/check_online
echo "*/30 * * * * root /minecraft_server/is_online.sh" > ../etc/cron.d/check_online

touch is_online.sh
touch online_status
echo "curl https://api.mcsrvstat.us/2/deanfogarty.link:443 | jq -r .players.online >> /minecraft_server/online_status" > is_online.sh

# Stop if empty cron

touch ../etc/cron.d/uptime_stopcheck
echo "*/15 * * * * root /minecraft_server/uptime_stopcheck.sh" > ../etc/cron.d/uptime_stopcheck

touch uptime_stopcheck.sh
echo "tail -3 online >> online_last && if [ $(sed '3!d' online_last ) = 0 ] && [ $(sed '2!d' online_last ) = 0 ] && [ $(sed '3!d' online_last ) = 0 ]; then aws autoscaling set-desired-capacity --auto-scaling-group-name server --desired-capacity 0; fi && rm -rf online_last" > uptime_stopcheck.sh

# EULA 

sudo sed -i s/eula=false/eula=true/g eula.txt

sudo sed -i s/-Xmx6G/-Xmx12G/g user_jvm_args.txt
sudo sed -i s/-Xmn128M/-Xmn612M/g user_jvm_args.txt

# run server
until sudo java @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.18.2-40.2.0/unix_args.txt "$@"; do
  sudo aws s3 cp world s3://glupp-metrics-storage/world/ --recursive
  sudo shutdown -h now
done
