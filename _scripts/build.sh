#!/bin/bash
# build Octopress 
rm -rf .git
rm -rf public
git clone git@github.com:Nurmukhamed/www-hdfilm-kz-octopress.git

bundle exec rake generate




