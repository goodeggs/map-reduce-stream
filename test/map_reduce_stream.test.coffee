require 'mocha-sinon'
sinonChai = require 'sinon-chai'
chai = require('chai')
chai.use(sinonChai)
expect = chai.expect
sinon = require 'sinon'

mrstream = require '..'

{EventEmitter} = require('events')

describe 'map-reduce-stream', ->

  describe 'single node', ->
    {parent, doWork} = {}
    beforeEach ->
      doWork = sinon.stub().yields()
      parent = new mrstream.Node doWork

    it 'should write tasks to source cargo', (done) ->
      parent.write ['a task'] , (error) ->
        expect(doWork).to.be.called
        done(error)

  describe 'with two Nodes', ->
    { nodeA, nodeB, stub } = {}
    before ->
      nodeA = new mrstream.Node (tasks, cb) ->
        tasks.map (task) =>
          @push(task.toUpperCase())
        cb()

      stub = sinon.stub().yields()
      nodeB = new mrstream.Node stub
      nodeA.pipe nodeB


    it 'should add tasks to the sink cargo', (done) ->
      nodeB.on 'drain', ->
        expect(stub).to.have.been.calledWith ['ABC'], sinon.match.func
        done()
      nodeA.write ['abc']
      nodeA.end()

  describe 'pipline with flush', ->
    it 'calls flush', (done) ->
      toUpperNode = new mrstream.Node (tasks, cb) ->
        tasks.map (task) =>
          @push(task.toUpperCase())
        cb()

      joinNode = new mrstream.Node {
        transform: (tasks, cb) ->
          @_string = tasks.join ' '
          cb()

        flush: (cb) ->
          @push @_string
          cb()
      }

      stub = sinon.stub().yields()
      sinkNode = new mrstream.Node stub

      toUpperNode.pipe(joinNode).pipe(sinkNode).drain ->
        expect(stub).to.have.been.calledWith ['A B C D E F G H I J K L M N O P Q R S T U V W X Y Z']
        done()


      process.nextTick ->
        # Write characters of the alphabet, a, b, c, ...
        for i in [97..122]
          toUpperNode.write String.fromCharCode(i)

        toUpperNode.end()
