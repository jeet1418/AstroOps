FROM ruby:3.4-bookworm

LABEL maintainer="Satyajit Behera"

ARG TARGETARCH

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
    build-essential \
    && rm -rf /var/lib/apt/lists/*


# ============================================================
# RubyGems + Bundler
# ============================================================

RUN gem update --system && \
    gem install bundler


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

RUN if [ "$TARGETARCH" = "amd64" ]; then \
        AWS_ARCH="x86_64"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        AWS_ARCH="aarch64"; \
    else \
        echo "Unsupported architecture: $TARGETARCH"; \
        exit 1; \
    fi && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" \
        -o /tmp/awscliv2.zip \
    && unzip -q /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf /tmp/aws /tmp/awscliv2.zip

# ============================================================
# yq
# ============================================================

RUN if [ "$TARGETARCH" = "amd64" ]; then \
        YQ_ARCH="amd64"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        YQ_ARCH="arm64"; \
    else \
        echo "Unsupported architecture: $TARGETARCH"; \
        exit 1; \
    fi && \
    wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${YQ_ARCH} \
        -O /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq



# ============================================================
# Trivy
# ============================================================

RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
    | sh -s -- -b /usr/local/bin

# ============================================================
# Verify installations
# ============================================================

RUN echo "===== Ruby =====" && \
    ruby --version && \
    echo "===== RubyGems =====" && \
    gem --version && \
    echo "===== Bundler =====" && \
    bundler --version && \
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
    trivy --version

# ============================================================
# Workspace
# ============================================================

WORKDIR /workspace

CMD ["bash"]