#!/usr/bin/ruby

def get_dir_list
  list = []
  
  file = File.open( "../tmp/known_dirs" )
  
  while (line = file.gets)
    list.insert( -1, line[0, line.length - 1] )
  end
  
  file.close
  
  return list
end

def get_library
  dir = Dir.new( File.expand_path("../library") )
  lib = []

  dir.each do |file|
    if file != "." && file != ".."
      path = File.readlink "#{dir.path}/#{file}"
      lib.insert( -1, { :name => file, :path => path } )
    end
  end

  return lib
end

def search_in_lib(file, lib)
  lib.each do |entry|
    if file == entry[:path]
      return nil
    end
  end

  return File.split( file )[1]
end

lib = get_library
list = get_dir_list

list.each do |file|
  name = search_in_lib( file, lib )
  link = "#{File.expand_path("../library")}/#{name}"
  File.symlink( file, link ) unless name.nil?
end
