FROM centos:centos7

# change default shell
SHELL ["/bin/bash", "-c"]

# set envs
ENV HOME /root
ENV ANYENV_HOME $HOME/.anyenv
ENV ANYENV_ENV  $ANYENV_HOME/envs

# install packages (for anyenv, node, rails)
RUN set -x \
  && yum -y update \
  && yum install -y epel-release \
  && yum install -y sudo git make autoconf curl wget which perl-Digest-SHA \
  && yum install -y gcc-c++ glibc-headers openssl-devel readline libyaml-devel readline-devel zlib zlib-devel bzip2

# install anyenv
RUN git clone https://github.com/riywo/anyenv ~/.anyenv \
    && echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> ~/.bashrc \
    && echo 'eval "$(anyenv init -)"' >> ~/.bashrc
ENV PATH $ANYENV_HOME/bin:$PATH

# install envs
RUN source ~/.bashrc \
  && anyenv install rbenv \
  && anyenv install nodenv \
  && anyenv install pyenv
ENV RBENV_ROOT $ANYENV_ENV/rbenv
ENV NODENV_ROOT $ANYENV_ENV/nodenv
ENV PYENV_ROOT $ANYENV_ENV/pyenv
ENV PATH $RBENV_ROOT/bin:$RBENV_ROOT/shims:$NODENV_ROOT/bin:$NODENV_ROOT/shims:$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH

# install ruby
RUN source ~/.bashrc \
  && rbenv install 2.4.0 \
  && rbenv global 2.4.0 \
  && gem install bundler -v 1.16.5

# install node
RUN source ~/.bashrc \
  && nodenv install v8.12.0 \
  && nodenv global v8.12.0 \
  && npm install npm@6.4.1 -g \
  && npm install pm2 express -g
  
# install python
RUN source ~/.bashrc \
  && pyenv install 3.6.8 \
  && pyenv global 3.6.8 \
  && pip install locustio pyzmq

# install anyenv update
RUN source ~/.bashrc \
  && mkdir -p $(anyenv root)/plugins \
  && git clone https://github.com/znz/anyenv-update.git $(anyenv root)/plugins/anyenv-update

# install headless chrome
COPY ./etc/yum.repos.d/google-chrome.repo /etc/yum.repos.d/
RUN source ~/.bashrc \
  && yum -y update \
  && yum install -y libX11 GConf2 fontconfig \
  && yum install -y google-chrome-stable

# change default work directory
WORKDIR /usr/local/src
