#!/bin/bash
set -x

# Import the SSH deployment key
openssl aes-256-cbc -K $encrypted_26b4962af0e7_key -iv $encrypted_26b4962af0e7_iv -in id-rsa.enc -out id-rsa -d
mv id-rsa ~/.ssh/id_rsa
rm id-rsa.enc
chmod 600 ~/.ssh/id_rsa

# Import Octopress 
#openssl aes-256-cbc -K $encrypted_26b4962af0e7_key -iv $encrypted_26b4962af0e7_iv -in Rakefile.enc -out Rakefile -d
chmod 600 Rakefile
rm Rakefile.enc

#openssl aes-256-cbc -K $encrypted_26b4962af0e7_key -iv $encrypted_26b4962af0e7_iv -in _config.yml.enc -out _config.yml -d
chmod 600 _config.yml
rm _config.yml.enc

gem install bundler

