#!/bin/bash

yum update -y
sudo yum -y install java-17-openjdk
sudo yum -y install unzip

[[ -d minecraft_server ]] || mkdir -p minecraft_server/world/region

# download here
sudo chmod +x scripts/download.sh
scripts/download.sh

if [ ! -f "eula.txt" ]; then
  # you must agree to eula bla bla bla
  sudo sed -i s/eula=false/eula=true/g eula.txt
fi

# run server
java @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.18.2-40.2.0/unix_args.txt "$@"