###
hopsoft\screeps-statsd

Licensed under the MIT license
For full copyright and license information, please see the LICENSE file

@author     Bryan Conrad <bkconrad@gmail.com>
@copyright  2016 Bryan Conrad
@copyright  2017 Ross Perkins
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
    #console.log "ENV = " + JSON.stringify(process.env)
    if process.env.SCREEPS_BASIC_AUTH == 1
      @signinBasicAuth()
      return
    @client = new StatsD host: process.env.GRAPHITE_PORT_8125_UDP_ADDR
    options =
      uri: process.env.SCREEPS_HOSTNAME + '/api/auth/signin'
      json: true
      method: 'POST'
      body:
        email: process.env.SCREEPS_EMAIL
        password: process.env.SCREEPS_PASSWORD
    console.log "New login request - " + options.uri + " - " + new Date()
    rp(options).then (x) =>
      token = x.token
      @getMemory()

  ###
  Sign-in using HTTP Basic Authentication (username & password).
  This non-standard way of signing in is used by some private server
  auth-mods. This can be disabled/enable via env-variables (see README).
  ###
  signinBasicAuth: () =>
    @client = new StatsD host: process.env.GRAPHITE_PORT_8125_UDP_ADDR
    options =
      uri: process.env.SCREEPS_HOSTNAME + '/api/auth/signin'
      json: true
      method: 'POST'
    console.log "New login request via HTTP Basic - " + options.uri + " - " + new Date()
    rp(options).auth(process.env.SCREEPS_USERNAME, process.env.SCREEPS_PASSWORD, true).then (x) =>
      token = x.token
      @getMemory()

  getMemory: () =>
    succes = false
    apiEndpoint = '/api/user/memory'
    fromSegment = process.env.SCREEPS_STATS_SOURCE && process.env.SCREEPS_STATS_SOURCE != 'memory'
    if fromSegment
      apiEndpoint = '/api/user/memory-segment?' + process.env.SCREEPS_STATS_SOURCE
    options =
      uri: process.env.SCREEPS_HOSTNAME + apiEndpoint
      method: 'GET'
      json: true
      resolveWithFullResponse: true
      headers:
        "X-Token": token
        "X-Username": token
    # segment api doesn't support limiting scope to 'stats' element
    if not fromSegment
      options.qs =
        path: 'stats'
    #console.log "Using request options: " + JSON.stringify(options)
    rp(options).then (x) =>
      # yeah... dunno why
      token = x.headers['x-token']
      return unless x.body.data
      succes = true
      if fromSegment
        # segments come as plain text, not deflated
        finalData = JSON.parse x.body.data
        # Use only the 'stats' data from this segment, in case there is other stuff
        @report(finalData.stats)
      else
        # memory comes deflated, first 3 chars "gz:" to indicate the deflation
        data = x.body.data.substring(3)
        finalData = JSON.parse zlib.inflateSync(new Buffer(data, 'base64')).toString()
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
