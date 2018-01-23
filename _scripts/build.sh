#!/bin/bash
# build Octopress 
rm -rf public
git submodule add -b master git@github.com:Nurmukhamed/www-hdfilm-kz-hugo public
bundle exec rake generate



