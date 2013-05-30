

class gg.core.Aes

  @aliases =
    color: ['fill', 'stroke']
    thickness: ['stroke-width']
    size: ['r']
    radius: ['r']
    opacity: ['fill-opacity', 'stroke-opacity']

  @resolve: (aes) ->
    if aes of @aliases then @aliases[aes] else [aes]

