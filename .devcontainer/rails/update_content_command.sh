#!/bin/bash

source /usr/local/rvm/scripts/rvm
rvm use 3.4.7 --default

gem install bundler:2.4.12
gem install debug

bundle install
