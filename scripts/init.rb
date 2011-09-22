# encoding: utf-8

module Init

  module_function
  
  def check_dirs
    dirs = []
    dirs.insert( -1, File.absolute_path( '../library' ) )
    dirs.insert( -1, File.absolute_path( '../catalogs' ) )
    dirs.insert( -1, File.absolute_path( '../tmp' ) )
    
    ok = true
    
    dirs.each do |dir|
      ok = ok && check_dir( dir )
    end
    
    return ok
  end
  
  def check_dir( dir_name )
    if !File.exist? dir_name
      puts "Creating #{dir_name} directory..."
      Dir.mkdir dir_name
      return true
    elsif !File.directory? dir_name
      puts "#{dir_name} is not a directory!"
      return false
    else
      return true
    end
  end
  
end
