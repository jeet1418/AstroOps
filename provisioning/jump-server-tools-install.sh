#!/bin/bash

set -e

echo "=========================================="
echo "Starting Jump Server Provisioning"
echo "=========================================="

# --------------------------------------------------
# 1. Update system
# --------------------------------------------------

apt-get update -y
apt-get upgrade -y

# Required packages
apt-get install -y \
    curl \
    wget \
    unzip \
    ca-certificates \
    gnupg \
    lsb-release \
    apt-transport-https \
    git

# --------------------------------------------------
# 2. Install AWS CLI v2
# --------------------------------------------------

echo "Installing AWS CLI..."

cd /tmp

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
    -o awscliv2.zip

unzip -q awscliv2.zip

./aws/install

rm -rf aws awscliv2.zip

echo "AWS CLI installed:"
aws --version

# --------------------------------------------------
# 3. Install kubectl
# --------------------------------------------------

echo "Installing kubectl..."

KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)

curl -LO \
    "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

rm kubectl

echo "kubectl installed:"
kubectl version --client

# --------------------------------------------------
# 4. Install Helm
# --------------------------------------------------

echo "Installing Helm..."

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    | bash

echo "Helm installed:"
helm version

# --------------------------------------------------
# 5. Install eksctl
# --------------------------------------------------

echo "Installing eksctl..."

ARCH=amd64

PLATFORM=$(uname -s)_${ARCH}

curl --silent --location \
    "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${PLATFORM}.tar.gz" \
    | tar xz -C /tmp

install -m 0755 /tmp/eksctl /usr/local/bin/eksctl

rm /tmp/eksctl

echo "eksctl installed:"
eksctl version

# --------------------------------------------------
# 6. Verification
# --------------------------------------------------

echo "=========================================="
echo "Installed Versions"
echo "=========================================="

aws --version
kubectl version --client
helm version
eksctl version

echo "=========================================="
echo "Jump Server Provisioning Completed"
echo "=========================================="