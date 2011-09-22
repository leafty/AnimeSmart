# encoding: utf-8

require 'yaml'
require './os.rb'
require './symlink_lib.rb'
require './dir_list.rb'

class Library

  def self.update
    stor = self.list_storage
    lib = self.list_library
    
    comp = self.compare_lists( stor, lib )
    self.update_library comp
    
    return comp[:lib]
  end
  
  private
  
    @storage_conf = YAML::load( File.open( "../config/storage.yml" ) )
    
    def self.list_storage
      stores = @storage_conf['storage']
      list = []
      
      stores.each do |store|
        d = DirList.new( store )
        list.concat( d.subdirs )
      end
      
      return list
    end
    
    def self.list_library
      list = []
      
      lib_dir = File.absolute_path '../library'
      
      d = Dir.new lib_dir
      d.each do |file|
        if file != '.' && file != '..'
          file_path = File.absolute_path( file, lib_dir )
          target = SymlinkLib.read( file_path )
          list.insert( -1, target )
        end
      end
      
      return list.map { |file| file.force_encoding "UTF-8" }
    end
    
    def self.compare_lists( stor, lib )
      comp = { :add => [], :del => [], :lib => [] }
      
      stor.each do |entry|
        file = entry.encode "UTF-8"
        
        comp[:lib].insert( -1, file )
      
        if lib.delete( file ).nil?
         comp[:add].insert( -1, entry )
         
         puts "+ #{file}"
        end
      end
      
      comp[:del] = lib
      lib.each do |file|
        puts "- #{file}"
      end
      
      return comp
    end
    
    def self.update_library( compare )
      lib_dir = File.absolute_path '../library'
    
      compare[:add].each do |file|
        link = File.basename file
        link_path = File.absolute_path( link, lib_dir )
        link_path = link_path.encode "Windows-1252" if OS.windows?
        SymlinkLib.create( file, link_path )
      end
      
      compare[:del].each do |file|
        link = File.basename file
        link_path = File.absolute_path( link, lib_dir )
        link_path = link_path.encode "Windows-1252" if OS.windows?
        SymlinkLib.delete( link_path ) if File.exist? link_path
      end
    end
  
end
