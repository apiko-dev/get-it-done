#Template.boardChooser.onCreated ()->
#	@.currentBoard = new ReactiveVar()
#
#Template.boardChooser.onRendered ()->
#	@.currentBoard.set Boards.findOne @.data.boardId

Template.boardChooser.helpers
  boards: ->
    Boards.find()
  isSelected: (boardId) ->
    boardId is Template.instance().data.boardId

#Template.boardChooser.events
#  'click .board-selector li': (e, t) ->
#  	console.log e, t