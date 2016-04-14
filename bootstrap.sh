#!/bin/bash
set -e

# Uncomment the following line while debugging
# set -x

# Overwrite env from base image
export HOME=/opt/home
export TEMP_DIR=/tmp
export TMPDIR=/tmp
export TMP_DIR=/tmp

# Other environment variables
export NVM_DIR=/opt/nvm
export PROFILE=$HOME/.profile
export DEMETEORIZER_VERSION=3.1.0

# Create $HOME/.profile and export environment variable
if [[ ! -d $HOME ]]; then
  mkdir -p $HOME
fi

touch $PROFILE

# Install dependent libraries
apt-get update && apt-get install -y libssl0.9.8 libsqlite-dev \
  libexpat1 libexpat1-dev libicu-dev libpq-dev libcairo2-dev \
  libjpeg8-dev libpango1.0-dev libgif-dev libxml2-dev \
  libmagickcore-dev libmagickwand-dev

# Install ImageMagick
export MAKEFLAGS="-j $(grep -c ^processor /proc/cpuinfo)"
cd /opt
wget http://www.imagemagick.org/download/ImageMagick.tar.gz
tar -xf ImageMagick.tar.gz && mv ImageMagick-* ImageMagick && cd ImageMagick && ./configure && make && sudo make install
ldconfig /usr/local/lib && rm -rf /opt/ImageMagick*
cd /opt

# Install nvm
mkdir -p $NVM_DIR
curl https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash

# Ensure mop can use nvm, but not write to it
chown mop:mop /opt/nvm/nvm.sh
chmod g-w /opt/nvm/nvm.sh

# Install get-version
npm install -g get-version

# Install demeteorizer
npm install -g demeteorizer@$DEMETEORIZER_VERSION

# Install Meteor
curl https://install.meteor.com/ | sh

# Ensure mop can copy the Meteor distribution
chown mop:mop -R $HOME

# Clean stuff up that's no longer needed
apt-get autoclean && apt-get autoremove -y && apt-get clean
