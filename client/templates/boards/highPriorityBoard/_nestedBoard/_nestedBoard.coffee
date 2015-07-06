Template._nestedBoard.helpers
  tasks: ->
    board = Template.instance().data
    findQuery = { boardId: board._id, priority: 2, completed: 0}
    sortingQuery = sort: {order: 1}
    return Tasks.find findQuery, sortingQuery
  isAnyTasks: () ->
    board = Template.instance().data
    return !!Tasks.find({ boardId: board._id, priority: 2, completed: 0}).count()
  togglProjects: ->
    TogglProjects.find()