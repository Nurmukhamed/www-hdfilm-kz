#!/bin/bash

# Encrypt archive and extract archive
openssl aes-256-cbc -K $encrypted_26b4962af0e7_key -iv $encrypted_26b4962af0e7_iv -in encryptedfiles.tar.enc -out encryptedfiles.tar -d
tar xvf encryptedfiles.tar
rm encryptedfiles.tar

# Import the SSH deployment key
mv id-rsa ~/.ssh/id_rsa
rm id-rsa.enc
chmod 600 ~/.ssh/id_rsa

# Import Octopress 
chmod 600 Rakefile


chmod 600 _config.yml


gem install bundler

cat Rakefile | grep ftp
