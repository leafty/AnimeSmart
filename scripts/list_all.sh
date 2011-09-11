#!/bin/bash

cd=$PWD
cd ..
wd=$PWD
cd $cd

mkdir $wd/library 2> /dev/null
mkdir $wd/tmp 2> /dev/null

if [ ! -e "$wd/tmp/list.lock" ]; then
  touch $wd/tmp/list.lock
  
  > $wd/tmp/known_dirs
  
  exec 3<&0
  exec < $wd/config/storage.conf
  
  last_modification=`stat -c %Y $wd/library`
  
  modif=false
  
  while read line; do
    date=`stat -c %Y $line`
    if [ "$date" -gt "$last_modification" ]; then
      modif=true
      ./list_directory.sh $line >> $wd/tmp/known_dirs
    fi
  done
  
  exec 0<&3 3<&-

  if [ "$modif" = true ]; then
    touch $wd/library
  fi
  
  rm $wd/tmp/list.lock
fi
