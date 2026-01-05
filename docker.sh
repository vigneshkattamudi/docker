#!/bin/bash
set -euxo pipefail

dnf -y install dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl daemon-reexec
systemctl enable --now docker

usermod -aG docker ec2-user

if lsblk /dev/nvme0n1p4; then
  growpart /dev/nvme0n1 4
  lvextend -L +20G /dev/RootVG/rootVol
  lvextend -L +10G /dev/RootVG/varVol
  xfs_growfs /
  xfs_growfs /var
fi

reboot