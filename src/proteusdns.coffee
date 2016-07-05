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

ProteusDNS = require 'proteusdns'

moduledesc = 'ProteusDNS'
modulename = 'pdns'

config =
  url: "http://localhost"
  username: example
  password: example

config.url = process.env.HUBOT_PROTEUSDNS_URL if process.env.HUBOT_PROTEUSDNS_URL
config.username = process.env.HUBOT_PROTEUSDNS_USER if process.env.HUBOT_PROTEUSDNS_USER
config.password = process.env.HUBOT_PROTEUSDNS_PASS if process.env.HUBOT_PROTEUSDNS_PASS

unless config.username == "example"
  pdns = new ProteusDNS config.url, config.username, config.password

searchByObjectTypes = (robot, msg, keyword) ->

  # robot.logger.info "sq: sending virustotal request for #{url}"
  pdns.searchByObjectTypes keyword, (err, res) ->
    if err
      msgout = "#{moduledesc}: error"
      robot.logger.info "#{msgout} [#{msg.envelope.user.name}]"
      return robot.send {room: msg.envelope.user.name}, msgout

    r = []
    for o in res
      r.push "#{o.name} - #{o.properties}" if o.type == 'IP4Network' or o.type == 'HostRecord' or o.type == 'AliasRecord'
      r.push "#{o.properties}" if o.type == 'IP4Address' or o.type == 'MACAddress'
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
