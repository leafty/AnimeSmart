# encoding: utf-8

require './os.rb'

if OS.windows?
  require 'win32/dir'
end

module SymlinkLib

  module_function
  
  def create( target, name )
    if OS.windows?
      link = "#{name}.ln".encode "UTF-8"
      File.open( link, 'w' ) do |file|
        file.write( "#{target}\n".encode( "UTF-8" ) )
      end
      return 0
    else
      return File.symlink( target, name )
    end
  end
  
  def read( name )
    if OS.windows?
      file = File.open( name, 'r' )
      line = file.gets
      entry = line[0, line.length - 1]
      file.close
      return entry
    else
      return File.readlink( name )
    end
  end
  
  def delete( name )
    return File.delete( name )
  end

end
