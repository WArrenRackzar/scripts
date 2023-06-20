#!/bin/bash

# Prompt for VM ID
read -p "Enter the VM ID: " VM_ID

# Select Ubuntu version
echo "Select the Ubuntu version:"
echo "1. Ubuntu 18.04"
echo "2. Ubuntu 20.04"
echo "3. Ubuntu 22.04"
echo "4. Ubuntu 23.04"
read -p "Enter your choice (1, 2, 3, or 4): " UBUNTU_OPTION

case $UBUNTU_OPTION in
    1)
        UBUNTU_VERSION="Ubuntu 18.04"
        UBUNTU_IMAGE_URL="https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img"
        ;;
    2)
        UBUNTU_VERSION="Ubuntu 20.04"
        UBUNTU_IMAGE_URL="https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
        ;;
    3)
        UBUNTU_VERSION="Ubuntu 22.04"
        UBUNTU_IMAGE_URL="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
        ;;
    4)
        UBUNTU_VERSION="Ubuntu 23.04"
        UBUNTU_IMAGE_URL="https://cloud-images.ubuntu.com/lunar/current/lunar-server-cloudimg-amd64.img"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Define other desired parameters
MEMORY=2048
NETWORK_ADAPTER="virtio"
BRIDGE_NAME="vmbr0"
SCSI_CONTROLLER="virtio-scsi-pci"
CPU_CORES=2

# Create the new virtual machine
qm create $VM_ID --memory $MEMORY --cores $CPU_CORES --net0 $NETWORK_ADAPTER,bridge=$BRIDGE_NAME --scsihw $SCSI_CONTROLLER

# Add serial port
qm set $VM_ID --serial0 socket

# Create directory
mkdir -p /templates-temp/

# Check if the image file already exists
IMAGE_FILE="/templates-temp/ubuntu-server-cloudimg-$UBUNTU_OPTION-amd64.img"
if [ -f "$IMAGE_FILE" ]; then
    echo "Image file already exists. Skipping download."
else
    # Download Ubuntu template
    wget -O $IMAGE_FILE $UBUNTU_IMAGE_URL
fi

# Prompt for storage name
read -p "Enter the storage name: " STORAGE_NAME

# Import the converted file
qm importdisk $VM_ID $IMAGE_FILE $STORAGE_NAME

# Set the imported disk as the primary disk
qm set $VM_ID --virtio0 /mnt/pve/$STORAGE_NAME/images/$VM_ID/vm-$VM_ID-disk-0.raw

# Add cloud-init drive using SATA bus
qm set $VM_ID --sata1 $STORAGE_NAME:cloudinit

# Set the OS type to Linux
qm set $VM_ID --ostype l26

# Set the boot order to scsi0
qm set $VM_ID --boot c --bootdisk virtio0

# Convert VM into a template
TEMPLATE_NAME="$UBUNTU_VERSION Template"
qm template $VM_ID $TEMPLATE_NAME
