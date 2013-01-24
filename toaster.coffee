# => SRC FOLDER
#
toast
  folders:
      'src/gg': 'gg'

  # EXCLUDED FOLDERS (optional)
  # exclude: ['folder/to/exclude', 'another/folder/to/exclude', ... ]

  # => VENDORS (optional)
  vendors: [
      'vendor/js/d3.min.js',
      'vendor/js/jquery.min.js',
      'vendor/js/json2.js',
      'vendor/js/underscore-min.js'
  ]


  # => OPTIONS (optional, default values listed)
  # bare: false
  #packaging: false
  expose: 'window'
  minify: true

  # => HTTPFOLDER (optional), RELEASE / DEBUG (required)
  httpfolder: '../js/'
  release: 'src/compiled/ggplotjs2.js'
  debug: 'src/compiled/ggplotjs2-debug.js'
