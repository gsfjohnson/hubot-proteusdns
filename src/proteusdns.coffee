# coffeelint: disable=max_line_length
#
# Description:
#   Interact with Proteus DNS.
#
# Dependencies:
#   proteusdns
#
# Configuration:
#   HUBOT_BCPROTAPI_HOST [required] - url (e.g. proteus.example.com)
#   HUBOT_BCPROTAPI_USER [required] - api user
#   HUBOT_BCPROTAPI_PASS [required] - api pass
#   HUBOT_BCPROTAPI_SSL [optional] - use ssl
#
# Commands:
#   hubot pdns help - proteus dns commands
#
# Notes:
#
# Author:
#   gfjohnson

papi = require 'bcprotapi'

moduledesc = 'ProteusDNS'
modulename = 'pdns'

config =
  host: 'localhost'
  username: 'example'
  password: 'example'
  ssl: false
  keepalives: true
  interation: 0

config.ssl = true if process.env.HUBOT_BCPROTAPI_SSL
config.host = process.env.HUBOT_BCPROTAPI_HOST if process.env.HUBOT_BCPROTAPI_HOST
config.username = process.env.HUBOT_BCPROTAPI_USER if process.env.HUBOT_BCPROTAPI_USER
config.password = process.env.HUBOT_BCPROTAPI_PASS if process.env.HUBOT_BCPROTAPI_PASS

unless config.username == "example"
  papi.connect config

searchByObjectTypes = (robot, msg, keyword) ->

  # robot.logger.info "searchByObjectTypes: sending request for #{keyword}"
  papi.searchByObjectTypes keyword, (err, res) ->
    if err
      if config.iteration < 1 and err is 'Error: env:Server: Not logged in'
        msgout = "#{moduledesc}: connection timeout, attempting reconnect"
        robot.logger.info "#{msgout} [#{msg.envelope.user.name}]"
        robot.send {room: msg.envelope.user.name}, msgout
        papi.connect config, (err, res) ->
          config.iteration += 1
          return searchByObjectTypes robot, msg, keyword
        return
      msgout = "#{moduledesc}: error"
      robot.logger.info "#{msgout} (#{err}) [#{msg.envelope.user.name}]"
      return robot.send {room: msg.envelope.user.name}, "#{msgout}, check hubot log for details"

    config.iteration = 0

    if res is null
      msgout = "#{moduledesc}: no results for `#{keyword}`"
      robot.logger.info "#{msgout} [#{msg.envelope.user.name}]"
      return msg.reply msgout
      
    r = []
    for o in res
      switch o.type
        when 'HostRecord'  then r.push "#{o.absoluteName} - #{o.addresses}"
        when 'AliasRecord' then r.push "#{o.name} - #{o.properties}"
        when 'IP4Network'  then r.push "#{o.CIDR} - #{o.name}"
        when 'IP4Address'  then r.push "#{o.address} - #{o.state} - #{o.macAddress}"
        when 'MACAddress'  then r.push "#{o.properties}"
        when 'NAPTRRecord' then r.push "#{o.properties}"
    out = r.join "\n"

    msgout = "#{moduledesc}: `#{res.length} results`\n```#{out}```"
    robot.logger.info "#{msgout} [#{msg.envelope.user.name}]"
    return msg.reply msgout


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

  robot.respond /pdns s(?:earch)? (.+)$/i, (msg) ->
    keyword = msg.match[1]

    robot.logger.info "#{moduledesc}: keyword search: #{keyword} [#{msg.envelope.user.name}]"

    return searchByObjectTypes robot, msg, keyword
