#!/bin/bash
# build Octopress 
rm -rf .git
rm -rf public
git clone git@github.com:Nurmukhamed/www-hdfilm-kz-hugo.git

bundle exec rake generate




