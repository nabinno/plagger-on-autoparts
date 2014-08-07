FROM ubuntu:12.04

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN echo "deb http://archive.ubuntu.com/ubuntu precise-updates main universe" >> /etc/apt/sources.list
RUN echo "deb http://archive.ubuntu.com/ubuntu precise-security main universe" >> /etc/apt/sources.list

RUN apt-get update; apt-get install -y \
  automake \
  autotools-dev \
  base-files \
  base-passwd \
  binutils \
  build-essential \
  bzip2 \
  cmake \
  curl \
  dnsutils \
  emacs
  gdb \
  git \
  git-core \
  gnupg \
  imagemagick \
  libarchive-dev \
  libarchive12 \
  libbz2-1.0 \
  libbz2-dev \
  libc6 \
  libcurl3 \
  libcurl3-gnutls \
  libcurl4-openssl-dev \
  libdb5.1 \
  libdb5.1-dev \
  libevent-1.4-2 \
  libevent-core-1.4-2 \
  libevent-dev \
  libevent-extra-1.4-2 \
  libffi-dev \
  libgdbm-dev \
  libglib2.0-dev \
  libglib2.0-dev \
  libicu-dev \
  libldap-2.4-2 \
  libldap2-dev \
  libltdl-dev \
  libltdl7 \
  liblzma-dev \
  liblzma-doc \
  liblzma5 \
  libmagickcore-dev \
  libmagickwand-dev \
  libmysqlclient-dev \
  libncap-dev \
  libncap44 \
  libncurses5-dev \
  libncurses5-dev \
  libncursesw5 \
  libncursesw5-dev \
  libncursesw5-dev \
  libpam0g-dev \
  libpng12-0 \
  libpng12-dev \
  libpq-dev \
  libqt4-dev \
  libreadline6-dev \
  libsndfile1-dev \
  libsqlite3-dev \
  libssl0.9.8 \
  libxml2 \
  libxml2-dev \
  libxslt1-dev \
  libxt-dev \
  libxt6 \
  libyaml-dev \
  openssl \
  openssh-server \
  psmisc \
  perl5.18.2 \
  pwgen \
  s3cmd \
  screen \
  sqlite3 \
  telnet \
  tsconf \
  unzip \
  util-linux \
  wget \
  whiptail \
  xz-utils \
  zip \
  zlib1g \
  zlib1g-dev \
  zsh

# User
RUN adduser -p nitrousio action
RUN git clone https://nabinno:i65cgh1qaz@github.com/nabinno/autoparts-with-plagger.git /home/action
RUN chown -R action:action /home/action

# Securities
RUN sed -i "s/^\(root.*\)$/\1\n000\tALL=(ALL)\tALL/g" /etc/sudoers
RUN sed -i "s/^#Protocol 2,1/Protocol 2/g" /etc/ssh/sshd_config
RUN sed -i "s/^#SyslogFacility AUTH/SyslogFacility AUTHPRIV/g" /etc/ssh/sshd_config
RUN sed -i "s/^#PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
RUN sed -i "s/^#PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
RUN sed -i "s/^#PermitEmptyPasswords no/PermitEmptyPasswords no/g" /etc/ssh/sshd_config

# Emacs Files
RUN mkdir -p /home/action/.emacs.d
RUN git clone https://nabinno@github.com/nabinno/emacs.d.git /home/action
RUN chown -R action:action /home/action/.emacs.d

# Dot Files
RUN mkdir -p /home/action/dotfiles
RUN git clone https://nabinno:i65cgh1qaz@github.com/nabinno/dotfiles.git /home/action
RUN chown -R action:action /home/action/dotfiles
RUN mv /home/action/dotfiles/* /home/action/
RUN mv /home/action/dotfiles/.* /home/action/
RUN rm -fr /home/action/dotfiles

# Environmental Variables
ENV PATH /home/action/.parts/autoparts/bin:${PATH}
ENV AUTOPARTS_DEV true
ENV HOME /home/action
WORKDIR /home/action

# Sshd
RUN mkdir -p /var/run/sshd 
EXPOSE 23133
CMD    /usr/sbin/sshd -D
