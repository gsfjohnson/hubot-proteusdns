# Description:
#   Interact with Proteus DNS.
#
# Dependencies:
#   proteusdns
#
# Configuration:
#   HUBOT_PROTEUSDNS_URL [required] - url (e.g. https://proteus.example.com)
#   HUBOT_PROTEUSDNS_USER [required] - api user
#   HUBOT_PROTEUSDNS_PASS [required] - api pass
#
# Commands:
#   hubot pdns help - proteus dns commands
#
# Notes:
#
# Author:
#   gfjohnson

BCProtAPI = require 'bcprotapi'

moduledesc = 'ProteusDNS'
modulename = 'pdns'

config =
  host: localhost
  username: example
  password: example
  ssl: false

config.ssl = true if process.env.HUBOT_PROTEUSDNS_SSL
config.host = process.env.HUBOT_PROTEUSDNS_HOST if process.env.HUBOT_PROTEUSDNS_HOST
config.username = process.env.HUBOT_PROTEUSDNS_USER if process.env.HUBOT_PROTEUSDNS_USER
config.password = process.env.HUBOT_PROTEUSDNS_PASS if process.env.HUBOT_PROTEUSDNS_PASS

unless config.username == "example"
  papi = new BCProtAPI config

searchByObjectTypes = (robot, msg, keyword) ->

  # robot.logger.info "searchByObjectTypes: sending request for #{keyword}"
  papi.searchByObjectTypes keyword, (err, res) ->
    if err
      msgout = "#{moduledesc}: error"
      robot.logger.info "#{msgout} [#{msg.envelope.user.name}]"
      return robot.send {room: msg.envelope.user.name}, msgout

    if res === null
      msgout = "#{moduledesc}: no results for `#{keyword}`"
      robot.logger.info "#{msgout} [#{msg.envelope.user.name}]"
      return robot.send {room: msg.envelope.user.name}, msgout
      
    r = []
    for o in res
      switch o.type
        when 'HostRecord'  then r.push "#{o.absoluteName} - #{o.addresses}"
        when 'AliasRecord' then r.push "#{o.name} - #{o.properties}"
        when 'IP4Network'  then r.push "#{o.CIDR} - #{o.name}"
        when 'IP4Address'  then r.push "#{o.address} - #{o.state} - #{o.macAddress}"
        when 'MACAddress'  then r.push "#{o.properties}"
    out = r.join "\n"

    msgout = "#{moduledesc}: ```#{out}```"
    robot.logger.info "#{msgout} [#{msg.envelope.user.name}]"
    return robot.send {room: msg.envelope.user.name}, msgout


module.exports = (robot) ->

  robot.respond /pdns help$/, (msg) ->
    cmds = []
    arr = [
      "#{modulename} search <keyword> - search database"
    ]

    for str in arr
      cmd = str.split " - "
      cmds.push "`#{cmd[0]}` - #{cmd[1]}"

    robot.send {room: msg.message?.user?.name}, cmds.join "\n"

  robot.respond /pdns search (.+)$/i, (msg) ->
    keyword = msg.match[1]

    robot.logger.info "#{moduledesc}: keyword search: #{keyword} [#{msg.envelope.user.name}]"

    return searchByObjectTypes robot, msg, keyword
