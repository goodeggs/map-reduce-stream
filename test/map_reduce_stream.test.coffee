require 'mocha-sinon'
sinonChai = require 'sinon-chai'
chai = require('chai')
chai.use(sinonChai)
expect = chai.expect

mrstream = require '..'

{EventEmitter} = require('events')
sinon = require 'sinon'

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
