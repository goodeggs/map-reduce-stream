async        = require 'async'
EventEmitter = require('events').EventEmitter

class Node extends EventEmitter
  constructor: (@doWork) ->
    @sourceCargo = async.cargo @doWork.bind @
  end: () ->
    @emit 'drain' if @sourceCargo.length() is 0
    @sourceCargo.drain = =>
      @sinkNode?.end()
      @emit 'drain'
  drain: (fn) ->
    @on 'drain', fn
    @
  write: (tasks, callback) ->
    callback ?= (error) =>
      @emit 'error', error if error
    @sourceCargo.push tasks, callback
  push: (tasks) ->
    @sinkNode?.write tasks
  pipe: (@sinkNode) ->
    # chain the dest stream
    @sinkNode

module.exports = Node
