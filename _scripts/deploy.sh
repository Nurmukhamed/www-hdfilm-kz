#!/bin/bash
if [ $TRAVIS_BRANCH == 'master' ] ; then
    # Initialize a new git repo in _site, and push it to our server.
    echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"
    
    cd www-hdfilm-kz-octopress
    git checkout -b gh-pages
    
    cd ..
    
    mv www-hdfilm-kz-octopress/.git git
    
    rsync -avz --delete public/ www-hdfilm-kz-octopress/
    
    mv git www-hdfilm-kz-octopress/.git
    
    # Go To Public folder
    cd www-hdfilm-kz-octopress
    # Add changes to git.
    git add .
    
    # Commit changes.
    msg="rebuilding site `date`"
    if [ $# -eq 1 ]
        then msg="$1"
    fi
    
    git commit -a -m "$msg"

    # Push source and build repos.
    git push -f origin gh-pages

    # Come Back up to the Project Root
    cd ..
    
else
    echo "Not deploying, since this branch isn't master."
fi
