How to Set-up Plagger on Autoparts
==================================
INDEX
-----
1. Dependencies
2. Set-up Docker/CentOS 6 x86_64
3. Set-up Plagger on Autoparts/Ubuntu 12.04


1. Dependencies
---------------
### servers
- centos = CentOS 6 x86_64
- plaggeronubuntu = Ubuntu 12.04 for Plagger on CentOS 6 x86_64
- client = Client PC

### scripts
- [docker/docker](https://github.com/docker/docker)
- [tagomoris/xbuild](https://github.com/tagomoris/xbuild)
- [nitrous-io/autoparts](https://github.com/nitrous-io/autoparts)
- [purcell/emacs.d](https://github.com/purcell/emacs.d)
- [nabinno/dot-files](https://github.com/nabinno/dot-files)
- [nabinno/dot-plagger](https://github.com/nabinno/dot-plagger)
- [nabinno/plagger-on-autoparts](https://github.com/nabinno/plagger-on-autoparts)
- etc.


2. Set-up Docker/CentOS 6 x86_64
--------------------------------
```sh
root@centos# adduser foo
root@centos# echo foo | passwd bar --stdin

### set env for sudo
root@centos# sed -i "s/^\(root.*\)$/\1\n000\tALL=(ALL)\tALL/g" /etc/sudoers

### set env for auth
root@centos# sed -i "s/^\(#PermitRootLogin yes\)/\1\nPermitRootLogin no/g" /etc/ssh/sshd_config
root@centos# sed -i "s/^\(#PasswordAuthentication yes\)/\1\nPasswordAuthentication no/g" /etc/ssh/sshd_config
root@centos# sed -i "s/^\(#ChallengeResponseAuthentication yes\)/\1\nChallengeResponseAuthentication no/g" /etc/ssh/sshd_config
root@centos# sed -i "s/^\(#RhostsRSAAuthentication no\)/\1\nRhostsRSAAuthentication no/g" /etc/ssh/sshd_config
root@centos# sed -i "s/^\(#PermitEmptyPasswords no\)/\1\nPermitEmptyPasswords no/g" /etc/ssh/sshd_config

### set env for other
root@centos# sed -i "s/^\(#Protocol 2,1\)/\1\nProtocol 2/g" /etc/ssh/sshd_config
root@centos# sed -i "s/^\(#SyslogFacility AUTH\)/\1\nSyslogFacility AUTHPRIV/g" /etc/ssh/sshd_config

### install docker
root@centos# yum install docker-io -y
root@centos# service docker start
root@centos# chkconfig docker on
foo@centos% alias docker='sudo docker'

### set env for auth of password
client# ssh-keygen -t rsa
client# ssh-copy-id -i ~/.ssh/id_rsa.pub foo@centos.host
client# mv ~/.ssh/id_rsa ~/.ssh/id_rsa_foo@centos
client# ssh foo@centos.host
foo@centos% sudo sed -i "s/^\(#PasswordAuthentication yes\)/\1\nPasswordAuthentication no/g" /etc/ssh/sshd_config
foo@centos% sudo /etc/init.d/sshd restart
```


3. Set-up Plagger on Autoparts/Ubuntu 12.04
-------------------------------------------
```sh

### build
# foo@centos% sudo sysctl overcommit_memory=1    # A/N
# foo@centos% sudo sysctl overcommit_ratio=75    # A/N
foo@centos% docker build -t nitrousio/autoparts-builder https://raw.githubusercontent.com/nitrous-io/autoparts/master/Dockerfile
foo@centos% docker build -t nabinno/plagger-on-autoparts https://raw.githubusercontent.com/nabinno/plagger-on-autoparts/master/Dockerfile

### start sshd server
foo@centos% docker run -t -d -P nabinno/plagger-on-autoparts /usr/sbin/sshd -D

### get port
foo@centos% docker inspect --format {{.NetworkSettings.IPAddress}} $(docker ps -l -q)
foo@centos% docker inspect --format {{.NetworkSettings.Ports}} $(docker ps -l -q)

### change password of ubuntu user
client# ssh-keygen -t rsa
client# ssh-copy-id -i ~/.ssh/id_rsa.pub action@plaggeronubuntu -p port-plaggeronubuntu
client# mv ~/.ssh/id_rsa ~/.ssh/id_rsa_action@plaggeronubuntu
client# ssh -t action@plaggeronubuntu(centos.host) zsh -p port-plaggeronubuntu
foo@centos% docker commit $(docker ps -l -q) container_id
foo@centos% docker run -i -t nabinno/plagger-on-autoparts zsh
root@plaggeronubuntu# sed -i "s/^\(#PasswordAuthentication yes\)/\1\nPasswordAuthentication no/g" /etc/ssh/sshd_config
root@plaggeronubuntu# echo 'action:baz' | chpasswd
root@plaggeronubuntu# /etc/init.d/ssh restart
foo@centos% docker commit $(docker ps -l -q) container_id
foo@centos% docker run -t -d -P nabinno/plagger-on-autoparts /usr/sbin/sshd -D
client# ssh -t action@plaggeronubuntu zsh -p port-plaggeronubuntu
```


EPILOGUE
--------
>     A whale! 
>     Down it goes, and more, and more
>     Up goes its tail!
>     
>     -Buson Yosa
