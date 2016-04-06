'use strict'

through2  = require('through2')

module.exports = (params, options) ->
  through2.obj (file, enc, cb) ->



    cb null, file