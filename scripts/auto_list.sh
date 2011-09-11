#!/bin/bash

cd=$PWD
cd ..
wd=$PWD
cd $cd

mkdir $wd/library 2> /dev/null

exec 3<&0
exec < ../config/storage.txt

last_modification=`stat -c %Y $wd/library`

while read line; do
  date=`stat -c %Y $line`
  if [ "$date" -gt "$last_modification" ]; then
    ./list_all.sh $line
  fi
done

exec 0<&3 3<&-

touch $wd/library
