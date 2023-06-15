#!/bin/bash

# Detect the Linux distribution
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    distro=$ID
elif [[ -f /etc/debian_version ]]; then
    distro="debian"
elif [[ -f /etc/centos-release ]]; then
    distro="centos"
else
    echo "Unsupported distribution. Exiting..."
    exit 1
fi

# Install python3-pip based on the distribution
if [[ $distro == "ubuntu" || $distro == "debian" ]]; then
    apt-get update
    apt-get install -y python3-pip
elif [[ $distro == "centos" ]]; then
    yum update
    yum install -y python3-pip
else
    echo "Unsupported distribution. Exiting..."
    exit 1
fi

# Install apt-smart
pip3 install --user apt-smart

# Configure apt-smart (for Ubuntu and Debian)
if [[ $distro == "ubuntu" || $distro == "debian" ]]; then
    echo "export PATH=\$(python3 -c 'import site; print(site.USER_BASE + \"/bin\")'):\$PATH" >> /etc/cloud/apt-smart
    source /etc/cloud/apt-smart
    apt-smart -x http://archive.ubuntu.com/ubuntu -a
fi

# Run cloud-init commands
if [[ $distro == "ubuntu" || $distro == "debian" ]]; then
    apt update
    apt install qemu-guest-agent -y

    # Check Ubuntu version and install specific kernel
    if [[ $distro == "ubuntu" ]]; then
        case $VERSION_ID in
            "18.04")
                apt -y install linux-image-5.4.0-99-generic
                ;;
            "20.04")
                apt -y install linux-image-5.15.0-73-generic
                ;;
            "22.04")
                apt -y install linux-image-5.19.0-42-generic
                ;;
            *)
                echo "Unsupported Ubuntu version: $VERSION_ID"
                exit 1
                ;;
        esac
    elif [[ $distro == "debian" ]]; then
        case $VERSION_ID in
            "10")
                apt -y install linux-image-5.10.0-0.deb10.23-amd64
                ;;
            "11")
                apt -y install linux-image-6.1.0-0.deb11.7-amd64
                ;;
            *)
                echo "Unsupported Debian version: $VERSION_ID"
                exit 1
                ;;
        esac
    fi

elif [[ $distro == "centos" ]]; then
    yum update
    yum install qemu-guest-agent -y

    # Check CentOS version and install specific kernel
    if [[ $distro == "centos" ]]; then
        case $VERSION_ID in
            7*)
                rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
                rpm -Uvh https://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
                yum --enablerepo=elrepo-kernel install kernel-ml
                grub2-set-default 0
                ;;
            8*)
                dnf install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm
                dnf --enablerepo=elrepo-kernel install kernel-ml
                grub2-set-default 0
                ;;
            *)
                echo "Unsupported CentOS version: $VERSION_ID"
                exit 1
                ;;
        esac
    fi
fi

# Backup the original sshd_config file
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Use awk to modify the sshd_config file
sudo awk '{
  if ($1 == "#PermitRootLogin" && $2 == "prohibit-password") {
    print "PermitRootLogin yes";
  } else if ($1 == "#PasswordAuthentication" && $2 == "yes") {
    print "PasswordAuthentication yes";
  } else {
    print $0;
  }
}' /etc/ssh/sshd_config.bak | sudo tee /etc/ssh/sshd_config > /dev/null

# Restart the SSH service
if [[ $distro == "ubuntu" || $distro == "debian" || $distro == "centos" ]]; then
    if command -v service >/dev/null; then
        sudo service ssh restart
    elif command -v systemctl >/dev/null; then
        sudo systemctl restart sshd
    else
        echo "Unable to restart SSH service. Please restart it manually."
    fi
else
    echo "Unsupported distribution. SSH service restart may be required."
fi
