Template.Stripe.onCreated ->
  @.curHash = new ReactiveVar ""

Template.Stripe.onRendered ->
  $(window).resize ->
    left = $("#bs-example-navbar-collapse-1").position().left
    @.$(".stripe-wrapper").css "width", (left - 120) + "px"

Template.Stripe.helpers
  colors: ->
    boards = Boards.find {}, sort: {order: 1}
    colors = []
    boards.forEach (board) ->
      if not board.isBacklog
        colors.push
          boardColor: COLORS[board.config.bgColor] or '#AAAAAA'
          boardName: board.title
          boardHash: board._id

    if colors.length == 0
      return [
        boardColor: '#f68d38'
        boardName: 'Your boards...'
        boardHash: ''
      ]
    else
      colors

  lineWidth: ->
    count = Boards.find(
      isBacklog:
        "$exists": false
    ).count() or 1
    1 / count * 100 + '%'

Template.Stripe.events
  'click .stripe-line': (e) ->
    boardHash = Blaze.getData(e.target).boardHash
    if location.pathname == '/boards'
      scrollToBoard boardHash
    else
      Router.go 'boards', {},
        hash: boardHash