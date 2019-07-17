# Publish the b2note_app dist directory into Github Pages as static web for review
cd /home/vagrant/b2note
#git push origin `git subtree split --prefix b2note_app/dist master 2> /dev/null`:gh-pages --force
git subtree push --prefix b2note_app/dist origin gh-pages
