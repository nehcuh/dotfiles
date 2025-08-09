# Use Ubuntu 25.04 with pinned digest for reproducibility
FROM ubuntu@sha256:95a416ad2446813278ec13b7efdeb551190c94e12028707dd7525632d3cec0d1

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=huchen
ARG USER_UID=1000
ARG USER_GID=1000
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY

ENV TZ=Asia/Shanghai
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Build-time proxy passthrough
ENV http_proxy=${HTTP_PROXY}
ENV https_proxy=${HTTPS_PROXY}
ENV no_proxy=${NO_PROXY}

# Install minimal prerequisites including Java and SSH
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      sudo bash zsh ca-certificates curl wget gnupg git \
      build-essential cmake pkg-config \
      locales tzdata unzip zip \
      libssl-dev libreadline-dev zlib1g-dev libbz2-dev libsqlite3-dev \
      libffi-dev liblzma-dev tk-dev \
      openjdk-21-jdk maven gradle \
      openssh-server && \
    rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME for OpenJDK 21
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH=${JAVA_HOME}/bin:${PATH}

# Generate locales to fix locale warnings
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

# Create user huchen, set password to 123456, default shell zsh, and passwordless sudo
RUN if getent passwd ${USER_UID}; then \
      EXISTING_USER=$(getent passwd ${USER_UID} | cut -d: -f1) && \
      usermod -l ${USERNAME} -d /home/${USERNAME} -m $EXISTING_USER && \
      groupmod -n ${USERNAME} $EXISTING_USER 2>/dev/null || true; \
    else \
      (getent group ${USER_GID} || groupadd --gid ${USER_GID} ${USERNAME}) && \
      useradd -ms /usr/bin/zsh --uid ${USER_UID} --gid ${USER_GID} ${USERNAME}; \
    fi && \
    usermod -aG sudo ${USERNAME} && \
    chsh -s /usr/bin/zsh ${USERNAME} && \
    echo "${USERNAME}:123456" | chpasswd && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME}

# Switch to user
USER ${USERNAME}
ENV HOME=/home/${USERNAME}

# Copy dotfiles and apply only zsh configs
COPY dotfiles /home/${USERNAME}/.dotfiles
RUN sudo chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.dotfiles && \
    cp /home/${USERNAME}/.dotfiles/stow-packs/zsh/.zshrc /home/${USERNAME}/.zshrc && \
    cp /home/${USERNAME}/.dotfiles/stow-packs/zsh/.zshenv /home/${USERNAME}/.zshenv && \
    cp /home/${USERNAME}/.dotfiles/stow-packs/zsh/.zprofile /home/${USERNAME}/.zprofile

# Install Starship to satisfy .zshrc (locally to avoid sudo)
RUN mkdir -p ${HOME}/.local/bin && \
    curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir=${HOME}/.local/bin -y

# Ensure nvm sourcing fallback in .zshrc and set default to LTS
RUN echo '' >> ${HOME}/.zshrc && \
    echo '# NVM fallback for Docker environment' >> ${HOME}/.zshrc && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ${HOME}/.zshrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"' >> ${HOME}/.zshrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"' >> ${HOME}/.zshrc

# Source setup script and install Rust
RUN /bin/bash -c "export INTERACTIVE=false && \
    source /home/${USERNAME}/.dotfiles/scripts/setup-dev-environment.sh && \
    install_rust"

# Install Python with pyenv
RUN /bin/bash -c "export INTERACTIVE=false && \
    source /home/${USERNAME}/.dotfiles/scripts/setup-dev-environment.sh && \
    install_python"

# Install Go (using apt for simplicity in Docker)
RUN sudo apt-get update && sudo apt-get install -y golang-go && \
    echo '' >> ${HOME}/.zshrc && \
    echo '# Go configuration' >> ${HOME}/.zshrc && \
    echo 'export GOPATH=$HOME/go' >> ${HOME}/.zshrc && \
    echo 'export PATH=$PATH:$GOPATH/bin' >> ${HOME}/.zshrc && \
    export GOPATH=$HOME/go && \
    export PATH=$PATH:$GOPATH/bin

# Install Node.js with NVM and set default to LTS
RUN /bin/bash -c "export INTERACTIVE=false && \
    source /home/${USERNAME}/.dotfiles/scripts/setup-dev-environment.sh && \
    install_nodejs && \
    source ~/.nvm/nvm.sh && nvm alias default lts/*"

# Create workspace
RUN mkdir -p ${HOME}/workspace

# Back to root to install entrypoint
USER root
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set ENTRYPOINT to the provided zsh based entrypoint
WORKDIR /home/${USERNAME}/workspace
USER ${USERNAME}
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
