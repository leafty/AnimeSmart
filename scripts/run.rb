#!/usr/bin/ruby1.9.1
# encoding: utf-8

require './init.rb'
require './lock.rb'
require './library.rb'
require './catalog.rb'

init = Init.check_dirs

if init
  lock = Lock.lock
  
  if lock
    Library.update
    Catalog.create
    Lock.unlock
  end
end
