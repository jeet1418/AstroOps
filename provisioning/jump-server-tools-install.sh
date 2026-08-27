#!/bin/bash

set -e

echo "=========================================="
echo "Starting Jump Server Provisioning"
echo "=========================================="

# --------------------------------------------------
# 1. Update system
# --------------------------------------------------

echo "Updating system packages..."

apt-get update -y
apt-get upgrade -y

# --------------------------------------------------
# 2. Install basic packages
# --------------------------------------------------

echo "Installing basic packages..."

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
# 3. Install AWS CLI
# --------------------------------------------------

echo "Installing AWS CLI..."

ARCH=$(dpkg --print-architecture)

if [ "$ARCH" = "arm64" ]; then
    AWS_ARCH="aarch64"
elif [ "$ARCH" = "amd64" ]; then
    AWS_ARCH="x86_64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

curl "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" \
    -o /tmp/awscliv2.zip

unzip -q /tmp/awscliv2.zip -d /tmp

/tmp/aws/install

rm -rf /tmp/aws /tmp/awscliv2.zip


echo "AWS CLI installed:"
aws --version

# --------------------------------------------------
# 4. Install kubectl
# --------------------------------------------------

echo "Installing kubectl..."

KUBECTL_VERSION=$(curl -fsSL https://dl.k8s.io/release/stable.txt)

ARCH=$(dpkg --print-architecture)

if [ "$ARCH" = "arm64" ]; then
    KUBECTL_ARCH="arm64"
elif [ "$ARCH" = "amd64" ]; then
    KUBECTL_ARCH="amd64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

curl -fsSL \
    "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${KUBECTL_ARCH}/kubectl" \
    -o /tmp/kubectl

install -o root -g root -m 0755 \
    /tmp/kubectl \
    /usr/local/bin/kubectl

rm -f /tmp/kubectl

echo "kubectl installed:"
kubectl version --client

# --------------------------------------------------
# 5. Install Helm
# --------------------------------------------------

echo "Installing Helm..."

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash

echo "Helm installed:"
helm version

# --------------------------------------------------
# 6. Install eksctl
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
# 7. Verification
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