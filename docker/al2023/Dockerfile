FROM amazonlinux:2023
ARG USERNAME
ARG GROUPNAME
ARG UID
ARG GID
ARG PYTHON_VERSION
ENV SHELL=/bin/bash
COPY ./docker/al2023/wsl.conf /etc
RUN dnf -y upgrade --releasever=latest && \
  dnf install -y unzip tar gcc zlib-devel bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel sudo shadow nano git && \
  dnf clean all && \
  groupadd -g ${GID} ${GROUPNAME} -f && \
  useradd --uid ${UID} --gid ${GID} -m -s /bin/bash ${USERNAME} && \
  curl -sfL https://direnv.net/install.sh | bash && \
  echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME}
USER ${USERNAME}
WORKDIR /home/${USERNAME}
ARG PYENV_ROOT=/home/${USERNAME}/.pyenv
COPY ./docker/al2023/bashrc .bashrc
RUN curl https://pyenv.run | bash
RUN ${PYENV_ROOT}/bin/pyenv install ${PYTHON_VERSION} && ${PYENV_ROOT}/bin/pyenv local ${PYTHON_VERSION}
 