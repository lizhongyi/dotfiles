require '~/.sharedrc.rb'

IRB.conf[:USE_READLINE] = true
IRB.conf[:AUTO_INDENT]  = true

# Save History between irb sessions
require 'irb/ext/save-history'
IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = "~/.irb_history"

# Enable colored output
require 'wirble'
Wirble.init
Wirble.colorize

# ASCII table views
Hirb.disable
extend Hirb::Console

# Bash-like tab completion
require 'bond'; Bond.start

# Enable awesome print
AwesomePrint.irb! if defined? AwesomePrint
