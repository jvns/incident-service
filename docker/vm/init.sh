#!/bin/bash

mount -t proc proc /proc

mkdir -p /dev/pts
mount -t devpts devpts /dev/pts
mkdir -p /run/sshd

tini -- /usr/sbin/sshd -D
