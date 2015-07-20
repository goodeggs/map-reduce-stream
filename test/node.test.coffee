require 'mocha-sinon'
sinonChai = require 'sinon-chai'
chai = require('chai')
chai.use(sinonChai)
expect = chai.expect

{Node} = require '..'

{EventEmitter} = require('events')
sinon = require 'sinon'

describe 'Node', ->
  {parent, doWork} = {}

  beforeEach ->
    doWork = sinon.stub().yields()
    parent = new Node doWork

  it 'should write tasks to source cargo', (done) ->
    parent.write ['a task'] , (error) ->
      expect(doWork).to.be.called
      done(error)

  describe 'with two Nodes', ->
    { nodeA, nodeB, stub } = {}
    before ->
      nodeA = new Node (tasks, cb) ->
        tasks.map (task) =>
          @push(task.toUpperCase())
        cb()

      stub = sinon.stub().yields()
      nodeB = new Node stub
      nodeA.pipe nodeB


    it 'should add tasks to the sink cargo', (done) ->
      nodeB.on 'drain', ->
        expect(stub).to.have.been.calledWith ['ABC'], sinon.match.func
        done()
      nodeA.write ['abc']
      nodeA.end()
