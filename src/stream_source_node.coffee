Node = require './node'
class StreamSource extends Node
  constructor: (stream) ->
    stream.on 'data', (chunk) =>
      @write chunk

    stream.on 'close', () =>
      @end()

    stream.on 'error', (err) =>
      @emit 'error', err

    super (tasks, callback) ->
      @push tasks
      callback()

module.exports = StreamSource
