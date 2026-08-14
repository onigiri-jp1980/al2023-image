#最新のdocker-composeを取得
#docker Desktop併用前提で一旦削除  

#ベースイメージ
#最新のamazonlinuxを使用して必要パッケージをインストールしておく
FROM amazonlinux:2023 as base
COPY ./docker/al2023/dnf.txt /tmp
COPY ./docker/al2023/dnf-groups.txt /tmp
RUN set -xe && dnf -y upgrade --releasever=latest && \
  while IFS= read -r group; do dnf groupinstall -y $group; done < /tmp/dnf-groups.txt && \
  dnf install -y $(cat /tmp/dnf.txt) && \
  dnf clean all && rm /tmp/dnf*.txt

#本編
FROM base as app
ARG USER_NAME
ARG GROUP_NAME
ARG USER_ID
ARG GROUP_ID
ARG PYTHON_VERSION
ARG NODE_VERSION
ARG ENABLE_PNPM
ARG PNPM_VERSION
ARG ENABLE_GOOGLE_CLOUD_CLI
ARG DIRENV_INSTALL_URL=https://direnv.net/install.sh
ARG NODE_INSTALL_URL=https://rpm.nodesource.com/setup_${NODE_VERSION}.x
ENV SHELL=/bin/bash
RUN echo "USER_NAME: ${USER_NAME}" && \
  echo "GROUP_NAME: ${GROUP_NAME}" && \
  echo "USER_ID: ${USER_ID}" && \
  echo "GROUP_ID: ${GROUP_ID}"
COPY ./docker/al2023/wsl.conf /etc
COPY ./docker/al2023/gcloud.repo /etc/yum.repos.d
COPY ./docker/al2023/gcloud.txt /tmp/gcloud.txt
RUN if [ "${ENABLE_GOOGLE_CLOUD_CLI}" = "true" ]; then \
  dnf install -y --enablerepo=google-cloud-cli $(cat /tmp/gcloud.txt) && \
  dnf clean all  && rm -rf /tmp/gcloud.txt; fi && \
  mkdir /etc/skel/.ssh && chmod 700 /etc/skel/.ssh && \
  touch /etc/skel/.ssh/authorized_keys && \
  chmod 600 /etc/skel/.ssh/authorized_keys && \
  groupadd -g ${GROUP_ID} ${GROUP_NAME} -f && \
  useradd --uid ${USER_ID} --gid ${GROUP_ID} -G root -m -s /bin/bash ${USER_NAME} && \
  mkdir -p /usr/local/libexec/cli-plugins && usermod -aG docker ${USER_NAME} && \  
  curl -sfL ${DIRENV_INSTALL_URL} | bash && \
  echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER_NAME} && \
  curl -fsSL ${NODE_INSTALL_URL} | sudo bash - && \
  dnf install -y nodejs && dnf clean all 

# pyenv/homebrew/AIエージェントをインストール
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}
ARG PYENV_ROOT=/home/${USER_NAME}/.pyenv
ARG PNPM_HOME=/home/${USER_NAME}/.local/share/pnpm
ARG BREW_INSTALL_URL=https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh
ARG PNPM_INSTALL_URL=https://get.pnpm.io/install.sh
ARG PYENV_INSTALL_URL=https://pyenv.run
ARG CURSOR_AGENT_INSTALL_URL=https://cursor.com/install
ARG ENABLE_CURSOR
ARG ENABLE_CODEX
ARG ENABLE_GEMINI
ARG ENABLE_CLAUDE
COPY --chown=${USER_NAME}:${GROUP_NAME} ./docker/al2023/bashrc .bashrc
COPY --chown=${USER_NAME}:${GROUP_NAME} ./docker/al2023/ssh/ .ssh
COPY --chown=${USER_NAME}:${GROUP_NAME} ./docker/al2023/git-functions .bashrc.d/git-functions
COPY --chown=${USER_NAME}:${GROUP_NAME} ./docker/al2023/pnpm .bashrc.d/pnpm
RUN set -ex && curl -fsSL ${PYENV_INSTALL_URL} | bash && \
  if [ "${ENABLE_PNPM}" = "true" ]; then curl -fsSL ${PNPM_INSTALL_URL} | sh; pnpm setup; export PATH="${PNPM_HOME}/bin:${PATH}"; NPM_CMD=pnpm; else NPM_CMD=npm; fi && \
  ${PYENV_ROOT}/bin/pyenv install ${PYTHON_VERSION} && \
  ${PYENV_ROOT}/bin/pyenv local ${PYTHON_VERSION} && \
  sh -c "$(curl -fsSL ${BREW_INSTALL_URL})" && \
  find .ssh -type f ! -name '*.pub' -exec chmod 600 {} \; && \
  rm .ssh/.gitignore && \
  AGENTS="${ENABLE_CODEX:+@openai/codex} ${ENABLE_GEMINI:+@google/gemini-cli} ${ENABLE_CLAUDE:+@anthropic-ai/claude-code}" && \
  echo "AGENTS: ${AGENTS}" && \
  if [ "${ENABLE_CURSOR}" = "true" ]; then curl ${CURSOR_AGENT_INSTALL_URL} -fsS | bash; fi && \
  if [ "${AGENTS}" != "  " ]; then ${NPM_CMD} install -g ${AGENTS}; fi
