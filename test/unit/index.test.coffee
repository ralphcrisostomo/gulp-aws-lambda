'use strict'

index = require('../../app/index')

describe 'index.coffee', ->
  it 'should return callback', ->
    params  = {}
    options = {}
    expect(index(params,options)).to.be.an('object')