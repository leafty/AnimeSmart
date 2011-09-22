# encoding: utf-8

require './os.rb'

class DirList

  attr_accessor :dir
  
  def initialize( dir )
    @dir = File.absolute_path dir
    @dir = @dir.encode "Windows-1252" if OS.windows?
  end
  
  def subdirs
    if File.directory? @dir
      list = []
      
      d = Dir.new @dir
      d.each do |file|
        path = File.absolute_path( file, @dir )
        list.insert( -1, path ) if File.directory?( path ) && file != '.' && file != '..'
      end
      
      return list
    else
      return nil
    end
  end

end
