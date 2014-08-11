FROM nitrousio/autoparts-builder

RUN apt-get update; apt-get install -y \
  build-essential \
  libxml2 \
  emacs \
  openssh-server \
  screen \
  tree \
  vim \
  zsh

# autoparts
RUN parts install heroku_toolbelt

# autoparts/xbuild

RUN git clone https://github.com/tagomoris/xbuild.git ~/.parts/autoparts/bin/xbuild

# autoparts/xbuild/perl
RUN mkdir ~/local
RUN ~/.parts/autoparts/bin/xbuild/perl-install 5.18.2 ~/local/perl-5.18
# RUN curl -s https://raw.githubusercontent.com/tokuhirom/Perl-Build/master/perl-build > /usr/bin/perl-build
# RUN perl -pi -e 's%^#!/usr/bin/env perl%#!/usr/bin/perl%g' /usr/bin/perl-build
# RUN chmod +x /usr/bin/perl-build

# autoparts/xbuild/perl/plagger
RUN export PATH=$HOME/local/perl-5.18/bin:$PATH
# RUN cpanm -Lextlib -n --installdeps ~/
RUN yes | cpan YAML::Loader
RUN yes | cpan XML::LibXML
RUN yes | cpan XML::LibXML::SAX
RUN yes | cpan XML::LibXML::XPathContext
RUN yes | cpan XML::Liberal
RUN yes | cpan Text::Glob
RUN yes | cpan Module::Runtime
RUN yes | cpan Params::Util
RUN yes | cpan Digest::SHA1
RUN yes | cpan -fi Class::Load
RUN yes | cpan -fi XML::RSS
RUN yes | cpan -fi XML::RSS::LibXML
RUN yes | cpan -fi XML::RSS::Liberal
RUN yes | cpan -fi XML::Feed
RUN yes | cpan -fi XML::Feed::RSS
RUN yes | cpan -fi XML::Atom
RUN yes | cpan -fi WebService::Bloglines
RUN yes | cpan -fi Plagger

# dot files
RUN git clone https://github.com/nabinno/dot-files.git
RUN find ~/dotfiles -maxdepth 1 -mindepth 1 | xargs -i mv -f {} ~/
RUN rm -fr dotfiles .git README.md

# environmental variables
RUN sed -i "s/^\(root.*\)$/\1\naction\tALL=(ALL)\tALL/g" /etc/sudoers
RUN sed -i "s/^#Protocol 2,1/Protocol 2/g" /etc/ssh/sshd_config
RUN sed -i "s/^#SyslogFacility AUTH/SyslogFacility AUTH/g" /etc/ssh/sshd_config
RUN sed -i "s/^\(PermitRootLogin yes\)/#\1\nPermitRootLogin without-password/g" /etc/ssh/sshd_config
RUN sed -i "s/^\(ChallengeResponseAuthentication no\)/#\1\nChallengeResponseAuthentication yes/g" /etc/ssh/sshd_config
# RUN sed -i "s/^\(#PasswordAuthentication yes\)/\1\nPasswordAuthentication yes/g" /etc/ssh/sshd_config
RUN echo 'root:screencast' | chpasswd
RUN echo 'action:nitrousio' | chpasswd
RUN chsh -s /usr/bin/zsh root
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales
RUN chmod 777 /var/run/screen
RUN chown -R action:action /home/action

# sshd
RUN mkdir -p /var/run/sshd 
EXPOSE 22
CMD    /usr/sbin/sshd -D
