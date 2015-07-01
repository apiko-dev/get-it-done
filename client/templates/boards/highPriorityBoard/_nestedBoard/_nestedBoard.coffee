Template._nestedBoard.helpers
  tasks: ->
    board = Template.instance().data
    findQuery = { boardId: board._id, priority: 2, completed: 0}
    sortingQuery = sort: {order: 1}
    return Tasks.find findQuery, sortingQuery
  isAnyTasks: () ->
    board = Template.instance().data
    return !!Tasks.find({ boardId: board._id, priority: 2, completed: 0}).count()

Template._nestedBoard.events
  'click .toggl-project-item': (e, t) ->
    instance = Template.instance()
    board = instance.data
    togglProj = Blaze.getData e.target
    if togglProj and togglProj.id
      Boards.update {_id: board._id}, {$set: {'togglProject': togglProj}}, (err, res) ->
        err and console.log err
    else
      createProject board.title, board._id, board.config.bgColor, (err, res) ->
        err and console.log err
  'keyup, focusout input.board-title': (e, t) ->
    if e.type == 'focusout' or e.keyCode == 13
      instance = Template.instance()
      cur = instance.boardEditing.get()
      self = @
      if cur
        title = $(e.currentTarget).parent().find('input').val()
        Boards.update {_id: @._id}, {$set: {title: title}}, (err, res) ->
          err and console.log err
        #Meteor.call 'toggl/updateProject', {projectId: self.togglProject.id, data: {name: title}}, (err, res)->
        #  err and console.log err
      instance.boardEditing.set null