Template.backlog.onCreated ()->
  @.taskCreating = new ReactiveVar false
  @.boardEditing = new ReactiveVar false


Template.backlog.onRendered ()->
  $('.dropdown-toggle').dropdown()
  @.$('.backlog-task-list').sortable 
    connectWith: '.task-list'
    helper: 'clone'
    placeholder: 'sortable-placeholder'
    items: '.action'
    forcePlaceholderSize: !0
    dropOnEmpty: true
    opacity: 1
    zIndex: 9999
    start: (e, ui) ->
      ui.placeholder.height(ui.helper.outerHeight());
    update: (event, ui) ->
      task = Blaze.getData(ui.item[0])
      targetBoardId = Blaze.getData(event.target)._id
      targetTaskId = task._id
      try
        prevTaskData = Blaze.getData ui.item[0].previousElementSibling
      try
        nextTaskData = Blaze.getData ui.item[0].nextElementSibling
      if !nextTaskData and prevTaskData
        curOrder = prevTaskData.order + 1
      if !prevTaskData and nextTaskData
        curOrder = nextTaskData.order / 2
      if !prevTaskData and !nextTaskData
        curOrder = 1
      if prevTaskData and nextTaskData
        curOrder = (nextTaskData.order + prevTaskData.order) / 2
      Tasks.update _id: targetTaskId,
        $set:
          boardId: targetBoardId, order: curOrder
      , (err, res) ->
        err and console.log err
  #@.$('.task.action').draggable
  #  revert: 'invalid'
  #  connectToSortable: '.task-list'
  #  zIndex: 9999
  #  dropOnEmpty: true
  #  opacity: 1
  

Template.backlog.helpers
  backlogExpanded: () ->
    return Session.get 'backlogExpanded'
  tasks: ->
    if Template.instance().data and Template.instance().data.backlogBoard
      board = Template.instance().data.backlogBoard
      findQuery = { boardId: board._id}
      sortByPriority = board.config.sortByPriority
      showArchieved = board.config.showArchieved
      sortingQuery = sort: if sortByPriority then  {priority: -1} else {order: 1}
      sortingQuery.sort.completed = -1
      if not showArchieved
        findQuery.completed = 0
      return Tasks.find findQuery, sortingQuery
  taskCreating: () ->
    return Template.instance().taskCreating and Template.instance().taskCreating.get()
  boardEditing: () ->
    return Template.instance().boardEditing.get()
  isNoTasks: () ->
    return !Tasks.find({ boardId: Template.instance().backlogBoard.data._id }).count()
  sortByPriority: ()->
    return !!Template.instance().data.backlogBoard.config.sortByPriority
  togglProjects: ()->
    return TogglProjects.find()
  showArchieved: () ->
    return !!Template.instance().data.backlogBoard.config.showArchieved
  backlogExpanded: () ->
    return Session.get 'backlogExpanded'


Template.backlog.events
  'click .new-task-action': (e, t) ->
    Modal.show 'newItemModal',
      board: Template.instance().data
    #Template.instance().taskCreating.set true

  'click .complete-action': (e, t) ->
    taskData = Blaze.getData(event.target)
    cur = taskData.completed
    newCompleted = if cur == 1 then 0 else 1
    Tasks.update { _id: taskData._id }, { $set: completed: newCompleted }, (err, res) ->
      err and console.log err

  'click .cancel-action': (e, t) ->
    Template.instance().taskCreating.set false

  'click .toggl-project-item': (e, t) ->
    instance = Template.instance()
    board = instance.data.backlogBoard
    togglProj = Blaze.getData e.target
    if togglProj and togglProj.id
      Boards.update {_id: board._id}, {$set: {'togglProject': togglProj}}, (err, res) ->
        err and console.log err
    else
      createProject board.title, board._id, board.config.bgColor, (err, res) ->
        err and console.log err

  'click .priority-switch-checkbox': (e, t) ->
    e.preventDefault()
    $(e.target).parent().toggleClass "active"
    board = Template.instance().data.backlogBoard
    currentSorting = board.config.sortByPriority
    newSorting = if currentSorting == 1 then 0 else 1
    Boards.update {_id: board._id}, {$set: {'config.sortByPriority': newSorting}}, (err, res) ->
      console.log err or res
      err and console.log err

  'click .show-archieved': (e, t) ->
    e.preventDefault()
    $(e.target).toggleClass "active"
    board = Template.instance().data.backlogBoard
    cur = board.config.showArchieved
    showArchieved = if cur == 1 then 0 else 1
    Boards.update {_id: board._id}, {$set: {'config.showArchieved': showArchieved}}, (err, res) ->
      err and console.log err

  'click .show-backlog': (e, t) ->
    cur = Session.get 'backlogExpanded'
    Session.set 'backlogExpanded', not cur

  'click .ok-action, keydown .new-task-action .title': (e, t) ->
    if e.type == 'click' or e.keyCode == 13
      text = t.$("input.title").val()
      description = t.$("textarea.description").val()
      boardId = t.$("select#select-board").val()
      boardId = Template.instance().data.backlogBoard._id if boardId?.length < 1
      priority = Number t.$('#priority-chooser button').filter(".active").data("value")

      if text?.length < 1
        alert 'text is required'
      else
        Tasks.insert {ownerId: Meteor.userId(), boardId: boardId, text: text, description: description, priority: priority || 1, completed: 0}, (err, res) ->
          err and console.log err
      Template.instance().taskCreating.set false

createProject = (name, boardId, bgColor, cb)->
  Meteor.call 'toggl/createProject', {name: name, boardId: boardId, color: bgColor}, (err, res)->
    res.result and fetchProjects()