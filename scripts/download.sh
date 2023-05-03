#!/bin/bash

cd minecraft_server

sudo wget https://www.curseforge.com/minecraft/modpacks/life-in-the-village-3/download/4477240

unzip LITV3-Serverpack-1.10.zip
rm -rf LITV3-Serverpack-1.10.zip

cp -a LITV3-Serverpack-1.10 ../
rm -rf LITV3-Serverpack-1.10

sudo curl -s -L https://github.com/gluppshitto/craft/raw/main/serverpack_config.tar.gz | sudo tar xvf - 
sudo curl -s -L https://github.com/gluppshitto/craft/raw/main/serverpack_world.tar.gz | sudo tar xvf - -C /world

sudo curl -s -L https://github.com/gluppshitto/craft/raw/main/serverpack_region_1.tar.gz| sudo tar xvf -C /world/region
sudo curl -s -L https://github.com/gluppshitto/craft/raw/main/serverpack_region_2.tar.gz| sudo tar xvf -C /world/region