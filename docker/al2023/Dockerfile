#最新のdocker-composeを取得
#docker Desktop併用前提で一旦削除  
#本編
FROM amazonlinux:2023
ARG USERNAME
ARG GROUPNAME
ARG UID
ARG GID
ARG PYTHON_VERSION
ARG NODE_VERSION
ENV SHELL=/bin/bash
COPY ./docker/al2023/wsl.conf /etc
COPY ./docker/al2023/gcloud.repo /etc/yum.repos.d
COPY ./docker/al2023/dnf.txt /tmp
RUN set -ex && dnf -y upgrade --releasever=latest && \
  dnf install -y --enablerepo=google-cloud-cli $(cat /tmp/dnf.txt) && \
  dnf groupinstall -y --disablerepo=google-cloud-cli 'Development Tools' && \
  dnf clean all  && rm /tmp/dnf.txt && \
  mkdir /etc/skel/.ssh && chmod 700 /etc/skel/.ssh && \
  touch /etc/skel/.ssh/authorized_keys && \
  chmod 600 /etc/skel/.ssh/authorized_keys && \
  groupadd -g ${GID} ${GROUPNAME} -f && \
  useradd --uid ${UID} --gid ${GID} -G root -m -s /bin/bash ${USERNAME} && \
  mkdir -p /usr/local/libexec/cli-plugins && usermod -aG docker ${USERNAME} && \  
  curl -sfL https://direnv.net/install.sh | bash && \
  echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME} && \
  curl -fsSL https://rpm.nodesource.com/s etup_${NODE_VERSION}.x | sudo bash - && \
  dnf install -y nodejs && dnf clean all

# pyenv/homebrew/AIエージェントをインストール
USER ${USERNAME}
WORKDIR /home/${USERNAME}
ARG PYENV_ROOT=/home/${USERNAME}/.pyenv
ARG BREW_INSTALL_URL=https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh
ARG ENABLE_CURSOR
ARG ENABLE_CODEX
ARG ENABLE_GEMINI
ARG ENABLE_CLAUDE
ARG ENABLE_PNPM
COPY --chown=${USERNAME}:${GROUPNAME} ./docker/al2023/bashrc .bashrc
COPY --chown=${USERNAME}:${GROUPNAME} ./docker/al2023/bashrc .bashrc
COPY --chown=${USERNAME}:${GROUPNAME} ./docker/al2023/ssh/ .ssh
COPY --chown=${USERNAME}:${GROUPNAME} ./docker/al2023/git-functions .bashrc.d/git-functions
RUN set -ex && pwd &&ls -la && curl https://pyenv.run | bash && \
  ${PYENV_ROOT}/bin/pyenv install ${PYTHON_VERSION} && \
  ${PYENV_ROOT}/bin/pyenv local ${PYTHON_VERSION} && \
  sh -c "$(curl -fsSL ${BREW_INSTALL_URL})" && \
  find .ssh -type f ! -name '*.pub' -exec chmod 600 {} \; && \
  rm .ssh/.gitignore && \
  AGENTS="${ENABLE_CODEX:+@openai/codex} ${ENABLE_GEMINI:+@google/gemini-cli} ${ENABLE_CLAUDE:+@anthropic-ai/claude-code}" && \
  echo "AGENTS: ${AGENTS}" && \
  if [ "${ENABLE_CURSOR}" = "true" ]; then curl https://cursor.com/install -fsS | bash; fi && \
  if [ "${AGENTS}" != "  " ]; then sudo npm install -g ${AGENTS}; fi && \
  if [ "${ENABLE_PNPM}" = "true" ]; then sudo npm install -g pnpm; fi