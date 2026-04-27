#!/bin/bash

# Update packages
apt update -y

# Install Python + dependencies
apt install -y python3 python3-pip python3-venv software-properties-common

# Install Ansible
add-apt-repository --yes --update ppa:ansible/ansible
apt install -y ansible

# Install AWS SDK + Ansible AWS collection
pip3 install --upgrade boto3 botocore
ansible-galaxy collection install amazon.aws

# Configure AWS default region
mkdir -p /home/ubuntu/.aws
cat > /home/ubuntu/.aws/config <<EOF
[default]
region=us-east-1
output=json
EOF
chown -R ubuntu:ubuntu /home/ubuntu/.aws

# Create dynamic inventory config
mkdir -p /opt/ansible
cat > /opt/ansible/aws_ec2.yml <<EOF
plugin: amazon.aws.aws_ec2
regions:
  - us-east-1
filters:
  tag:Project: dpp
  instance-state-name: running
keyed_groups:
  - key: tags.Name
    prefix: ""
    separator: ""
hostnames:
  - private-ip-address
compose:
  ansible_host: private_ip_address
  ansible_user: "'ubuntu'"
  ansible_private_key_file: "'/opt/dpp.pem'"
EOF

chown -R ubuntu:ubuntu /opt/ansible

# Disable SSH host key checking
mkdir -p /etc/ansible
cat > /etc/ansible/ansible.cfg <<EOF
[defaults]
host_key_checking = False
deprecation_warnings = False
EOF

echo "✅ Ansible setup completed successfully" > /tmp/ansible_setup.log