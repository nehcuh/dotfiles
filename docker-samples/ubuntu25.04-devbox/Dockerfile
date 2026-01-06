# Minimal Ubuntu 25.04 development environment
# Good taste: simple, focused, no bullshit
FROM ubuntu@sha256:95a416ad2446813278ec13b7efdeb551190c94e12028707dd7525632d3cec0d1

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=devuser
ARG USER_UID=1000
ARG USER_GID=1000

# Environment - define once, use everywhere
ENV TZ=Asia/Shanghai \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Install minimal base packages
# Good taste: one RUN layer, clean up in same command
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      sudo bash zsh ca-certificates curl wget gnupg git \
      build-essential cmake pkg-config \
      locales tzdata unzip zip \
      libssl-dev libreadline-dev zlib1g-dev \
      libbz2-dev libsqlite3-dev libffi-dev \
      openssh-server && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    rm -rf /var/lib/apt/lists/*

# Create user - handle UID/GID conflicts in Ubuntu base image
RUN if getent passwd ${USER_UID}; then \
      EXISTING_USER=$(getent passwd ${USER_UID} | cut -d: -f1) && \
      usermod -l ${USERNAME} -d /home/${USERNAME} -m $EXISTING_USER && \
      groupmod -n ${USERNAME} $EXISTING_USER 2>/dev/null || true; \
    else \
      (groupadd --gid ${USER_GID} ${USERNAME} 2>/dev/null || true) && \
      useradd -ms /usr/bin/zsh --uid ${USER_UID} --gid ${USER_GID} ${USERNAME}; \
    fi && \
    usermod -aG sudo ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME}

# Switch to user early - good taste: principle of least privilege
USER ${USERNAME}
ENV HOME=/home/${USERNAME}

# Install Starship prompt (with fallback for network issues)
RUN mkdir -p ${HOME}/.local/bin && \
    (curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir=${HOME}/.local/bin -y || \
    echo "# Starship install failed, using basic prompt")

# Copy dotfiles - only zsh configs needed for base image
COPY --chown=${USERNAME}:${USERNAME} dotfiles /home/${USERNAME}/.dotfiles
RUN cp /home/${USERNAME}/.dotfiles/stow-packs/zsh/.zshrc ${HOME}/.zshrc && \
    cp /home/${USERNAME}/.dotfiles/stow-packs/zsh/.zshenv ${HOME}/.zshenv && \
    cp /home/${USERNAME}/.dotfiles/stow-packs/zsh/.zprofile ${HOME}/.zprofile

# Skip dev environment setup for Apple Container test
# Full setup would install Rust, Python, Node.js via dotfiles scripts

# Install Go via apt (simple and reproducible)
USER root
RUN apt-get update && \
    apt-get install -y golang-go && \
    rm -rf /var/lib/apt/lists/* && \
    echo 'export GOPATH=$HOME/go' >> /home/${USERNAME}/.zshrc.local && \
    echo 'export PATH=$PATH:$GOPATH/bin' >> /home/${USERNAME}/.zshrc.local
USER ${USERNAME}

# Create workspace
RUN mkdir -p ${HOME}/workspace ${HOME}/Projects

# Setup SSH server (optional, disabled by default)
# Good taste: make it opt-in, not always-on
USER root
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set working directory and default shell
WORKDIR /home/${USERNAME}/workspace
USER ${USERNAME}
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
