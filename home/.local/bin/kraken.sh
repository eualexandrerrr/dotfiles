#!/bin/bash
# github.com/mamutal91

sshfs -o IdentityFile=/home/mamutal91/.ssh/kraken mamutal91@173.249.49.99:/home/mamutal91/ /media/storage/Kraken

# Future in fstab
#mamutal91@173.249.49.99:/home/mamutal91/kraken  /media/storage/Kraken  fuse.sshfs _netdev,user,idmap=user,transform_symlinks,identityfile=/home/mamutal91/.ssh/kraken,allow_other,default_permissions,uid=USER_ID_N,gid=USER_GID_N 0 0
