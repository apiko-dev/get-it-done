Template.Stripe.helpers
  colors: ->
    boards = Boards.find()
    colors = []
    boards.forEach (board) ->
      if not board.isBacklog
        colors.push COLORS[board.config.bgColor] or '#AAAAAA'

    if colors.length == 0
      return ['#f68d38']
    colors
  lineWidth: ->
    count = Boards.find(isBacklog: "$exists": false).count() or 1
    return 1 / count * 100 + '%'