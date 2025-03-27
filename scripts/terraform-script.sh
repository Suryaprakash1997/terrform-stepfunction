#!/bin/bash
sudo apt update
sudo apt upgrade -y
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
sudo apt install unzip curl collectd docker.io -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv3.zip"
unzip awscliv3.zip
sudo ./aws/install
echo "AWS CLI Version:" $(aws --version)
sudo usermod -aG docker ubuntu