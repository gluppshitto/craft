#!/bin/bash

cd minecraft_server

sudo wget https://www.curseforge.com/minecraft/modpacks/life-in-the-village-3/download/4477240

unzip LITV3-Serverpack-1.10.zip
rm -rf LITV3-Serverpack-1.10.zip

cd LITV3-Serverpack-1.10
cp -a ./ ../
rm -rf LITV3-Serverpack-1.10

