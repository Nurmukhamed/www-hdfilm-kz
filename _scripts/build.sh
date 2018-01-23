#!/bin/bash
# build Octopress 
rm -rf public
git submodule add -b master git@github.com:Nurmukhamed/www-hdfilm-kz-hugo.git gh-pages

bundle exec rake generate
rsync -avz --delete public/ gh-pages/



