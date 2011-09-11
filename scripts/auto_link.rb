#!/usr/bin/ruby

require 'yaml'

tree = YAML::load( File.open( "../config/conf.yml" ) )

def list_children(tree, tags)
  new_tags = Array.new(tags)
  
  if tree.class == {}.class
    tree.each do |key, value|
      #puts key
      new_tags.insert(-1, key)
      build_directory new_tags
      list_children(value, new_tags)
    end
  elsif tree.class == [].class
    tree.each do |value|
      #new_dir = "#{dir}/#{value}"
      list_children(value, tags)
    end
  elsif tree.class == "".class
    #puts tree
    new_tags.insert(-1, tree)
    #puts new_dir
    build_directory new_tags
  end
end

def build_directory tags
  puts tags.inspect
end

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
  build_catalog_r( conf, [], catalog )
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
  dir = "../tmp/#{catalog_name}"
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

def get_tags filename
  h = { :name => filename, :tags => {} }
  
  if m = tag_regex.match(filename)
    tag = m[1]
    if m2 = tag_regex2.match(tag)
      tag_key = m2[1]
      tag_value = m2[2]
    end
    
    h = get_tags m[2]
    h[:tags][tag_key.to_sym] = tag_value unless tag_key.nil?
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

#list_children(tree, [])

def build_links(conf, catalog, library)
  library.each do |file|
    lang = file[:tags][:lang] || "Other"
  
    catalog.each do |location|
      catalog_path = get_catalog_path( location, file )
      link = "#{build_path( conf[:name], catalog_path )}/#{file[:name]}"
      path = truncate_chroot( conf[:chroot], file[:path] )
      File.symlink( path, link ) unless File.exist? link
    end
  end
end

library = get_library

p tree

Dir.mkdir "../tmp" unless File.exist? "../tmp"

tree.each_key do |key|
  catalog = build_catalog tree[key]['show']
  chroot = tree[key]['chroot']
  conf = { :name => key, :chroot => chroot }
  build_links( conf, catalog, library )
end
