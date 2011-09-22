#!/usr/bin/ruby
# encoding: utf-8

require './init.rb'
require './lock.rb'
require './library.rb'
require './catalog.rb'

lock = Lock.lock

if lock
  init = Init.check_dirs
  
  if init
    Library.update
    Catalog.create
  end
  
  Lock.unlock
end
