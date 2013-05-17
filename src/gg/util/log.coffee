_ = require("underscore")

class gg.util.Log
  @DEBUG = 0
  @WARN = 1
  @ERROR = 2
  @loggers = {}

  # static verisons for...
  @logLevel: (level, args...) ->
    @logger().logLevel level, args...
  @log: (args...) -> @logger().log args...
  @debug: (args...) -> @logLevel @DEBUG, args...
  @warn: (args...) -> @logLevel @WARN, args...
  @err: (args...) -> @logLevel @ERROR, args...
  @error: (args...) -> @logLevel @ERROR, args...

  @logger: (logname="", level=gg.util.Log.DEBUG) ->
    loggers = gg.util.Log.loggers
    unless logname of loggers
      loggers[logname] = new gg.util.Log logname, level
    return loggers[logname]

  constructor: (@logname, @level=gg.util.Log.DEBUG) ->
    callable = (args...) -> callable.debug args...
    _.extend callable, @
    #for key, val of @
    #  callable[key] = val
    return callable

  # pass through
  log: (args...) ->
    prefix = switch @level
      when gg.util.Log.DEBUG then "D"
      when gg.util.Log.WARN then "W"
      when gg.util.Log.ERROR then "E"
    prefix = "#{prefix} "
    if @logname != ""
      prefix = "#{prefix}[#{@logname}]:\t"
    args.unshift prefix
    console.log args...

  logLevel: (level, args...) ->
    if level >= @level
      @log args...

  debug: (args...) -> @logLevel gg.util.Log.DEBUG, args...
  warn: (args...) -> @logLevel gg.util.Log.WARN, args...
  err: (args...) -> @logLevel gg.util.Log.ERROR, args...
  error: (args...) -> @logLevel gg.util.Log.ERROR, args...





