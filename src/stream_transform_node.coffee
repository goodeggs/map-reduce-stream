Node = require './node'
class StreamTransformNode extends Node
  constructor: (stream) ->
    @stream = stream
    stream.on 'data', (chunk) =>
      # chunk is transformed, push it to the next node
      @push chunk

    stream.on 'error', (err) =>
      @emit 'error', err

    super (tasks, callback) ->
      # Incoming tasks, write them to the stream for transform
      for task in tasks
        stream.write task
      callback()

    @on 'drain', ->
      # No more incoming tasks, end the stream
      stream.end()


module.exports = StreamTransformNode
