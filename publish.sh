git checkout master

rm -r blog
cp -r ~/Dropbox/_/notes/blog/ ~/ws/blog/blog
for OLD in blog/*.md ; do
    NEW=`echo $OLD | sed -e 's/^blog\/[0-9]*\./blog\//'`
    mv -v $OLD $NEW
done

LAST_COMMIT=`git log --pretty=format:"%s" -1`
COMMIT="Update $(date +%Y-%m-%d)"
if [ "$LAST_COMMIT" == "$COMMIT" ]; then
    git add -A
    git commit --amend -m "$COMMIT"
else
    git add -A
    git commit -m "$COMMIT"
fi

git checkout publish
git rebase master
rm -r blog
git checkout master -- blog
git rebase --skip
gitbook install && gitbook build

if [ `ls _book/*.md` ]; then
    echo "There are .md files in _book. Please fix SUMMARY.md."
    ls _book/*.md
else
    git add -A
    git commit --amend -m "Publish to Heroku"
    git push -f origin master publish
    git checkout master
fi
