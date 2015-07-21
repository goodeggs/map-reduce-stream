require 'mocha-sinon'
sinonChai = require 'sinon-chai'
chai = require('chai')
chai.use(sinonChai)
expect = chai.expect
sinon = require 'sinon'


async = require 'async'
{Node} = require '..'

describe 'Node', ->
  describe '::constructor', ->
    {node} = {}

    beforeEach ->
      @sinon.spy(async, 'cargo')
      @sinon.spy(Node::, 'flush')

    it 'accepts a transform', ->
      transform = sinon.spy()
      node = new Node(transform)
      expect(async.cargo).to.have.been.called

    it 'accepts a transform as options', ->
      transform = sinon.spy()
      node = new Node(transform: transform)
      expect(async.cargo).to.have.been.called

    it 'accepts a transform and flush as options', ->
      transform = sinon.spy()
      flush = sinon.stub().yields()
      node = new Node(transform: transform, flush: flush)
      expect(async.cargo).to.have.been.called
      expect(node.flush).to.have.been.calledWith flush

  describe '::flush', ->
    it 'hooks up callback to flush event', ->
      transform = sinon.stub().yields()
      flush = sinon.stub().yields()
      node = new Node(transform)
      node.flush flush
      expect(node._flush).to.eql flush
