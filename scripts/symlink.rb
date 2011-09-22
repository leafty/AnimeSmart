# encoding: utf-8

require './os.rb'

if OS.windows?
  require 'win32/dir'
end

module Symlink

  module_function
  
  def create( target, name )
    if OS.windows?
      return Dir.create_junction( name, target )
    else
      return File.symlink( target, name )
    end
  end
  
  def delete( name )
    if OS.windows?
      return Dir.rmdir( name )
    else
      return File.delete( name )
    end
  end

end
