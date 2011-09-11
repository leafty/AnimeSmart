#!/bin/bash

cd=$PWD
cd ..
wd=$PWD
cd $1
rd=$PWD
cd $cd

tmp="/tmp/list_$(date +%s)"

ls -l $1 > $tmp
#cat $tmp

exec 3<&0
exec < $tmp

lines=0

#Header line ignored
read line

#Retrieve directories
while read line; do
  type=${line:0:1}

  name=`echo $line | sed "s/\w+/ /g"`
  i=7
  while [ "$i" -gt 0 ]; do
    name=${name#* }
    ((i--))
  done

  if [ `expr match "$type" 'd'` -eq "1" ]; then
    array[$lines]=$name
    ((lines++))
  fi
done

i=$lines
while [ "$i" -gt 0 ]; do
  #echo "$i  ${array[$lines-i]}"
  path="$rd/${array[$lines-i]}"
  mkdir $wd/library 2> /dev/null
  echo $path
  #mkdir $wd/tags
  #ln -s "$path" "$wd/library/${array[$lines-$i]}" 2> /dev/null
  #ln -s "$wd/library/${array[$lines-$i]}" "$wd/tags/${array[$lines-$i]}"
  ((i--))
done

exec 0<&3 3<&-

rm $tmp
