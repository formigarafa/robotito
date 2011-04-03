# Jabber-shell
 Jabber-shell is alternative connection to remote machine terminal.
 
## Main Objective
Sometimes you can not reach an ssh ip:port of an host by a lot of reasons:

* host is behind NAT
* firewall protection
* remote host with dynamic ip
* port redirections
* annoying administrators
  
To avoid these problems there is the Jabber-Shell.
 
## Description
This is a light-weight bot connecting through XMPP (eg.: GTalk) that allow you runnning shell command remotely.
Jabber-Shell will not open an port to be accessed, instead of that, it will connect to a jabber service.
You will send your commands in a chat session and receive terminal output back.
You will keep "talking" to your server like you always had, but this time it will respond to you.

### Requirements

* [bundler](http://rubygems.org/gems/bundler)
* Ruby 1.8.7 _(depends on gems not working with 1.9.2)_

## Thanks
 [Philippe Creux](http://github.com/pcreux) and its [suggestion on gist](https://gist.github.com/258561)
 
 https://gist.github.com/258561