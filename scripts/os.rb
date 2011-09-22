require 'rbconfig'

module OS
  class << self
    def is?(what)
      what === RbConfig::CONFIG['host_os']
    end
    alias is is?

    def to_s
      RbConfig::CONFIG['host_os']
    end
  end

  module_function

  def windows?
    @windows ||= OS.is? /mswin|win|mingw/
  end
end
