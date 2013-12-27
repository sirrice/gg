#
#
#
# Adapted from pwnall's dropship cakefile
#
#
#
async = require 'async'
{spawn, exec} = require 'child_process'
fs = require 'fs-extra'
glob = require 'glob'
log = console.log
path = require 'path'
remove = require 'remove'
process.setMaxListeners 30

  


coffeebin = "coffee" #"node_modules/coffee-script/bin/coffee"

# Node 0.6 compatibility hack.
unless fs.existsSync
  fs.existsSync = (filePath) -> path.existsSync filePath

task 'build', ->
  vendor ->
    build()

task 'release', ->
  vendor ->
    build ->
      release()

task 'vendor', ->
  vendor()

task 'test', ->
  build ->
      test()

task 'clean', ->
  clean()


release = (callback) ->
  commands = []
  commands.push "echo 'run: cd build/; python -m SimpleHTTPServer 8000'"
  commands.push "cp lib/gg.js public/js/"
  commands.push "cp build/js/prettify.js public/js/"
  commands.push "cp lib/gg.css public/css/"
  commands.push "cp -r build/vendor public/"
  #commands.push "slimerjs vendor/js/rasterize.js http://localhost:8000/html/release.html docs/imgs/screenshot.png"
  commands.push "slimerjs vendor/js/rasterize.js http://localhost:8000/html/gallery.html docs/imgs/screenshot.png"

  async.forEachSeries commands, run, ->
    callback() if callback




build = (callback) ->
  create_build_dirs()

  commands = []


  commands.push 'toaster -dc'
  commands.push 'ls build/compiled/*'
  commands.push 'cp -r build/compiled/ build/js/'
  commands.push 'cp -r src/html src/js data build/'

  compile_less commands
  copy_vendor commands

  #commands.push "#{coffeebin} --output build/js --compile src/gg/*.coffee"
  commands.push "#{coffeebin} --output test/js --compile  test/gg/*.coffee"
  commands.push 'cp build/js/ggplotjs2.js lib/'
  commands.push "./node_modules/browserify/bin/cmd.js -e lib/ggplotjs2.js >  build/js/gg.js"
  commands.push "echo 'compiled build/js/gg.js'"


  # copy final sources into lib/
  commands.push "cp build/js/gg.js lib/gg-client.js"
  commands.push "cp build/js/gg.js lib/gg.js"
  commands.push "cp build/js/ggplotjs2.js lib/gg-server.js"
  commands.push "cp build/css/gg.css lib/"


  async.forEachSeries commands, run, ->
    callback() if callback




clean = (callback) ->
  fs.remove 'build',  ->
    fs.remove 'test/js/*', ->
      fs.remove 'release', ->
        fs.remove 'lib/gg*.js', ->
          callback() if callback


test = (callback) ->
  commands = []
  commands.push "node_modules/vows/bin/vows ./test/gg/*"
  async.forEachSeries commands, run, ->

vendor = (callback) ->
  dirs = ['vendor', 'vendor/js', 'vendor/less', 'vendor/font', 'vendor/tmp']
  for dir in dirs
    fs.mkdirSync dir unless fs.existsSync dir

  downloads = [
    # D3
    ['http://d3js.org/d3.v3.min.js', 'vendor/js/d3.min.js'],

    # Zepto.js is a small subset of jQuery.
    ['http://code.jquery.com/jquery-1.9.0.min.js', 'vendor/js/jquery.min.js'],

    # JSON2
    ['https://raw.github.com/douglascrockford/JSON-js/master/json2.js',
     'vendor/js/json2.js'],

    # underscore.js
    ['http://underscorejs.org/underscore-min.js', 'vendor/js/underscore.min.js'],

    # SeedRandom (http://davidbau.com/archives/2010/01/30/random_seeds_coded_hints_and_quintillions.html)
    ['http://davidbau.com/encode/seedrandom.js', 'vendor/js/seedrandom.js'],

    # rasterize for rendering html pages
    ["https://raw.github.com/ariya/phantomjs/master/examples/rasterize.js", "vendor/js/rasterize.js"],

    # Require.js
    #['http://requirejs.org/docs/release/2.1.5/minified/require.js', 'vendor/js/require.js'],

    # science
    ["https://raw.github.com/jasondavies/science.js/master/science.v1.js", "vendor/js/science.js"]

  ]

  async.forEachSeries downloads, download, ->
    callback() if callback

create_build_dirs = ->
  for dir in [
      'build',
      'build/compiled',
      'build/css',
      'build/font',
      'build/html',
      'build/images',
      'build/js',
      'build/vendor',
      'build/vendor/font',
      'build/vendor/js',
      'test/js']
    fs.mkdirSync dir unless fs.existsSync dir

compile_less = (commands) ->
    # compile LESS
    for inFile in glob.sync 'src/less/**/*.less'
        continue if path.basename(inFile).match /^_/
        outFile = inFile.replace(/^src\/less\//, 'build/css/').
                         replace(/\.less$/, '.css')
        commands.push "node_modules/less/bin/lessc " +
                      "--strict-imports #{inFile} " +
                      "> #{outFile}"


copy_vendor = (commands) ->
  if fs.existsSync 'vendor/js'
    for inFile in glob.sync 'vendor/js/*.js'
      outFile = 'build/' + inFile
      commands.push "cp #{inFile} #{outFile}"

  if fs.existsSync 'vendor/font'
    for inFile in glob.sync 'vendor/font/*'
      outFile = 'build/' + inFile
      commands.push "cp #{inFile} #{outFile}"




run = (args...) ->
  for a in args
    switch typeof a
      when 'string' then command = a
      when 'object'
        if a instanceof Array then params = a
        else options = a
      when 'function' then callback = a

  command += ' ' + params.join ' ' if params?
  cmd = spawn '/bin/sh', ['-c', command], options
  cmd.stdout.on 'data', (data) -> process.stdout.write data
  cmd.stderr.on 'data', (data) -> 
    console.log args
    process.stderr.write data
  process.on 'SIGHUP', -> 
    console.log args
    cmd.kill()
  cmd.on 'exit', (code) -> callback() if callback? and code is 0




download = ([url, file], callback) ->
  if fs.existsSync file
    callback() if callback?
    return

  run "curl -L -o #{file} #{url}", callback




