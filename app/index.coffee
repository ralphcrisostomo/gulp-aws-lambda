'use strict'


gutil     = require('gulp-util')
through2  = require('through2')
aws       = require('aws-sdk')
async     = require('async')
_         = require('lodash')

#
# Ref : http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/Lambda.html
#

API =
  _log : (title,message) ->
    gutil.log("#{gutil.colors.yellow('AWS LAMBDA Function')} '#{gutil.colors.magenta(title)}' :  #{message}")

  uploadToS3 : (S3,lambda_params) ->
    (callback) ->
      return callback null, {} if _.isEmpty(lambda_params.Code.S3Bucket) or _.isEmpty(lambda_params.Code.S3Key) or _.isEmpty(lambda_params.Code.ZipFile)
      API._log(lambda_params.FunctionName,'Uploading to S3...')
      params   =
        Bucket : lambda_params.Code.S3Bucket
        Key    : lambda_params.Code.S3Key
        Body   : lambda_params.Code.ZipFile
      S3.putObject params, (err, result) ->
        callback err, result


  getFunction : (lambda,lambda_params) ->
    (input, callback) ->
      API._log(lambda_params.FunctionName,'Getting function...')

      params          =
        FunctionName  : lambda_params.FunctionName

      lambda.getFunction params, (err, result) ->
        if err?.statusCode is 404
          err    = null
          result = 404
        callback err, result

  createFunction : (lambda,lambda_params) ->
    (input, callback) ->
      return callback null, input if input isnt 404
      API._log(lambda_params.FunctionName,'Creating function...')
      lambda.createFunction lambda_params, (err, result) ->
        callback err, 404

  updateFunctionCode : (lambda,lambda_params) ->
    (input, callback) ->
      return callback null, 404 if input is 404
      API._log(lambda_params.FunctionName,'Updating function code...')
      params            =
        FunctionName    : lambda_params.FunctionName
        Publish         : lambda_params.Publish
        S3Bucket        : lambda_params.Code.S3Bucket
        S3Key           : lambda_params.Code.S3Key
        S3ObjectVersion : lambda_params.Code.S3ObjectVersion
        ZipFile         : lambda_params.Code.ZipFile

      #
      # Remove 'ZipFile' if S3Bucket has value
      #
      params = _.omit params, ['ZipFile','S3ObjectVersion'] if lambda_params.Code.S3Bucket

      lambda.updateFunctionCode params, (err, result) ->
        callback err, result

  updateFunctionConfiguration : (lambda,lambda_params) ->
    (input, callback) ->
      return callback null, 404 if input is 404
      API._log(lambda_params.FunctionName,'Updating function configuration...')
      params            =
        FunctionName    : lambda_params.FunctionName
        Description     : lambda_params.Description
        Handler         : lambda_params.Handler
        MemorySize      : lambda_params.MemorySize
        Role            : lambda_params.Role

      lambda.updateFunctionConfiguration params, (err, result) ->
        callback err, result


module.exports = (aws_credentials, lambda_params) ->
  through2.obj (file, enc, cb) ->

    s3                  = new aws.S3(aws_credentials)
    lambda              = new aws.Lambda(aws_credentials)
    lambda_params       = _.defaults lambda_params,
      FunctionName      : ''
      Description       : 'A short, user-defined function description. Assign a meaningful description as you see fit.'
      Handler           : 'index.handler'
      Runtime           : 'nodejs'
      Role              : undefined
      Timeout           : 10
      MemorySize        : 128
      Publish           : true
      Code              : {}

    lambda_params.Code  = _.defaults lambda_params.Code,
      S3Bucket        : undefined
      S3Key           : undefined
      S3ObjectVersion : undefined
      ZipFile         : file.contents

    lambda_params.Code = _.omit lambda_params.Code, ['ZipFile','S3ObjectVersion'] if lambda_params.S3Bucket

    API._log(lambda_params.FunctionName,'Starting')
    async.waterfall [

      API.uploadToS3(s3,lambda_params)
      API.getFunction(lambda,lambda_params)
      API.createFunction(lambda,lambda_params)
      API.updateFunctionCode(lambda,lambda_params)
      API.updateFunctionConfiguration(lambda,lambda_params)

    ], (err, result) ->
      API._log(lambda_params.FunctionName,'Finished')
      gutil.log(gutil.colors.red(err)) if err
      cb err, file
