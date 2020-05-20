#!/bin/bash
HOMEDIR=/home/travis/build/Nurmukhamed
REPODIR=/home/travis/build/Nurmukhamed/www-hdfilm-kz-octopress

if [ $TRAVIS_BRANCH == 'master' ] ; then
    # Initialize a new git repo in _site, and push it to our server.
    cd ${REPODIR}
    
    echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"
    
    ls -l ${REPODIR}
    
    ls -l ${HOMEDIR}
    
    mv ${REPODIR}/public ${HOMEDIR}
    
    git checkout -b gh-pages
    mv ${REPODIR}/.git ${HOMEDIR}/git
    
    cd ${HOMEDIR}
    
    rsync -avz --delete ${HOMEDIR}/public/ ${REPODIR}/
    
    mv ${HOMEDIR}/git ${REPODIR}/.git
    
    # Go To Public folder
    cd ${REPODIR}
    # Add changes to git.
    git add .
    
    # Commit changes.
    msg="rebuilding site `date`"
    if [ $# -eq 1 ]
        then msg="$1"
    fi
    
    git commit -a -m "$msg"

    # Change git remote
    git remote set-url origin git@github.com:Nurmukhamed/www-hdfilm-kz-octopress.git
    
    # Push source and build repos.
    git push -f origin gh-pages

    # Come Back up to the Project Root
    cd ..
    
else
    echo "Not deploying, since this branch isn't master."
fi
