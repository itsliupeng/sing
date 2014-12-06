#!/usr/bin/env bash

USER=`whoami`


# git
sudo apt-get install git

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y redis-server memcached git-core nodejs imagemagick postfix

# vim configuration
if [ -e "/home/vagrant/macvim"]
then
  git clone https://github.com/dp90219/macvim ~/macvim
  mv ~/macvim ~/.vim
  ln -s ~/.vim/vimrc ~/.vimrc
  source ~/.vimrc
fi
# postgresql 
sudo apt-get install -y postgresql libpq-dev
sudo su postgres -c "createuser -d -R -S $USER"

# ruby 
curl -sSL https://get.rvm.io | bash -s master && source ~/.rvm/scripts/rvm && echo "source ~/.rvm/scripts/rvm" >> ~/.bashrc
rvm install 2.1
echo "gem: --no-rdoc --no-ri " >> ~/.gemrc
gem install rails

#

