# => SRC FOLDER
#
toast
  folders:
      'src/data': 'data'

  # EXCLUDED FOLDERS (optional)
  exclude: [
    'src/gg/old'
    "src/gg/server"
  ]
  # exclude: ['folder/to/exclude', 'another/folder/to/exclude', ... ]


  # => VENDORS (optional)
  vendors: [
      'vendor/js/d3.min.js',
      'vendor/js/jquery.min.js',
      'vendor/js/json2.js',
      'vendor/js/underscore.min.js',
      'vendor/js/seedrandom.js',
      'vendor/js/science.js'
  ]


  # => OPTIONS (optional, default values listed)
  # bare: false
  #packaging: false
  expose: 'window'
  minify: false

  # => HTTPFOLDER (optional), RELEASE / DEBUG (required)
  httpfolder: '../js/'
  release: 'build/compiled/ggdata.js'
  debug: 'build/compiled/ggdata-debug.js'



