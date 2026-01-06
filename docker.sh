#!/bin/bash
set -euxo pipefail

# -----------------------------
# Docker installation
# -----------------------------
dnf -y install dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl daemon-reexec
systemctl enable --now docker
usermod -aG docker ec2-user

# -----------------------------
# Disk expansion (if present)
# -----------------------------
if lsblk /dev/nvme0n1p4 >/dev/null 2>&1; then
  growpart /dev/nvme0n1 4
  lvextend -L +20G /dev/RootVG/rootVol
  lvextend -L +10G /dev/RootVG/varVol
  xfs_growfs /
  xfs_growfs /var
fi

# -----------------------------
# eksctl installation
# -----------------------------
ARCH=amd64
PLATFORM="$(uname -s)_${ARCH}"

curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${PLATFORM}.tar.gz"
tar -xzf eksctl_${PLATFORM}.tar.gz -C /tmp
install -m 0755 /tmp/eksctl /usr/local/bin/eksctl
rm -f eksctl_${PLATFORM}.tar.gz /tmp/eksctl

# -----------------------------
# kubectl installation
# -----------------------------
curl -sLO https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.0/2025-05-01/bin/linux/amd64/kubectl
chmod +x kubectl
mv kubectl /usr/local/bin/kubectl

# -----------------------------
# Verification (client-only)
# -----------------------------
eksctl version
kubectl version --client

# -----------------------------
# kubectx / kubens
# -----------------------------
git clone https://github.com/ahmetb/kubectx /opt/kubectx
ln -sf /opt/kubectx/kubens /usr/local/bin/kubens
ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx

# -----------------------------
# Reboot to finalize
# -----------------------------
reboot


#========================================================================================================================

# set -euxo pipefail

# dnf -y install dnf-plugins-core
# dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
# dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# systemctl daemon-reexec
# systemctl enable --now docker
# usermod -aG docker ec2-user

# if lsblk /dev/nvme0n1p4; then
#   growpart /dev/nvme0n1 4
#   lvextend -L +20G /dev/RootVG/rootVol
#   lvextend -L +10G /dev/RootVG/varVol
#   xfs_growfs /
#   xfs_growfs /var
# fi

# ARCH=amd64
# PLATFORM=$(uname -s)_$ARCH
# curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
# tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
# install -m 0755 /tmp/eksctl /usr/local/bin && rm /tmp/eksctl

# curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.0/2025-05-01/bin/linux/amd64/kubectl
# chmod +x ./kubectl
# mv kubectl /usr/local/bin/kubectl

# eksctl version
# kubectl version

# git clone https://github.com/ahmetb/kubectx /opt/kubectx
# ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# reboot