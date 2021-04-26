#!/bin/sh
scp id_rsa.pub root@slave1:~/.ssh/id_rsa.pub
scp id_rsa.pub root@slave2:~/.ssh/id_rsa.pub

cd /root/.ssh
cat id_rsa.pub >> authorized_keys
