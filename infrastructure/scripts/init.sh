#!/bin/bash

yum update -y

# install JAVA 17
wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm
rpm -ivh jdk-17_linux-x64_bin.rpmCopied!
java -version

[[ -d minecraft_server ]] || mkdir -p minecraft_server/world/region

cd minecraft_server

aws s3 cp s3://glupp-metrics-storage/LITV3-Serverpack-1.10.zip ./lts.zip
unzip lts.zip
cp -a lts/. ./

sudo curl -s -L https://github.com/gluppshitto/craft/raw/main/serverpack_config.tar.gz | sudo tar xvf - 
cp -a serverpack_config/. ./

sudo curl -s -L https://github.com/gluppshitto/craft/raw/main/serverpack_world.tar.gz | sudo tar xvf - 
cp -a serverpack_world/. world/

sudo curl -s -L https://github.com/gluppshitto/craft/raw/main/serverpack_region_1.tar.gz| sudo tar xvf -C /world/region
cp -a serverpack_region_1/. world/region/

sudo curl -s -L https://github.com/gluppshitto/craft/raw/main/serverpack_region_2.tar.gz| sudo tar xvf -C /world/region
cp -a serverpack_region_2/. world/region/

if [ ! -f "eula.txt" ]; then
  # you must agree to eula bla bla bla
  sudo sed -i s/eula=false/eula=true/g eula.txt
fi

# run server
java @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.18.2-40.2.0/unix_args.txt "$@"