#!/usr/bin/env bash
# Adjust the following variables as necessary

source $HOME/.myTokens/tokens.sh &> /dev/null
source $HOME/.Xcolors &> /dev/null

repo=frameworks_base
repoPath=frameworks/base

git remote remove push &> /dev/null

if [[ -z "$1" ]]; then
  echo "${BOL_RED}\$1${BOL_YEL} org não existe"
  exit 1
fi

if [[ -z "$2" ]]; then
  echo "${BOL_RED}\$2${BOL_YEL} branch não existe"
  exit 1
fi

org=$1
branch=$2

echo "${BOL_GRE}${org} - ${branch}${END}"

git remote add push ssh://git@github.com/${org}/${repo}

REMOTE=push
BRANCH=$(git rev-parse --abbrev-ref HEAD)
BATCH_SIZE=50000 # default: 20000

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
    git push $REMOTE $h:refs/heads/$branch --force
done
# push the final partial batch
git push $REMOTE HEAD:refs/heads/$branch --force
