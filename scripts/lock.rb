# encoding: utf-8

class Lock

  def self.lock
    if File.exist? @flock
      puts "Lock: #{@flock} exists"
      return false
    else
      File.open( @flock, 'w') do |f|
        f.write( "\n" )
      end
      return true
    end
  end
  
  def self.unlock
    File.delete( @flock ) if File.exist? @flock
  end

  private
  
    @flock = File.absolute_path '../tmp/AnimeSmart.lock'
  
end
