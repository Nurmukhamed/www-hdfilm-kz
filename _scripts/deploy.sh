#!/bin/bash
if [ $TRAVIS_BRANCH == 'master' ] ; then
    # Initialize a new git repo in _site, and push it to our server.
    echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"
    
    git config --global push.default gh-pages
    
    cd www-hdfilm-kz-hugo
    git checkout -b gh-pages
    
    cd ..
    
    mv www-hdfilm-kz-hugo/.git .git
    
    rsync -avz --delete public/ www-hdfilm-kz-hugo/
    
    mv .git www-hdfilm-kz-hugo/.git
    
    # Go To Public folder
    cd www-hdfilm-kz-hugo
    # Add changes to git.
    git add .
    git stash save
    git pull -r
    git stash pop
    
    # Commit changes.
    msg="rebuilding site `date`"
    if [ $# -eq 1 ]
        then msg="$1"
    fi
    
    git commit -a -m "$msg"

    # Push source and build repos.
    git push -r

    # Come Back up to the Project Root
    cd ..
    
else
    echo "Not deploying, since this branch isn't master."
fi
