#!/bin/bash

set -e

echo "=========================================="
echo "Starting Jenkins Server Provisioning"
echo "=========================================="


# --------------------------------------------------
# 1. Update system
# --------------------------------------------------

apt update -y


# --------------------------------------------------
# 2. Install basic packages
# --------------------------------------------------

apt install -y \
    ca-certificates \
    curl \
    wget \
    gnupg \
    unzip \
    lsb-release


# --------------------------------------------------
# 3. Install Java 17
# --------------------------------------------------

apt install -y openjdk-17-jdk

java --version


# --------------------------------------------------
# 4. Install Jenkins
# --------------------------------------------------

mkdir -p /etc/apt/keyrings

wget -O /etc/apt/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" \
    > /etc/apt/sources.list.d/jenkins.list

apt update -y

apt install -y jenkins

systemctl enable jenkins
systemctl start jenkins


# --------------------------------------------------
# 5. Install Terraform
# --------------------------------------------------

wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor \
    -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) \
signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com \
$(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" \
    > /etc/apt/sources.list.d/hashicorp.list

apt update -y

apt install -y terraform


# --------------------------------------------------
# 6. Install Docker
# --------------------------------------------------

apt remove -y \
    docker.io \
    docker-compose \
    docker-compose-v2 \
    docker-doc \
    docker-buildx \
    podman-docker \
    containerd \
    runc || true

install -m 0755 -d /etc/apt/keyrings

curl -fsSL \
    https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) \
signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") \
stable" \
    > /etc/apt/sources.list.d/docker.list

apt update -y

apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

systemctl enable docker
systemctl start docker


# --------------------------------------------------
# 7. Add users to Docker group
# --------------------------------------------------

usermod -aG docker jenkins
usermod -aG docker ubuntu


# --------------------------------------------------
# 8. Install AWS CLI
# --------------------------------------------------

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


# --------------------------------------------------
# 9. Install Trivy
# --------------------------------------------------

wget -qO - \
    https://aquasecurity.github.io/trivy-repo/deb/public.key | \
    gpg --dearmor | \
    tee /usr/share/keyrings/trivy.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] \
https://aquasecurity.github.io/trivy-repo/deb generic main" \
    > /etc/apt/sources.list.d/trivy.list

apt update -y

apt install -y trivy


# --------------------------------------------------
# 10. Start SonarQube
# --------------------------------------------------

docker volume create sonarqube_data
docker volume create sonarqube_logs
docker volume create sonarqube_extensions

docker run -d \
    --name sonarqube \
    --restart unless-stopped \
    -p 9000:9000 \
    -v sonarqube_data:/opt/sonarqube/data \
    -v sonarqube_logs:/opt/sonarqube/logs \
    -v sonarqube_extensions:/opt/sonarqube/extensions \
    sonarqube:lts-community


# --------------------------------------------------
# 11. Restart Jenkins
# --------------------------------------------------

systemctl restart jenkins


# --------------------------------------------------
# 12. Verification
# --------------------------------------------------


java --version
terraform version
docker --version
aws --version
trivy --version

systemctl is-active jenkins
systemctl is-active docker

docker ps

echo "======================================"
echo "Jenkins Server Provisioning completed"
echo "======================================"
