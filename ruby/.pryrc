require '~/.sharedrc'

Pry.config.auto_indent = true
Pry.config.theme = "monokai"

# Nice prompt
Pry.config.prompt = proc do |obj, level, _|
  prompt = ""
  prompt << "#{Rails.application.class.parent_name} " if defined?(Rails)
  prompt << "(#{RUBY_VERSION}"
  prompt <<
    if defined?(Rails)
      "@#{Rails.version})"
    else
      ")"
    end

  "#{prompt}[#{obj}]> "
end

# Use same history file for pry and irb
Pry.config.history.file = "~/.irb_history"

# Aliases
Pry.config.commands.alias_command 'w', 'whereami'
Pry.config.commands.alias_command '.clr', '.clear'

default_command_set = Pry::CommandSet.new do
  command "copy", "Copy argument to the clip-board" do |str|
     IO.popen('pbcopy', 'w') { |f| f << str.to_s }
  end

  command "clear" do
    system 'clear'
    if ENV['RAILS_ENV']
      output.puts "Rails Environment: " + ENV['RAILS_ENV']
    end
  end

  command "sql", "Send sql over AR." do |query|
    if ENV['RAILS_ENV'] || defined?(Rails)
      pp ActiveRecord::Base.connection.select_all(query)
    else
      pp "No rails env defined"
    end
  end

  command "caller_method" do |depth|
    depth = depth.to_i || 1
    if /^(.+?):(\d+)(?::in `(.*)')?/ =~ caller(depth+1).first
      file   = Regexp.last_match[1]
      line   = Regexp.last_match[2].to_i
      method = Regexp.last_match[3]
      output.puts [file, line, method]
    end
  end
end

Pry.config.commands.import default_command_set

# Settings for awesome_print.
if defined? AwesomePrint
  AwesomePrint.pry!
  Pry.config.print = proc { |output, value| output.puts value.ai }
end

# Allows Hirb to work with pry (instead of irb).
if defined? Hirb
  class Object

    Hirb::View.instance_eval do
      def enable_output_method
        @output_method = true
        Pry.config.print = proc do |output, value|
          Hirb::View.view_or_page_output(value) || Pry::DEFAULT_PRINT.call(output, value)
        end
      end

      def disable_output_method
        Pry.config.print = proc { |output, value| Pry::DEFAULT_PRINT.call(output, value) }
        @output_method = nil
      end
    end
  end
end

# Install and require an appropriate debugger for Pry when NOT using Rails.
unless defined? Rails
  begin
    debugger_gem = RUBY_VERSION.to_f < 2.0 ? 'pry-debugger' : 'pry-byebug'
    gem debugger_gem
  rescue LoadError
    system "gem install #{debugger_gem}"
    Gem.clear_paths
  end
  require debugger_gem
end

# Aliases for pry-debugger. Not needed for pry-byebug.
if defined? PryDebugger
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'f', 'finish'
end
