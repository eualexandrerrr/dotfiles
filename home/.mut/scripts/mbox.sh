#!/bin/bash
# github.com/mamutal91

sshfs -o IdentityFile=/home/mamutal91/.ssh/mbox mamutal91@173.249.49.99:/home/mamutal91/ /media/storage/mbox

# Future in fstab
#mamutal91@173.249.49.99:/home/mamutal91/mbox  /media/storage/Kraken  fuse.sshfs _netdev,user,idmap=user,transform_symlinks,identityfile=/home/mamutal91/.ssh/mbox,allow_other,default_permissions,uid=USER_ID_N,gid=USER_GID_N 0 0
