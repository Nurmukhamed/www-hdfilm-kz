#!/bin/bash

# Encrypt archive and extract archive
openssl aes-256-cbc -K $encrypted_2f4b7b8a1cd1_key -iv $encrypted_2f4b7b8a1cd1_iv -in encryptedfiles.tar.enc -out encryptedfiles.tar -d
tar xvf encryptedfiles.tar
rm encryptedfiles.tar

# Import the SSH deployment key
mv id_rsa ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa


# Import Octopress 
chmod 600 Rakefile


chmod 600 _config.yml


gem install bundler -v 1.17.3
