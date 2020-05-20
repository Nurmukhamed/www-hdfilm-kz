#!/bin/bash
# build Octopress 
HOMEDIR=/home/travis/build/Nurmukhamed
REPODIR=/home/travis/build/Nurmukhamed/www-hdfilm-kz-octopress

cd ${REPODIR}

ls -l

rm -rf public

bundle exec rake generate




