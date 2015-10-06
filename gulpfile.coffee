# Main build driver
gulp       = require 'gulp'

bower      = require 'main-bower-files'
clean      = require 'rimraf'
coffee     = require 'gulp-coffee'
concat     = require 'gulp-concat'
gfilter    = require 'gulp-filter'
gulpif     = require 'gulp-if'
livereload = require 'gulp-livereload'
minify     = require 'gulp-uglify'
sequence   = require 'gulp-sequence'
watch      = require 'gulp-watch'
webserver  = require 'gulp-webserver'

minifyDeps = false
minifySrc  = false

# Folders
srcF       = 'src/'
distF      = 'dist/'
scriptsF   = srcF + 'scripts/'
stylesF    = srcF + 'styles/'

glob =
    coffee:    '**/*.coffee'
    css:       '**/*.css'
    js:        '**/*.js'
    litcoffee: '**/*.litcoffee'

# Src Files
src =
    css:       stylesF  + glob.css
    coffee:    scriptsF + glob.coffee
    index:     srcF     + 'index.html'
    js:        scriptsF + glob.js
    litcoffee: scriptsF + glob.litcoffee

# Destination Files
dest =
    index:   distF
    js:      distF + 'js'
    css:     distF + 'css'

# Groups of Files
selections =
    srcScripts: [src.js, src.coffee, src.litcoffee]

gulp.task 'clean', (cb) ->
    clean 'dist', cb

gulp.task 'bower', () ->
    jsFilter  = gfilter glob.js, {restore: true}
    cssFilter = gfilter glob.js, {restore: true}
    gulp.src bower()
        # Javascript
        .pipe jsFilter
        .pipe minify()
        .pipe concat    'deps.js'
        .pipe gulp.dest dest.js
        .pipe jsFilter.restore
        # CSS
        .pipe cssFilter
        .pipe concat    'deps.css'
        .pipe gulp.dest dest.css
        .pipe cssFilter.restore

gulp.task 'index', ->
    gulp.src src.index
        .pipe gulp.dest dest.index

gulp.task 'scripts', ->
    jsFilter        = gfilter glob.js, {restore: true}
    coffeeFilter    = gfilter glob.coffee, {restore: true}
    litcoffeeFilter = gfilter glob.litcoffee, {restore: true}
    gulp.src selections.srcScripts
        # Coffeescript
        .pipe coffeeFilter
        .pipe coffee()
        .pipe coffeeFilter.restore
        # Literate Coffeescript
        .pipe litcoffeeFilter
        .pipe coffee()
        .pipe litcoffeeFilter.restore
        # All together
        .pipe concat 'index.js'
        .pipe gulpif minifySrc, minify()
        .pipe gulp.dest dest.js

gulp.task 'watch', () ->
    gulp.watch src.index     , ['index']
    gulp.watch src.js        , ['scripts']
    gulp.watch src.coffee    , ['scripts']
    gulp.watch src.litcoffee , ['scripts']

gulp.task 'webserver', () ->
    gulp.src distF
        .pipe webserver
            livereload: true,
            directoryListing: false,
            open: true,
            port: 9090

gulp.task 'default',
    sequence 'clean',
             'bower',
             ['scripts', 'index'],
             'webserver',
             'watch'

