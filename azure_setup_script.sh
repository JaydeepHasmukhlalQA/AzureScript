#!/bin/bash

sudo apt-get update
sudo apt install curl
sudo apt install python

sudo curl -sL https://aka.ms/InstallAzureCliDeb | sudo bash
sudo apt-get update && sudo apt-get install --only-upgrade -y azure-cli

az login

#Creating the resource named MainResourceGroup:
az group create --name MainResourceGroup --location uksouth

#Creating the virtual network within MainResourceGroup with a subnet:
az network vnet create --resource-group MainResourceGroup --name MainVirtualNetwork --address-prefixes 10.0.0.0/16 --subnet-name VirtualNetworkSubnet --subnet-prefix 10.0.0.0/24

#Creating Network Security Group with port rules:
az network nsg create --resource-group MainResourceGroup --name NetworkSecurityGroup

az network nsg rule create --resource-group MainResourceGroup --nsg-name NetworkSecurityGroup --name SSH --destination-port-ranges 22 --priority 100
az network nsg rule create --resource-group MainResourceGroup --nsg-name NetworkSecurityGroup --name HTTP --destination-port-ranges 80 -- priority 101
az network nsg rule create --resource-group MainResourceGroup --nsg-name NetworkSecurityGroup --name HTTPS --destination-port-ranges 443 -- priority 102
az network nsg rule create --resource-group MainResourceGroup --nsg-name NetworkSecurityGroup --name JenkFly --destination-port-ranges 8080 -- priority 103

#Creating public IP for Jenkins and Wildfly:
az network public-ip create --resource-group MainResourceGroup --name JenkinsIP --dns-name jenkinsvm
az network public-ip create --resource-group MainResourceGroup --name WildflyIP --dns-name wildflyvm

#Create NIC with NSG and public IP for Jenkins and Wildfly
az network nic create --resource-group MainResourceGroup --name JenkinsNetworkInterface --vnet-name MainVirtualNetwork --subnet VirtualNetworkSubnet --network-security-group NetworkSecurityGroup --public-ip-address JenkinsIP
az network nic create --resource-group MainResourceGroup --name WildFlyNetworkInterface --vnet-name MainVirtualNetwork --subnet VirtualNetworkSubnet --network-security-group NetworkSecurityGroup --public-ip-address WildflyIP

#Creating Jenkins and Wildfly VM:
az vm create --resource-group MainResourceGroup --name JenkinsVirtualMachine --image UbuntuLTS --size Standard_B1s --nic JenkinsNetworkInterface --admin-username jenkins --admin-password Password1234 --generate-ssh-keys
az vm create --resource-group MainResourceGroup --name WildflyVirtualMachine --image UbuntuLTS --size Standard_B1s --nic WildFlyNetworkInterface --admin-username wildfly --admin-password Password1234 --generate-ssh-keys
