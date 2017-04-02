###
hopsoft\screeps-statsd

Licensed under the MIT license
For full copyright and license information, please see the LICENSE file

@author     Bryan Conrad <bkconrad@gmail.com>
@copyright  2016 Bryan Conrad
@link       https://github.com/hopsoft/docker-graphite-statsd
@license    http://choosealicense.com/licenses/MIT  MIT License
###

###
SimpleClass documentation

@since  0.1.0
###
rp = require 'request-promise'
zlib = require 'zlib'
# require('request-debug')(rp)
StatsD = require 'node-statsd'
token = ""
succes = false
class ScreepsStatsd

  ###
  Do absolutely nothing and still return something

  @param    {string}    string      The string to be returned - untouched, of course
  @return   string
  @since    0.1.0
  ###
  run: ( string ) ->
    rp.defaults jar: true
    @loop()

    setInterval @loop, 15000

  loop: () =>
    @signin()

  signin: () =>
    if(token != "" && succes)
      @getMemory()
      return
    @client = new StatsD host: process.env.GRAPHITE_PORT_8125_UDP_ADDR
    console.log "New login request - " + new Date()
    options =
      uri: 'https://screeps.com/api/auth/signin'
      json: true
      method: 'POST'
      body:
        email: process.env.SCREEPS_EMAIL
        password: process.env.SCREEPS_PASSWORD
    rp(options).then (x) =>
      token = x.token
      @getMemory()

  getMemory: () =>
    succes = false
    options =
      uri: 'https://screeps.com/api/user/memory'
      method: 'GET' 
      json: true
      resolveWithFullResponse: true
      headers:
        "X-Token": token
        "X-Username": token
      qs:
        path: 'stats'
    rp(options).then (x) =>
      # yeah... dunno why
      token = x.headers['x-token']
      return unless x.body.data
      data = x.body.data.split('gz:')[1]
      finalData = JSON.parse zlib.gunzipSync(new Buffer(data, 'base64')).toString()
      succes = true
      @report(finalData)

  report: (data, prefix="") =>
    if prefix is ''
      console.log "Pushing to gauges - " + new Date()
      for k,v of data
      if typeof v is 'object'
        @report(v, prefix+k+'.')
      else
        @client.gauge prefix+k, v

module.exports = ScreepsStatsd
