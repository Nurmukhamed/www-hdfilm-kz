#!/bin/bash
if [ $TRAVIS_BRANCH == 'master' ] ; then
    # Initialize a new git repo in _site, and push it to our server.
    echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

    cd gh-pages
    git checkout -b gh-pages
    
    cd ..
    
    rsync -avz --delete public/ gh-pages/
    
    # Go To Public folder
    cd gh-pages
    # Add changes to git.
    git add .

    # Commit changes.
    msg="rebuilding site `date`"
    if [ $# -eq 1 ]
        then msg="$1"
    fi
    
    git commit -a -m "$msg"

    # Push source and build repos.
    git push 

    # Come Back up to the Project Root
    cd ..
    
    git add gh-pages
    git commit -m "Updated gh-pages"
    
else
    echo "Not deploying, since this branch isn't master."
fi
