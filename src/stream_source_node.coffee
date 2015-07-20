Node = require './node'
class StreamSource extends Node
  constructor: (stream) ->
    stream.on 'data', (chunk) =>
      @write chunk

    stream.on 'close', () =>
      @end()

    super (tasks, callback) ->
      @push tasks
      callback()

module.exports = StreamSource
