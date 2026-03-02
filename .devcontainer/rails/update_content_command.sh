#!/bin/bash

source /usr/local/rvm/scripts/rvm
rvm use 3.4.7 --default

gem install debug

cd rails/trading && bundle install
