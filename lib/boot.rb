JabberShellRoot = ::File.expand_path('../..',  __FILE__)

require 'rubygems'
require 'bundler/setup'
require 'xmpp4r-simple'
require 'session'
require 'daemons'

require "#{JabberShellRoot}/config/credentials"
require "#{JabberShellRoot}/lib/gems_patch"
require "#{JabberShellRoot}/lib/jabber_shell"
