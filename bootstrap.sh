#!/bin/bash

echo "bootstrapping the linux env"
echo "installing dotnet SDK"
sudo apt-get update && sudo apt-get install -y dotnet-sdk-8.0
wget https://www.nuget.org/api/v2/package/python/3.13.1
mv 3.13.1 3.13.1.nupkg
