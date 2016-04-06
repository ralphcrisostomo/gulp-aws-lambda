# gulp-aws-lambda
By Ralph Crisostomo - 2016/04/05

#### Description
A Gulp plugin for AWS Lambda deployment.

#### Install
```bash
npm install --save-dev gulp-aws-lambda
```

#### Sample Lambda Params
```javascript
var lambda_params = {
    FunctionName    : 'MyFunctionName',
    Handler         : 'index.handler',              
    Role            : 'arn:aws:iam:xxxxxx',
    Runtime         : 'nodejs',
    Description     : 'Assign a meaningful description as you see fit',
    MemorySize      : 128,
    Timeout         : 10,
    Publish         : true,
    Code            : {
        S3Bucket    : 'my_s3_bucket',
        S3Key       : 'archive.zip'
    }
}
```

#### Basic Usage
```javascript

var gulp            = require('gulp');
var zip             = require('gulp-zip')
var aws_lambda      = require("gulp-aws-lambda");

var lambda_params   = { FunctionName : 'MyFunctionName' };
var aws_credentials = {
    accessKeyId       : '',
    secretAccessKey   : '',
    region            : '',
};

gulp.task('deploy',function(){
    gulp.src(['dist/*'])
    .pipe(zip('archive.zip'))
    .pipe(aws_lambda(aws_credentials, lambda_params))
});
```


#### Basic usage with S3 upload
```javascript

var gulp            = require('gulp');
var zip             = require('gulp-zip')
var aws_lambda      = require("gulp-aws-lambda");

var lambda_params   = { 
    FunctionName    : 'MyFunctionName',
    Code            : {
        S3Bucket    : 'my_s3_bucket',
        S3Key       : 'archive.zip'
    }
};

var aws_credentials = {
    accessKeyId       : '',
    secretAccessKey   : '',
    region            : '',
};

gulp.task('deploy',function(){
    gulp.src(['dist/*'])
    .pipe(zip('archive.zip'))
    .pipe(aws_lambda(aws_credentials, lambda_params))
});
```
