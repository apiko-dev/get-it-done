Template.boardChooser.helpers
  boards: ->
    Boards.find()
  isSelected: (boardId) ->
    boardId is Template.instance().data.boardId