

class gg.core.Aes
  @groupcols: [
    'fill'
    'stroke'
    'stroke-width'
    'stroke-opacity'
    'group'
    'opacity'
    'r'
    'radius'
  ]

  @aliases =
    color: ['fill', 'stroke']
    thickness: ['stroke-width']
    size: ['r']
    radius: ['r']
    opacity: ['fill-opacity', 'stroke-opacity']

  @resolve: (aes) ->
    if aes of @aliases then @aliases[aes] else [aes]

  @groupable: (aes) -> aes in @groupcols

