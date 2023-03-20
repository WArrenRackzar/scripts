apt install -y python3-pip
yum install -y python3-pip
pip3 install --user apt-smart
echo "export PATH=\$(python3 -c 'import site; print(site.USER_BASE + \"/bin\")'):\$PATH" >> /etc/cloud/apt-smart
source /etc/cloud/apt-smart
apt-smart -x http://archive.ubuntu.com/ubuntu -a
