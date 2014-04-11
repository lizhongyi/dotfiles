require 'pp'

unless defined? Rails
  require 'active_support'
  require 'active_support/core_ext'
  require 'awesome_print'
  require 'hirb'
  require 'looksee'
end

# Useful aliases.
alias :q :exit
alias :q! :exit!
alias :r :require
alias :l :load

class Object
  # Return a list of methods defined locally for a particular object.
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end

  # Similar to `local_methods` minus the constructors, etc.
  def interesting_methods
    case self.class
    when Class then self.public_methods.sort - Object.public_methods
    when Module then self.public_methods.sort - Module.public_methods
    else
      self.public_methods.sort - Object.new.public_methods
    end
  end

  if defined? Hirb
    def hirb?
      Hirb::View.enabled?
    end

    # Adds shortcut to enable or disable Hirb from within the console.
    def hirb
      if Hirb::View.enabled?
        Hirb::View.disable
        "Hirb has been disabled."
      else
        Hirb::View.enable
        "Hirb has been enabled."
      end
    end
    alias :hirb! :hirb
  end
end

if defined? Rails
  # Enable route helpers in Rails console
  include Rails.application.routes.url_helpers

  # run an ad-hoc sql query
   def sql(query)
     ActiveRecord::Base.connection.select_all(query)
   end

  module Rails
    module ConsoleMethods
      alias :rl :reload!
      alias :rl! :reload!
    end
  end

end

