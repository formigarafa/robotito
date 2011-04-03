#!/usr/bin/env ruby

# Jabber-SH — SH console via XMPP/Jabber (GTalk)
#
# Jabber-SH allows you to administrate a remote computer via a command line 
# through a Jabber client. It’s like SSH via GoogleTalk! :)
# This is just a hack but it might be usefull sometime to run basic commands
# on a machine that is not accessible via ssh.
#
# Philippe Creux. pcreux/AT/gmail/DOT/com

require 'lib/boot'

JabberShell.new.run