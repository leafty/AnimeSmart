#!/bin/bash

cd=$PWD
cd ..
wd=$PWD
cd $cd

if [ ! -e "$wd/library" ]; then
  ./init.sh
fi

./list_all.sh

mkdir $wd/catalogs 2> /dev/null

if [ ! -e "$wd/tmp/autolist.lock" ]; then
  touch $wd/tmp/autolist.lock
  
  ./auto_list.rb
  rm $wd/tmp/known_dirs
  
  rm $wd/tmp/autolist.lock
fi

if [ ! -e "$wd/tmp/catalog.lock" ]; then
  touch $wd/tmp/catalog.lock
  
  run=false
  timestamp="$wd/tmp/last_update"
  
  date=`stat -c %Y $wd/library`
  
  if [ ! -e "$timestamp" ]; then
    run=true
  else
    last=`stat -c %Y $timestamp`
    if [ "$date" -gt "$last" ]; then
      run=true
    fi
  fi
  
  if [ "$run" = true ]; then
    ./auto_link.rb

    rm -rf $wd/catalogs/*/*
    cp -R $wd/tmp/catalogs/* $wd/catalogs/.
    rm -rf $wd/tmp/catalogs
  fi

  touch $timestamp
  rm $wd/tmp/catalog.lock
fi
