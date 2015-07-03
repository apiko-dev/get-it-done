BOARD_WIDTH = 300;

Template.boards.events
  'click .new-board-wrapper': (e, t) ->
    buttonSide = t.$(e.target).data "side"
    Modal.show 'newItemModal',
      buttonPressed: buttonSide

  'click .new-board-cancel-action': () ->
    Template.instance().boardCreating.set false

Template.boards.helpers
  boards: () ->
    return Boards.find { ownerId: Meteor.userId(), isBacklog: {$exists: false}}, sort: order: 1
  boardCreating: () ->
    return Template.instance().boardCreating.get()
  backlogBoard: () ->
    return Boards.findOne {isBacklog: true}

Template.boards.onCreated () ->
  @.boardCreating = new ReactiveVar(false);
  fetchProjects()

@scrollToBoard = ->
  hash = Iron.Location.get().hash
  hash = hash.slice 1, hash.length
  if hash
    bodyWidth = $('body').width()
    boardOffset = $('#' + hash).offset()
    $('#lists').stop().animate {scrollLeft: boardOffset.left - bodyWidth / 2 + BOARD_WIDTH / 2}, 700

Template.boards.onRendered () ->
  Meteor.setTimeout ->
    $('.dropdown-toggle').dropdown()
  , 1000
  scrollToBoard()
  @.$('#lists').sortable
    helper: 'clone'
    placeholder: 'sortable-placeholder'
    items: '.board'
    forcePlaceholderSize: !0
    distance: 5
    dropOnEmpty: true
    opacity: 1
    zIndex: 1000
    axis: 'x'
    start: (e, ui) ->
      #ui.placeholder.height(ui.helper.outerHeight());
    update: (event, ui) ->
      targetBoardId = Blaze.getData(ui.item[0])._id
      try
        prevBoardData = Blaze.getData ui.item[0].previousElementSibling
      try
        nextBoardData = Blaze.getData ui.item[0].nextElementSibling
      if !nextBoardData and prevBoardData
        curOrder = prevBoardData.order + 1
      if !prevBoardData and nextBoardData
        curOrder = nextBoardData.order/2
      if !prevBoardData and !nextBoardData
        curOrder = 1
      if prevBoardData and nextBoardData
        curOrder = (nextBoardData.order + prevBoardData.order) / 2
      Boards.update { _id: targetBoardId }, { $set: order: curOrder}, (err, res) ->
        console.log err or res
