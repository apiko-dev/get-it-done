BOARD_WIDTH = 300

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
  'click .new-board-wrapper': (e, t) ->
    buttonSide = t.$(e.target).data "side"
    Modal.show 'newItemModal',
      buttonPressed: buttonSide

@scrollToBoard = ->
  hash = Iron.Location.get().hash
  hash = hash.slice 1, hash.length
  if hash
    bodyWidth = $('body').width()
    boardOffset = $('#' + hash).offset()
    $('#lists').stop().animate {scrollLeft: boardOffset.left - bodyWidth / 2 + BOARD_WIDTH / 2}, 700
