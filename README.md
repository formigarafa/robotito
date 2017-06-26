# Robo-TiTO
 Robo-TiTO is an alternative connection to a remote machine terminal.

## Main Objective
Sometimes you cannot reach an ssh ip:port of an host by a lot of reasons:

* host is behind NAT
* firewall protection
* remote host with dynamic ip
* port redirections
* annoying administrators

Robo-TiTO allows you circumvent these problems and execute commands remotelly on your server.

## Get involved
Drop a :+1: or a comment on Robo-TiTO's [Research](https://github.com/formigarafa/robotito/issues/4)

## Description
This is a light-weight bot connecting through XMPP (eg.: GTalk) that allows you run shell command remotely.
Robo-TiTO will not open a port to be accessed, instead of that, it will connect to a jabber service.
You send your commands in a chat session and receive terminal output back.
You will be "talking" to your server like you always did, but now you will get some answers from it.

### Requirements

* Ruby <= 1.8.7 (TODO: review support after update, so far working with 2.4.1 and stuck on init with 1.8.7)
* [bundler](http://rubygems.org/gems/bundler)

### Installation

```
bundle install

# adjust the bot credentials and server settings using the example file provided
cp config/credentials.rb.example credentials.rb
vim config/credentials.rb

# start with
./jabbershd start

# check additional available options with
./jabbershd -h

```

## Thanks
 [Philippe Creux](http://github.com/pcreux) and its [suggestion on gist](https://gist.github.com/258561)

 https://gist.github.com/258561
