#!/usr/bin/env bash

USER=`whoami`
APP_ROOT=/var/www/singflying

sudo apt-get update

# Install system packages
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y redis-server memcached git-core nodejs imagemagick postfix

# Install Elasticsearch
wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
sudo bash -c "echo 'deb http://packages.elasticsearch.org/elasticsearch/1.0/debian stable main' > /etc/apt/sources.list.d/elasticsearch.list"
sudo apt-get update
sudo apt-get install -y openjdk-7-jre-headless elasticsearch
sudo update-rc.d elasticsearch defaults
sudo service elasticsearch start

# Install PostgreSQL
sudo apt-get install -y postgresql libpq-dev
sudo su postgres -c "createuser -d -R -S $USER"


# Install rvm and ruby
sudo apt-get install libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
curl -L https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
echo "source ~/.rvm/scripts/rvm" >> ~/.bashrc
rvm install 2.1.2
rvm use 2.1.2 --default
ruby -v
echo "gem: --no-ri --no-rdoc" > ~/.gemrc


# nignx
gpg --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
gpg --armor --export 561F9B9CAC40B2F7 | sudo apt-key add -

# Add HTTPS support to APT
sudo apt-get install apt-transport-https

# Add the passenger repository
sudo sh -c "echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main' >> /etc/apt/sources.list.d/passenger.list"
sudo chown root: /etc/apt/sources.list.d/passenger.list
sudo chmod 600 /etc/apt/sources.list.d/passenger.list
sudo apt-get update

# Install nginx and passenger
sudo apt-get install nginx-full passenger

sudo service nginx start


# Development environment
cp config/database.example.yml config/database.yml
cp config/secrets.example.yml config/secrets.yml
cp config/config.example.yml config/config.yml
bundle install
bundle exec rake db:create:all db:setup

# Production environment
sudo mkdir -p $APP_ROOT
sudo chown $USER:sudo $APP_ROOT
mkdir -p $APP_ROOT/shared/config
cp config/database.example.yml $APP_ROOT/shared/config/database.yml
cp config/secrets.example.yml $APP_ROOT/shared/config/secrets.yml
cp config/config.example.yml $APP_ROOT/shared/config/config.yml
sed -i "s/secret_key_base: \w\+/secret_key_base: `bundle exec rake secret`/g" $APP_ROOT/shared/config/secrets.yml

# Resque init script
sudo cp config/resque.example.sh /etc/init.d/resque
sudo chmod +x /etc/init.d/resque
sudo sed -i "s|APP_ROOT=.\+|APP_ROOT=$APP_ROOT/current|" /etc/init.d/resque
sudo sed -i "s/USER=\w\+/USER=$USER/" /etc/init.d/resque
sudo update-rc.d resque defaults

# Nginx config
sudo cp config/nginx.example.conf /etc/nginx/sites-available/singflying
sudo sed -i "s|root .\+;|root $APP_ROOT/current/public;|" /etc/nginx/sites-available/singflying
sudo ln -s /etc/nginx/sites-available/singflying /etc/nginx/sites-enabled/singflying
sudo rm /etc/nginx/sites-enabled/default
sudo sed -i 's/# passenger_root/passenger_root/' /etc/nginx/nginx.conf
sudo sed -i "s|# passenger_ruby .\+;|passenger_ruby /home/$USER/.rvm/wrappers/default/ruby;|" /etc/nginx/nginx.conf
sudo service nginx restart
