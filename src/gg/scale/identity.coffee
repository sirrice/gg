#<< gg/scale/scale
#<< gg/data/schema

class gg.scale.Identity extends gg.scale.Scale
  @aliases = "identity"
  constructor: () ->
    @d3Scale = null
    @type = gg.data.Schema.numeric
    super

  clone: -> @

  valid: -> true
  defaultDomain: ->
    console.log "warning, gg.IdentityScale has no domain"
  mergeDomain: ->
    console.log "warning, gg.IdentityScale has no domain"
  domain: ->
    console.log "warning, gg.IdentityScale has no domain"
  minDomain: ->
    console.log "warning, gg.IdentityScale has no domain"
  maxDomain: ->
    console.log "warning, gg.IdentityScale has no domain"
  resetDomain: ->
  range: ->
    console.log "warning, gg.IdentityScale has no range"
  minRange: ->
    console.log "warning, gg.IdentityScale has no range"
  maxRange: ->
    console.log "warning, gg.IdentityScale has no range"

  scale: (v) -> v
  invert: (v) -> v
  toString: () -> "#{@aes}.#{@id} (#{@type}): identity"


