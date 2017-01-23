#!/bin/bash
set -x

# Import the SSH deployment key
openssl aes-256-cbc -K $encrypted_62f3167d5387_key -iv $encrypted_62f3167d5387_iv -in travis_pub_base64.enc -out travis_pub_base64 -d
mv travis_pub_base64 ~/.ssh/id_rsa
rm travis_pub_base64.enc
chmod 600 ~/.ssh/id_rsa

# Import Octopress 
openssl aes-256-cbc -K $encrypted_26b4962af0e7_key -iv $encrypted_26b4962af0e7_iv -in Rakefile.enc -out Rakefile -d
chmod 600 Rakefile
rm Rakefile.enc

openssl aes-256-cbc -K $encrypted_26b4962af0e7_key -iv $encrypted_26b4962af0e7_iv -in _config.yml.enc -out _config.yml -d
chmod 600 _config.yml
rm _config.yml



