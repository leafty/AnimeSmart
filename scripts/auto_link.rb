#!/usr/bin/ruby

require 'yaml'

tree = YAML::load( File.open( "../config/catalogs.yml" ) )
@aliases = YAML::load( File.open( "../config/aliases.yml" ) )

def build_catalog_r(conf, tags, catalog)
  new_tags = Array.new(tags)

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

def build_catalog conf
  catalog = []
  catalog.insert( -1, [] ) if conf['files-in-root']
  build_catalog_r( conf['show'], [], catalog )
  return catalog
end

def get_catalog_path(conf_path, file)
  catalog_path = []
  
  conf_path.each do |tag|
    catalog_path.insert( -1, "0_Sorted by #{tag}" )
    tag_value = file[:tags][tag.to_sym] || "Other"
    catalog_path.insert( -1, tag_value )
  end
  
  return catalog_path
end

def build_path(catalog_name, path)
  dir = "../tmp/catalogs/#{catalog_name}"
  Dir.mkdir "../tmp/catalogs" unless File.exist? "../tmp/catalogs"
  Dir.mkdir dir unless File.exist? dir
  
  path.each do |subdir|
    dir = "#{dir}/#{subdir}"
    Dir.mkdir dir unless File.exist? dir
  end
  
  return dir
end

def tag_regex 
  return /(\[\w*:\w*\])(.*)/
end

def tag_regex2
  return /\[(\w*):(\w*)\]/
end

def resolve_alias tag
  return @aliases[tag] || tag
end

def get_tags filename
  h = { :name => filename, :tags => {} }
  
  if m = tag_regex.match(filename)
    tag = m[1]
    if m2 = tag_regex2.match(tag)
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

def get_library
  dir = Dir.new( File.expand_path("../library") )
  lib = []
  
  dir.each do |file|
    if file != "." && file != ".."
      h = get_tags file
      link = File.expand_path "../library/#{h[:filename]}"
      h[:path] = File.readlink link
      lib.insert( -1, h )
    end
  end
  
  return lib
end

def truncate_chroot(chroot, path)
  if !chroot.nil?
    regex = Regexp.new( "\\A#{Regexp.escape(chroot)}(.*)" )
    if m = regex.match(path)
      return m[1]
    end
  end

  return path
end

def get_link_name(file, tag_order)
  tags = ""
  tag_order ||= []
  tag_order.each do |tag|
    full_tag = resolve_alias tag
    tag_value = file[:tags][full_tag.to_sym]
    tags = "#{tags}[#{tag_value}]" unless tag_value.nil?
  end
  
  return "#{tags}#{file[:name]}"
end

def build_links(conf, catalog, library)
  library.each do |file|
    lang = file[:tags][:lang] || "Other"
  
    catalog.each do |location|
      catalog_path = get_catalog_path( location, file )
      link_path = build_path( conf[:name], catalog_path )
      link_name = get_link_name( file, conf[:tag_order] )
      link = "#{link_path}/#{link_name}"
      path = truncate_chroot( conf[:chroot], file[:path] )
      File.symlink( path, link ) unless File.symlink? link
    end
  end
end

library = get_library

Dir.mkdir "../tmp" unless File.exist? "../tmp"

tree.each_key do |key|
  catalog = build_catalog tree[key]
  conf = { :name => key, :chroot => tree[key]['chroot'], :tag_order => tree[key]['tag-order'] }
  build_links( conf, catalog, library )
end
