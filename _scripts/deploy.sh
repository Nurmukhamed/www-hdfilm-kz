#!/bin/bash
if [ $TRAVIS_BRANCH == 'master' ] ; then
    # Initialize a new git repo in _site, and push it to our server.
    bundle exec rake deploy
else
    echo "Not deploying, since this branch isn't master."
fi
