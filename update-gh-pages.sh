echo -e "Starting to update gh-pages\n"

cp -R coverage $HOME/coverage

cd $HOME
git config --global user.email "travis@travis-ci.org"
git config --global user.name "TullerVal"

git clone --quiet --branch=gh-pages https://cf75effcf9d0ba6e5fdb3d7d6158f1a8e4054e7e@github.com/TullerVal/SharedTravisLogs.git gh-pages

date
cd gh-pages
if [ "$1" = "1" ]; then mkdir `date +%Y.%m.%d_%H.%M_№$TRAVIS_BUILD_NUMBER`_fail; cd `date +%Y.%m.%d_%H.%M_№$TRAVIS_BUILD_NUMBER`_fail; else mkdir `date +%Y.%m.%d_%H.%M_№$TRAVIS_BUILD_NUMBER`_ok; cd `date +%Y.%m.%d_%H.%M_№$TRAVIS_BUILD_NUMBER`_ok; fi

ls -all
rm -R *
cp -Rf $HOME/coverage/* .
cd ..

#add, commit and push files
git add -f .
git commit -m "Travis build $TRAVIS_BUILD_NUMBER pushed to gh-pages (branch $TRAVIS_BRANCH, commit $TRAVIS_COMMIT (build number $TRAVIS_BUILD_NUMBER))"
git push -fq origin gh-pages

echo -e "Done magic with coverage\n"
