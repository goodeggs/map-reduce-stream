async        = require 'async'
EventEmitter = require('events').EventEmitter

class Node extends EventEmitter
  constructor: (options) ->
    {transform, flush} = options

    if typeof options is 'function'
      transform = options
      options = {}

    # If we have a flush, check that it is a function
    if !!flush and typeof flush isnt 'function'
      throw new Error('flush must be a function that accepts a callback')

    @flush(flush ? (cb) -> cb())
    @sourceCargo = async.cargo transform.bind @

  end: () ->
    _drain = =>
      # First, flush to the sink
      @_flush.call @, (err) =>
        @emit 'error', err if err?

        # We're done writing to sink, so end it.
        @sinkNode?.end()
        @emit 'drain'

    if @sourceCargo.idle() # No tasks, no workers running
      return _drain()

    # There's still tasks in the source, hook up the flush/drain event
    @sourceCargo.drain = ->
      _drain()

  drain: (fn) ->
    @on 'drain', fn
    @on 'error', fn
    @ # return `this` for chaining

  write: (tasks, callback) ->
    callback ?= (error) =>
      @emit 'error', error if error
    @sourceCargo.push tasks, callback

  push: (tasks) ->
    @sinkNode?.write tasks

  pipe: (@sinkNode) ->
    @on 'error', (err) ->
      @sinkNode.emit 'error', err

    # chain the dest Node
    @sinkNode

  # Set a flush callback to be called on the flush event
  flush: (flushCallback) ->
    @_flush = flushCallback

module.exports = Node
