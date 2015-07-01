Template._boardItem.onCreated ()->
  @.taskCreating = new ReactiveVar false
  @.boardEditing = new ReactiveVar false
  #@.allowCreatingNew = new ReactiveVar true


Template._boardItem.onRendered ()->
  #isAllowCreatingNew 
  @.$('.dropdown-toggle').dropdown()
  taskListOptions =
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
      targetBoardId = Blaze.getData(event.target)._id
      targetTaskId = Blaze.getData(ui.item[0])._id
      try
        prevTaskData = Blaze.getData ui.item[0].previousElementSibling
      try
        nextTaskData = Blaze.getData ui.item[0].nextElementSibling
      if !nextTaskData and prevTaskData
        curOrder = prevTaskData.order + 1
      if !prevTaskData and nextTaskData
        curOrder = nextTaskData.order/2
      if !prevTaskData and !nextTaskData
        curOrder = 1
      if prevTaskData and nextTaskData
        curOrder = (nextTaskData.order + prevTaskData.order) / 2
      Tasks.update { _id: targetTaskId }, { $set: boardId: targetBoardId, order: curOrder}, (err, res) ->
        err and console.log err

  @.$('.task-list').sortable taskListOptions

  # Restore checkbox value according to sorting methods selected by user
  @.$(".priority-switch-checkbox").prop "checked", if Number @.data.config.sortByPriority is 0 then false else true
  @.$(".hidden-settings").hide()

Template._boardItem.helpers
  colors: ->
    array = []
    for color, i in COLORS
      array.push color: color, _index: i
    return array
  tasks: ->
    findQuery = { boardId: Template.instance().data._id}
    board = Template.instance().data
    sortByPriority = board.config.sortByPriority
    showArchieved = board.config.showArchieved
    sortingQuery = sort: if sortByPriority then  {priority: -1} else {order: 1}
    sortingQuery.sort.completed = -1
    console.log 'findQuery', findQuery
    console.log 'sortingQuery', sortingQuery
    if not showArchieved
      findQuery.completed = 0
    return Tasks.find findQuery, sortingQuery
  taskCreating: () ->
    return Template.instance().taskCreating and Template.instance().taskCreating.get()
  boardEditing: () ->
    return Template.instance().boardEditing.get()
  isNoTasks: () ->
    return !Tasks.find({ boardId: Template.instance().data._id }).count()
  sortByPriority: ()->
    return Template.instance().data.config.sortByPriority
  togglProjects: ()->
    return TogglProjects.find()
  showArchieved: () ->
    return !!Template.instance().data.config.showArchieved
  backlogExpanded: () ->
    return Session.get 'backlogExpanded'
  #allowCreatingNew: ()->
  #  return Template.instance().allowCreatingNew.get()

Template._boardItem.events
  'click .new-task-action': (e, t) ->
    Template.instance().taskCreating.set true

  'click .complete-action': (e, t) ->
    taskData = Blaze.getData(event.target)
    cur = taskData.completed
    newCompleted = if cur == 1 then 0 else 1
    Tasks.update { _id: taskData._id }, { $set: completed: newCompleted }, (err, res) ->
      err and console.log err

  'click .ok-action, keydown .new-task-action .title': (e, t) ->
    if e.type == 'click' or e.keyCode == 13
      text = t.$("textarea.title").val()
      description = t.$("textarea.description").val()
      priority = Number t.$("select#priority-chooser").val()

      if text?.length < 1
        alert 'text is required'
      else
        boardId = t.data._id
        Tasks.insert {ownerId: Meteor.userId(), boardId: boardId, text: text, description: description, priority: priority || 1, completed: 0}, (err, res) ->
          err and console.log err
      Template.instance().taskCreating.set false

  'click .cancel-action': (e, t) ->
    Template.instance().taskCreating.set false

  'click li.color': (e, t) ->
    self = Template.instance()
    Boards.update { _id: self.data._id }, { $set: 'config.bgColor': e.currentTarget.dataset.color}, (err, res) ->
      err and console.log err
    ##if self.togglProject and self.togglProject.id
    ##  Meteor.call 'toggl/updateProject', {projectId: self.togglProject.id, data: {color: e.currentTarget.dataset.color}}, (err, res)->
    ##    err and console.log err

  'click .delete-board': (e, t) ->
    Boards.remove {_id: t.data._id}, (err, res) ->
      err and console.log err

  'click .edit-board-title': (e, t) ->
    instance = Template.instance()
    cur = instance.boardEditing.get()
    instance.boardEditing.set !cur
    Meteor.setTimeout (->
      t.$('.board-title').focus()
    ), 0

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

  'click .priority-switch-checkbox': (e, t) ->
    $(e.target).parent().toggleClass "active"

    board = Template.instance().data
    currentSorting = board.config.sortByPriority
    newSorting = if currentSorting == 1 then 0 else 1
    Boards.update {_id: board._id}, {$set: {'config.sortByPriority': newSorting}}, (err, res) ->
      console.log err or res
      err and console.log err

  'click .show-archieved': (e, t) ->
    e.preventDefault()
    $(e.target).toggleClass "active"

    board = Template.instance().data
    cur = board.config.showArchieved
    showArchieved = if cur == 1 then 0 else 1
    Boards.update {_id: board._id}, {$set: {'config.showArchieved': showArchieved}}, (err, res) ->
      err and console.log err
  'click .show-backlog': (e, t) ->
    cur = Session.get 'backlogExpanded'
    console.log cur
    Session.set 'backlogExpanded', not cur

  'click .board-settings-button': (e, t) ->
    t.$(".hidden-settings").toggle()
    t.$(".toggle-list.edit-board-title").toggle()

createProject = (name, boardId, bgColor, cb)->
  Meteor.call 'toggl/createProject', {name: name, boardId: boardId, color: bgColor}, (err, res)->
    res.result and fetchProjects()

#isAllowCreatingNew = (instance) ->
#  board = instance.data
#  board.togglProject and board.togglProject.name and console.log TogglProjects.findOne {name: board.togglProject.name} 
#  board.togglProject and board.togglProject.name and if TogglProjects.findOne {name: board.togglProject.name}
#    instance.allowCreatingNew.set false
