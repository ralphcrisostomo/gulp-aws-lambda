gulp        = require('gulp')
bump        = require('gulp-bump')
changelog   = require('gulp-conventional-changelog')
inquirer    = require('inquirer')
runSequence = require('run-sequence')

gulp.task "bump", ->
  gulp.src ['./package.json','./bower.json']
  .pipe bump { key : "version", type : process.env.BUMP}
  .pipe gulp.dest('./')

gulp.task "changelog", ->
  gulp.src ['./CHANGELOG.md']
  .pipe changelog()
  .pipe gulp.dest "./"

# Public Tasks
# ------------------------------
gulp.task "release", (callback) ->
  inquirer.prompt [
    type : 'list'
    name : 'bump'
    message : 'Select bump type :'
    choices :[ 'patch','minor', 'major']
  ], (answers) ->
    process.env.BUMP = answers.bump
    runSequence(
      "bump"
      "changelog"
      "build"
      callback
    )