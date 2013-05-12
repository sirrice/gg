# => SRC FOLDER
#
toast
  folders:
      'src/gg': 'gg'

  # EXCLUDED FOLDERS (optional)
  exclude: ['src/gg/old']
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
  release: 'build/compiled/ggplotjs2.js'
  debug: 'build/compiled/ggplotjs2-debug.js'



