#!/bin/bash

eval "$(rbenv init -)"
rbenv local 3.2.6
rbenv global 3.2.6
rbenv rehash

gem install bundler:2.4.12
gem install yard

bundle add solargraph solargraph-rails --skip-install --group "development"
bundle install

yard doc
