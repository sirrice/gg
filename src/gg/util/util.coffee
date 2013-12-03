#<< gg/util/json
ggutil = require 'ggutil'
_ = require 'underscore'

class gg.util.Util
  @ggklass: (ggpackage) ->
    cmd = "return ('gg' in window)? window.#{ggpackage} : #{ggpackage}"
    Function(cmd)()

_.mixin 
  ggklass: gg.util.Util.ggklass
  toJSON: gg.util.Json.toJSON
  fromJson: gg.util.Json.fromJSON


_.extend gg.util, _.omit(ggutil, 'Util', 'Json')
_.extend gg.util.Util, ggutil.Util
