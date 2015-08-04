Template.boards.onCreated ->
  fetchProjects()

Template.boards.onRendered ->
  Meteor.setTimeout ->
    $('.dropdown-toggle').dropdown()
  , 1000
  @.$('#lists').sortable boardsListOptions
  scrollToBoard()


Template.boards.helpers
  boards: ->
    Boards.find
      ownerId: Meteor.userId()
      isBacklog:
        $exists: false
    , sort:
      order: 1
  backlogBoard: ->
    Boards.findOne isBacklog: true

Template.boards.events
  'click .new-board-container': (e, t) ->
    buttonSide = t.$(e.target).data "side"
    Modal.show 'newItemModal',
      buttonPressed: buttonSide

@scrollToBoard = (boardId)->
    if location.hash != '#'+boardId
      hash = boardId or location.hash.slice 1, location.hash.length
      location.hash = hash
      $('.board.active').removeClass 'active'
      board = $('#' + hash)
      board.addClass('active')
      bodyWidth = $('body').width()
      boardOffset = board.offset()
      try
        boardWidth = $('.board').width()
        listsScroll = $('#lists').scrollLeft()
        $('#lists').stop().animate {scrollLeft: listsScroll + boardOffset.left - bodyWidth / 2 + boardWidth / 2}, 700

$('body,html').bind 'scroll mousedown wheel DOMMouseScroll mousewheel keyup', (e) ->
  if not (e.type == 'mousedown' or e.type == 'mousewheel')
    $('.board.active').removeClass 'active'
    location.hash = ''