#!/bin/bash

cd=$PWD
cd ..
wd=$PWD
cd $cd

mkdir $wd/library 2> /dev/null

sleep 1

exec 3<&0
exec < $wd/config/storage.conf

while read line; do
  touch $line
done

./catalog.sh
