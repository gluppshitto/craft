#!/bin/bash

yum update -y

[[ -d minecraft_server ]] || mkdir -p minecraft_server/world/region

cd minecraft_server

# install JAVA 17
sudo wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm 
sudo rpm -ivh jdk-17_linux-x64_bin.rpm
java -version

sudo aws s3 cp s3://glupp-metrics-storage/LITV3-Serverpack-1.10.zip ./lts.zip
sudo unzip lts.zip
sudo cp -a LITV3-Serverpack-1.10/. ./

sudo wget https://github.com/gluppshitto/craft/raw/main/assets/serverpack_config.tar.gz
sudo tar xvf serverpack_config.tar.gz 
sudo cp -a serverpack_config/. ./

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

sudo -i
touch ../etc/cron.d/backup_hourly
echo "0 * * * * root aws s3 cp world s3://glupp-metrics-storage/world/ --recursive" > ../etc/cron.d/backup_hourly

sudo sed -i s/eula=false/eula=true/g eula.txt

# run server
until sudo java @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.18.2-40.2.0/unix_args.txt "$@"; do
  shutdown -h now
done