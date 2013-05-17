#<< gg/scale/scale
#<< gg/data/schema

class gg.scale.Identity extends gg.scale.Scale
  @aliases = "identity"
  constructor: () ->
    @d3Scale = null
    @type = gg.data.Schema.numeric
    super
    @log.level = gg.util.Log.ERROR

  clone: -> @

  valid: -> true
  defaultDomain: ->
    @log.warn "IdentityScale has no domain"
  mergeDomain: ->
    @log.warn "IdentityScale has no domain"
  domain: ->
    @log.warn "IdentityScale has no domain"
  minDomain: ->
    @log.warn "IdentityScale has no domain"
  maxDomain: ->
    @log.warn "IdentityScale has no domain"
  resetDomain: ->
  range: ->
    @log.warn "IdentityScale has no range"
  minRange: ->
    @log.warn "IdentityScale has no range"
  maxRange: ->
    @log.warn "IdentityScale has no range"

  scale: (v) -> v
  invert: (v) -> v
  toString: () -> "#{@aes}.#{@id} (#{@type}): identity"


