FROM rust:1.89-bookworm

LABEL maintainer="Satyajit Behera"

ENV DEBIAN_FRONTEND=noninteractive

# ============================================================
# Common utilities + Java
# ============================================================

RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    bash \
    ca-certificates \
    gnupg \
    pkg-config \
    build-essential \
    openjdk-17-jre \
    && rm -rf /var/lib/apt/lists/*


# ============================================================
# Docker CLI + Buildx
# ============================================================

RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg \
        -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
        > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y \
        docker-ce-cli \
        docker-buildx-plugin \
    && rm -rf /var/lib/apt/lists/*


# ============================================================
# AWS CLI
# ============================================================

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
    -o "/tmp/awscliv2.zip" \
    && unzip /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf /tmp/aws /tmp/awscliv2.zip

# ============================================================
# yq
# ============================================================

RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
    -O /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq


# ============================================================
# Trivy
# ============================================================

RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
    | sh -s -- -b /usr/local/bin


# ============================================================
# SonarQube Scanner
# ============================================================

ARG SONAR_SCANNER_VERSION=7.2.0.4067

RUN wget -q \
    "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux-x64.zip" \
    -O /tmp/sonar-scanner.zip \
    && unzip /tmp/sonar-scanner.zip -d /opt \
    && mv "/opt/sonar-scanner-${SONAR_SCANNER_VERSION}-linux-x64" /opt/sonar-scanner \
    && ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner \
    && rm /tmp/sonar-scanner.zip


# ============================================================
# Verify installations
# ============================================================

RUN echo "===== Rust =====" && \
    rustc --version && \
    echo "===== Cargo =====" && \
    cargo --version && \
    echo "===== Java =====" && \
    java -version && \
    echo "===== Git =====" && \
    git --version && \
    echo "===== Docker =====" && \
    docker --version && \
    echo "===== Docker Buildx =====" && \
    docker buildx version && \
    echo "===== AWS CLI =====" && \
    aws --version && \
    echo "===== yq =====" && \
    yq --version && \
    echo "===== Trivy =====" && \
    trivy --version && \
    echo "===== Sonar Scanner =====" && \
    sonar-scanner --version


# ============================================================
# Workspace
# ============================================================

WORKDIR /workspace

CMD ["bash"]