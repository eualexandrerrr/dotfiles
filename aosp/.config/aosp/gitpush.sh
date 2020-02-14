#!/bin/bash
# github.com/mamutal91

# Add remote org/repo and rename branch

echo "Lembre-se!"
echo "git remote add gitpush ssh://git@github.com/aosp-forking/frameworks_base"
echo "git checkout lineage-17.1 && git branch -m ten"

# Adjust the following variables as necessary
REMOTE=gitpush
BRANCH=$(git rev-parse --abbrev-ref HEAD)
BATCH_SIZE=200000

# check if the branch exists on the remote
if git show-ref --quiet --verify refs/remotes/$REMOTE/$BRANCH; then
    # if so, only push the commits that are not on the remote already
    range=$REMOTE/$BRANCH..HEAD
else
    # else push all the commits
    range=HEAD
fi
# count the number of commits to push
n=$(git log --first-parent --format=format:x $range | wc -l)

# push each batch
for i in $(seq $n -$BATCH_SIZE 1); do
    # get the hash of the commit to push
    h=$(git log --first-parent --reverse --format=format:%H --skip $i -n1)
    echo "Pushing $h..."
    git push $REMOTE $h:refs/heads/$BRANCH --force
done
# push the final partial batch
git push $REMOTE HEAD:refs/heads/$BRANCH --force
