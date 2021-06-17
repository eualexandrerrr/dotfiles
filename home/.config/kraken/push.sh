#!/usr/bin/env bash
# Adjust the following variables as necessary

pwd=$(pwd)

echo -e '[Push] $ Pushing to or AOSPK-DEV/frameworks_base...'
git remote add push ssh://git@github.com/AOSPK-DEV/frameworks_base

sleep 2

REMOTE=push
BRANCH=$(git rev-parse --abbrev-ref HEAD)
NEWBRANCH=eleven
BATCH_SIZE=20000

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
    git push $REMOTE $h:refs/heads/$NEWBRANCH
done
# push the final partial batch
git push $REMOTE HEAD:refs/heads/$NEWBRANCH

cd $pwd
