

class gg.core.Aes

  @aliases =
    color: ['fill', 'stroke']
    thickness: ['stroke-width']
    size: ['r']
    radius: ['r']

  @resolve: (aes) ->
    if aes of @aliases then @aliases[aes] else [aes]

