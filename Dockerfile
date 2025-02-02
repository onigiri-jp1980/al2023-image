FROM amazonlinux:2023
ARG USERNAME="appuser"
ARG USERID="1000"
ARG PYTHON_VERSION="3.12.0"
ENV SHELL=/bin/bash
COPY ./docker/wsl.conf /etc
RUN echo ${USERNAME}
RUN dnf -y upgrade --releasever=latest && \
  dnf install -y unzip tar gcc zlib-devel bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel sudo shadow nano git && \
  dnf clean all && \
  useradd -m -s /bin/bash ${USERNAME} && \
  curl -sfL https://direnv.net/install.sh | bash && \
  echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME}
USER ${USERNAME}
WORKDIR /home/${USERNAME}
ARG PYENV_ROOT=/home/${USERNAME}/.pyenv
COPY ./docker/bashrc .bashrc
RUN curl https://pyenv.run | bash
RUN ${PYENV_ROOT}/bin/pyenv install ${PYTHON_VERSION} && ${PYENV_ROOT}/bin/pyenv local ${PYTHON_VERSION}
 