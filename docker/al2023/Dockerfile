#最新のdocker-composeを取得
FROM amazonlinux:2023 AS collector
ARG DOCKER_COMPOSE_BASEURL=https://github.com/docker/compose/releases
RUN dnf install -y util-linux && \
    LATEST=$(curl -Ls -o /dev/null -w %{url_effective} ${DOCKER_COMPOSE_BASEURL}/latest | rev | cut -d/ -f1 | rev) && \
    curl -L "${DOCKER_COMPOSE_BASEURL}/download/${LATEST}/docker-compose-$(uname -s)-$(uname -m)" -o ./docker-compose && \
    chmod +x ./docker-compose && dnf clean all

#本編
FROM amazonlinux:2023
ARG USERNAME
ARG GROUPNAME
ARG UID
ARG GID
ARG PYTHON_VERSION
ARG HOST_DOCKER_GID
ARG NODE_VERSION
ENV SHELL=/bin/bash
COPY ./docker/al2023/wsl.conf /etc
COPY ./docker/al2023/gcloud.repo /etc/yum.repos.d
RUN dnf -y upgrade --releasever=latest && \
  dnf install -y --enablerepo=google-cloud-cli unzip tar gcc zlib-devel jq curl\
    bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel \
    libffi-devel xz-devel sudo shadow nano file procps-ng git google-cloud-cli \
    passwd iproute findutils diffutils util-linux docker awscli-2 bash-completion && \
  dnf groupinstall -y --disablerepo=google-cloud-cli 'Development Tools' && \
  dnf clean all && \
  groupadd -g ${GID} ${GROUPNAME} -f && \
  useradd --uid ${UID} --gid ${GID} -G root -m -s /bin/bash ${USERNAME} && \
  mkdir -p /usr/local/libexec/cli-plugins && usermod -aG docker ${USERNAME} && \  
  curl -sfL https://direnv.net/install.sh | bash && \
  echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME} && \
  curl -fsSL https://rpm.nodesource.com/setup_${NODE_VERSION}.x | sudo bash - && \
  dnf install -y nodejs && dnf clean all
COPY --from=collector /docker-compose /usr/local/libexec/docker/cli-plugins/

# pyenv & homebrew
USER ${USERNAME}
WORKDIR /home/${USERNAME}
ARG PYENV_ROOT=/home/${USERNAME}/.pyenv
ARG BREW_INSTALL_URL=https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh
COPY --chown=${USERNAME}:${GROUPNAME} ./docker/al2023/bashrc .bashrc
RUN curl https://pyenv.run | bash && \
  ${PYENV_ROOT}/bin/pyenv install ${PYTHON_VERSION} && \
  ${PYENV_ROOT}/bin/pyenv local ${PYTHON_VERSION} && \
  sh -c "$(curl -fsSL ${BREW_INSTALL_URL})"

