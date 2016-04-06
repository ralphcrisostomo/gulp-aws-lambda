gulp        = require('gulp')
clean       = require('gulp-clean')
coffee      = require('gulp-coffee')
uglify      = require('gulp-uglify')
coffeelint  = require('gulp-coffeelint')
mocha       = require('gulp-mocha')
runSequence = require('run-sequence')
_           = require('lodash')
path        = require('path')
rootPath    = path.normalize(__dirname + '/../..')

dir     =
  app   : './app'
  dist  : './dist'
  test  : './test'


gulp.task 'clean', ->
  gulp.src ['./dist'], {read: false}
    .pipe clean()

gulp.task 'coffeelint', ->
  gulp.src [
    './**/*.coffee'
    '!./node_modules/**'
  ]
    .pipe coffeelint
      max_line_length :
        level : 'ignore'
    .pipe coffeelint.reporter('default')


gulp.task 'coffee', ->
  gulp.src "#{dir.app}/**/*.coffee"
  .pipe coffee({bare: true})
  .pipe uglify({mangle: true})
  .pipe gulp.dest "#{dir.dist}"


# Public Tasks
# ------------------------------
gulp.task 'default', ->
  console.log ''
  console.log 'Public Tasks'
  console.log '------------'
  console.log ''
  console.log '  gulp build \t\t\t - Build `/app` and put into `/dist` directory.'
  console.log '  gulp release \t\t\t - Run this on release branch.'
  console.log '  gulp test \t\t\t - Alias for `gulp test:unit`.'
  console.log '  gulp test:unit \t\t - Unit test everything inside `/app` directory.'
  console.log '  gulp test:integration \t - Integration testing.'
  console.log ''


gulp.task 'test', ['test:unit']
gulp.task 'test:unit', ['coffeelint'], ->
  gulp.src "#{dir.test}/unit/**/*.test.coffee",  {read: false}
    .pipe mocha
      ui          : 'bdd'
      reporter    : 'nyan'
      ignoreLeaks : false
      require: [
        #"#{rootPath}/test/helpers/init.coffee"
        "#{rootPath}/test/helpers/global.coffee"
      ]
    .once('end', -> process.exit())

gulp.task 'test:integration', ['coffeelint'], ->
  gulp.src "#{dir.test}/integration/**/*.test.coffee",  {read: false}
  .pipe mocha
    ui          : 'bdd'
    reporter    : 'nyan'
    ignoreLeaks : false
    require: [
      "#{rootPath}/test/helpers/global.coffee"
      "#{rootPath}/test/helpers/mockgoose.coffee"
    ]

gulp.task 'build', (done) ->
  runSequence(
    'clean'
    'coffee'
    done
  )

