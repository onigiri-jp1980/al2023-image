FROM amazonlinux:2023 AS collector
ARG DOCKER_COMPOSE_VERSION
ARG ARCH
ARG DOCKER_COMPOSE_URL=https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${ARCH}
RUN dnf update && dnf clean all && dnf install -y util-linux && set -eux; \
  LATEST=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/docker/compose/releases/latest | rev | cut -d/ -f1 | rev); \
  curl -L "https://github.com/docker/compose/releases/download/${LATEST}/${ARCH}" -o docker-compose; \
  chmod +x ./docker-compose

FROM amazonlinux:2023
ARG USERNAME
ARG GROUPNAME
ARG UID
ARG GID
ARG PYTHON_VERSION
ARG HOST_DOCKER_GID
ENV SHELL=/bin/bash
COPY ./docker/al2023/wsl.conf /etc
COPY ./docker/al2023/gcloud.repo /etc/yum.repos.d
RUN dnf -y upgrade --releasever=latest && \
  dnf install -y --enablerepo=google-cloud-cli unzip tar gcc zlib-devel \
    bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel \
    libffi-devel xz-devel sudo shadow nano file procps-ng git google-cloud-cli && \
  dnf groupinstall -y --disablerepo=google-cloud-cli 'Development Tools' && \
  dnf clean all && \
  groupadd -g ${GID} ${GROUPNAME} -f && \
  useradd --uid ${UID} --gid ${GID} -G root -m -s /bin/bash ${USERNAME} && \
  curl -sfL https://direnv.net/install.sh | bash && \
  echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME}

# set up docker
RUN dnf install -y docker && dnf clean all && \
  mkdir -p /usr/local/libexec/cli-plugins && usermod -aG docker ${USERNAME}   
COPY --from=collector /docker-compose /usr/local/libexec/docker/cli-plugins/

# pyenv
USER ${USERNAME}
WORKDIR /home/${USERNAME}
ARG PYENV_ROOT=/home/${USERNAME}/.pyenv
COPY --chown=${USERNAME}:${GROUPNAME} ./docker/al2023/bashrc .bashrc

RUN curl https://pyenv.run | bash && \
  ${PYENV_ROOT}/bin/pyenv install ${PYTHON_VERSION} && ${PYENV_ROOT}/bin/pyenv local ${PYTHON_VERSION}

# homebrew
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
