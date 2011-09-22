# encoding: utf-8

require 'yaml'
require './init.rb'
require './symlink.rb'
require './symlink_lib.rb'

class Catalog

  def self.create
    #tmp_dir = File.absolute_path '../tmp'
    library = get_library
    
    #if Init.check_dir tmp_dir
      @conf.each_key do |key|
        catalog = build_catalog @conf[key]
        catalog_conf = { :name => key, :chroot => @conf[key]['chroot'], :tag_order => @conf[key]['tag-order'] }
        build_links( catalog_conf, catalog, library )
      end
    #end
  end

  private
    
    @conf = YAML::load( File.open( '../config/catalogs.yml' ) )
    @aliases = YAML::load( File.open( '../config/aliases.yml' ) )
    
    @tag_regex = /(\[\w*:\w*\])(.*)/
    @tag_regex2 = /\[(\w*):(\w*)\]/
    
    def self.build_catalog_r( conf, tags, catalog )
      new_tags = Array.new( tags )

      if conf.class == {}.class
        conf.each do |key, value|
          new_tags.insert( -1, key )
          catalog.insert( -1, new_tags )
          build_catalog_r( value, new_tags, catalog )
        end
      elsif conf.class == [].class
        conf.each do |value|
          build_catalog_r( value, tags, catalog )
        end
      elsif conf.class == "".class
        new_tags.insert( -1, conf )
        catalog.insert( -1, new_tags )
      end
    end

    def self.build_catalog conf
      catalog = []
      catalog.insert( -1, [] ) if conf['files-in-root']
      build_catalog_r( conf['show'], [], catalog )
      return catalog
    end

    def self.get_catalog_path( conf_path, file )
      catalog_path = []
      
      conf_path.each do |tag|
        catalog_path.insert( -1, "0_Sorted by #{tag}" )
        tag_value = file[:tags][tag.to_sym] || "Other"
        catalog_path.insert( -1, tag_value )
      end
      
      return catalog_path
    end

    def self.build_path( catalog_name, path, clean = false )
      catalogs_dir = File.absolute_path '../catalogs'
      dir = File.absolute_path( catalog_name, catalogs_dir )
      Dir.mkdir catalogs_dir unless File.exist? catalogs_dir
      Dir.mkdir dir unless File.exist? dir

      clean_dir dir if clean && File.exist?( dir )
      
      path.each do |subdir|
        dir = File.absolute_path( subdir, dir )
        clean_dir dir if clean && File.exist?( dir )
        Dir.mkdir dir unless File.exist? dir
      end
      
      return dir
    end
    
    def self.clean_dir( dir )
      d = Dir.new dir
      d.each do |file|
        if file!= '.' && file != '..'
          path = File.absolute_path( file, dir )
          begin
            Symlink.delete( path )
          rescue SystemCallError
          end
        end
      end
    end

    def self.resolve_alias tag
      return @aliases[tag] || tag
    end

    def self.get_tags filename
      h = { :name => filename, :tags => {} }
      
      h[:name] = File.basename( filename, '.ln' ) if OS.windows?
      
      if m = @tag_regex.match( filename )
        tag = m[1]
        if m2 = @tag_regex2.match( tag )
          tag_key = m2[1]
          tag_value = m2[2]
        end
        
        h = get_tags m[2]
        key = resolve_alias tag_key
        h[:tags][key.to_sym] = tag_value unless tag_key.nil?
      end
      
      h[:filename] = filename
      
      return h
    end

    def self.get_library
      lib_dir = File.absolute_path '../library'
      dir = Dir.new lib_dir
      lib = []
      
      dir.each do |file|
        if file != '.' && file != '..'
          h = get_tags file
          link = File.absolute_path( h[:filename], lib_dir )
          h[:path] = SymlinkLib.read link
          lib.insert( -1, h )
        end
      end
      
      return lib
    end

    def self.truncate_chroot( chroot, path )
      if !chroot.nil?
        regex = Regexp.new( "\\A#{Regexp.escape( chroot )}(.*)" )
        if m = regex.match( path )
          return m[1]
        end
      end

      return path
    end

    def self.get_link_name( file, tag_order )
      tags = ""
      tag_order ||= []
      tag_order.each do |tag|
        full_tag = resolve_alias tag
        tag_value = file[:tags][full_tag.to_sym]
        tags = "#{tags}[#{tag_value}]" unless tag_value.nil?
      end
      
      return "#{tags}#{file[:name]}"
    end

    def self.build_links( conf, catalog, library )
    catalog.each do |location|
      catalog_path = get_catalog_path( location, get_tags( "" ) )
      build_path( conf[:name], catalog_path, true )
    end
    
      library.each do |file|
        lang = file[:tags][:lang] || "Other"
      
        catalog.each do |location|
          catalog_path = get_catalog_path( location, file )
          link_path = build_path( conf[:name], catalog_path )
          link_name = get_link_name( file, conf[:tag_order] )
          link = "#{link_path}/#{link_name}"
          path = truncate_chroot( conf[:chroot], file[:path] )
          path = path.force_encoding "UTF-8"
          path = path.encode "Windows-1252" if OS.windows?
          
          Symlink.create( path, link ) unless File.exist? link
        end
      end
    end

end
