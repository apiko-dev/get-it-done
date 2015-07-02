Template.Stripe.helpers
  colors: ->
    boards = Boards.find()
    colors = []
    boards.forEach (board) ->
      if not board.isBacklog
        colors.push
          boardColor: COLORS[board.config.bgColor] or '#AAAAAA'
          boardName: board.title
          boardHash: board._id

    if colors.length == 0
      return [
        {
          boardColor: '#f68d38'
          boardName: ''
          boardHash: ''
        }
      ]
    colors
  lineWidth: ->
    count = Boards.find(isBacklog: "$exists": false).count() or 1
    return 1 / count * 100 + '%'

Template.Stripe.events
  'click .stripe-line': (e, t) ->
    boardHash = Blaze.getData(e.target).boardHash
    Router.go 'boards', {},
      hash: boardHash
    scrollToBoard()

  'mouseenter .stripe': (e, t) ->
    $('#bs-example-navbar-collapse-1 .nav').hide()

  'mouseleave .stripe': (e, t) ->
    Meteor.setTimeout ->
      $('#bs-example-navbar-collapse-1 .nav').show()
    , 200