JabberShellRoot = File.dirname(__FILE__)

require 'rubygems'
require 'bundler/setup'
require 'xmpp4r-simple'
require 'session'
require 'daemons'

require "#{JabberShellRoot}/gems_patch"
require "#{JabberShellRoot}/../config"
require "#{JabberShellRoot}/jabber_shell"
