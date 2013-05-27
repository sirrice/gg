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
  commands.push "phantomjs vendor/js/rasterize.js build/html/release.html docs/imgs/screenshot.png"
  commands.push "scp -r lib eugenewu@athena.dialup.mit.edu:~/Public/gg"

  async.forEachSeries commands, run, ->
    callback() if callback


build = (callback) ->
    create_build_dirs()

    commands = []


    commands.push 'toaster -dc'
    commands.push 'cp -r build/compiled/* build/js/'

    #  commands.push 'cp src/manifest.json build/'
    commands.push 'cp -r src/html build/'
    commands.push 'cp -r src/font build/'
    commands.push 'cp -r src/js build/'
    commands.push 'cp -r src/data build/'
    # TODO: consider optipng
    commands.push 'cp -r src/images build/'

    compile_less commands
    copy_vendor commands

    #commands.push "#{coffeebin} --output build/js --compile src/gg/*.coffee"
    commands.push "#{coffeebin} --output test/js --compile  test/gg/*.coffee"
    commands.push 'cp build/js/ggplotjs2.js .'
    commands.push "./node_modules/browserify/bin/cmd.js -e ggplotjs2.js >  build/js/gg.js"


    # copy final sources into lib/
    commands.push "cp build/js/gg.js lib/"
    commands.push "cp build/css/gg.css lib/"


    async.forEachSeries commands, run, ->
      callback() if callback


clean = (callback) ->
    fs.remove 'build',  ->
        fs.remove 'test/js/*', ->
          fs.remove 'release', ->
            callback() if callback


test = (callback) ->
    commands = []
    commands.push "node_modules/vows/bin/vows"
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

    # Humanize for user-readable sizes.
    ['https://raw.github.com/taijinlee/humanize/0a97f11503e3844115cfa3dc365cf9884e150e4b/humanize.js',
     'vendor/js/humanize.js'],

    # JSON2
    ['https://raw.github.com/douglascrockford/JSON-js/master/json2.js',
     'vendor/js/json2.js'],

    # underscore.js
    ['http://underscorejs.org/underscore-min.js', 'vendor/js/underscore.min.js'],

    # FontAwesome for icons.
    ['https://github.com/FortAwesome/Font-Awesome/archive/v3.0.1.zip',
     'vendor/tmp/font_awesome.zip'],

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
    commands = []

    # Minify humanize.
    unless fs.existsSync 'vendor/js/humanize.min.js'
      commands.push 'node_modules/uglify-js/bin/uglifyjs --compress ' +
          '--mangle --output vendor/js/humanize.min.js vendor/js/humanize.js'

    # Unpack fontawesome.
    unless fs.existsSync 'vendor/tmp/Font-Awesome-3.0.1/'
      commands.push 'unzip -qq -d vendor/tmp vendor/tmp/font_awesome'
      # Patch fontawesome inplace.
      commands.push 'sed -i -e "/^@FontAwesomePath:/d" ' +
                    'vendor/tmp/Font-Awesome-3.0.1/less/font-awesome.less'

    async.forEachSeries commands, run, ->
      commands = []

      # Copy fontawesome to vendor/.
      for inFile in glob.sync 'vendor/tmp/Font-Awesome-3.0.1/less/*.less'
        outFile = inFile.replace /^vendor\/tmp\/Font-Awesome-3\.0\.1\/less\//,
                                 'vendor/less/'
        unless fs.existsSync outFile
          commands.push "cp #{inFile} #{outFile}"
      for inFile in glob.sync 'vendor/tmp/Font-Awesome-3.0.1/font/*'
        outFile = inFile.replace /^vendor\/tmp\/Font-Awesome-3\.0\.1\/font\//,
                                 'vendor/font/'
        unless fs.existsSync outFile
          commands.push "cp #{inFile} #{outFile}"

      async.forEachSeries commands, run, ->
        callback() if callback




create_build_dirs = ->
  for dir in [
      'build',
      'build/data',
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
    for inFile in glob.sync 'vendor/js/*.js'
        #continue if inFile.match /\.min\.js$/
        outFile = 'build/' + inFile
        commands.push "cp #{inFile} #{outFile}"

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
  cmd.stderr.on 'data', (data) -> process.stderr.write data
  process.on 'SIGHUP', -> cmd.kill()
  cmd.on 'exit', (code) -> callback() if callback? and code is 0




download = ([url, file], callback) ->
  if fs.existsSync file
    callback() if callback?
    return

  run "curl -L -o #{file} #{url}", callback




