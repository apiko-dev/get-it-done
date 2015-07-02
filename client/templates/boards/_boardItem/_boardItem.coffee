Template._boardItem.onCreated ()->
  @.taskCreating = new ReactiveVar false
  @.boardEditing = new ReactiveVar false
  @.showSettings = new ReactiveVar false

Template._boardItem.onRendered ()->
  makeTaskListSortable.call @
  $('.dropdown-toggle').dropdown()

makeTaskListSortable = ->
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
      targetTaskId = ui.item[0].dataset.id
      try
        prevTaskData = ui.item[0].previousElementSibling.dataset #Blaze.getData ui.item[0].previousElementSibling
      try
        nextTaskData = ui.item[0].nextElementSibling.dataset #Blaze.getData ui.item[0].nextElementSibling
      if !nextTaskData and prevTaskData
        curOrder = Number prevTaskData.order + 1
      if !prevTaskData and nextTaskData
        curOrder = Number nextTaskData.order / 2
      if !prevTaskData and !nextTaskData
        curOrder = 1
      if prevTaskData and nextTaskData
        curOrder = (nextTaskData.order + prevTaskData.order) / 2
      Tasks.update _id: targetTaskId,
        $set:
          boardId: targetBoardId, order: curOrder
      , (err, res) ->
        console.log err or res

  @.$('.task-list').sortable taskListOptions

Template._boardItem.helpers
  colors: ->
    array = []
    array.push color: color, _index: i for color, i in COLORS
    return array
  tasks: ->
    board = Template.instance().data
    findQuery = boardId: board._id
    sortByPriority = board.config.sortByPriority
    showArchieved = board.config.showArchieved
    sortingQuery = sort: if sortByPriority then  priority: -1 else order: 1
    sortingQuery.sort.completed = -1
    if showArchieved
      findQuery.completed = 1
    else findQuery.completed = 0
    return Tasks.find findQuery, sortingQuery
  taskCreating: () ->
    return Template.instance().taskCreating and Template.instance().taskCreating.get()
  boardEditing: () ->
    return Template.instance().boardEditing.get()
  isNoTasks: () ->
    return !Tasks.find(boardId: Template.instance().data._id).count()
  sortByPriority: ()->
    return Template.instance().data.config.sortByPriority
  togglProjects: ()->
    return TogglProjects.find()
  showArchieved: () ->
    return !!Template.instance().data.config.showArchieved
  showSettings: () ->
    return Template.instance().showSettings.get()
#allowCreatingNew: ()->
#  return Template.instance().allowCreatingNew.get()

Template._boardItem.events
  'click .new-task-action': (e, t) ->
    #Template.instance().taskCreating.set true
    Modal.show 'newTaskModal',
      board: Template.instance().data

  'click .ok-action, keydown .new-task-action .title': (e, t) ->
    if e.type is 'click' or e.keyCode is 13
      titleField = t.$("input.title")
      descriptionField = t.$("textarea.description")

      text = titleField.val()
      description = descriptionField.val()
      priority = Number t.$('#priority-chooser button').filter(".active").data("value")

      if text?.length < 1
        alert 'text is required'
      else
        boardId = t.data._id
        taskDoc =
          ownerId: Meteor.userId()
          boardId: boardId
          text: text
          description: description
          priority: if priority? then priority else 1
          completed: 0
        Tasks.insert taskDoc, (err, res) ->
          err and console.log(err)

      titleField.val ""
      descriptionField.val ""

  'click .cancel-action': (e, t) ->
    Template.instance().taskCreating.set false

  'click li.color': (e, t) ->
    self = Template.instance()
    Boards.update _id: self.data._id,
      $set:
        'config.bgColor': e.currentTarget.dataset.color
    , (err, res) ->
      err and console.log err
##if self.togglProject and self.togglProject.id
##  Meteor.call 'toggl/updateProject', {projectId: self.togglProject.id, data: {color: e.currentTarget.dataset.color}}, (err, res)->
##    err and console.log err

  'click .delete-board': (e, t) ->
    Boards.remove _id: t.data._id, (err, res) ->
      err and console.log err

  'click .edit-board-title': (e, t) ->
    instance = Template.instance()
    cur = instance.boardEditing.get()
    instance.boardEditing.set !cur
    Meteor.setTimeout ->
      t.$('.board-title').focus()
    , 0

  'click .toggl-project-item': (e, t) ->
    instance = Template.instance()
    board = instance.data
    togglProj = Blaze.getData e.target
    if togglProj and togglProj.id
      Boards.update {_id: board._id}, $set:
        'togglProject': togglProj
      , (err, res) ->
        err and console.log err
    else
      createProject board.title, board._id, board.config.bgColor, (err, res) ->
        err and console.log err

  'keyup, focusout input.board-title': (e, t) ->
    if e.type is 'focusout' or e.keyCode is 13
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
    board = Template.instance().data
    currentSorting = board.config.sortByPriority
    newSorting = if currentSorting is 1 then 0 else 1
    Boards.update {_id: board._id}, {$set: {'config.sortByPriority': newSorting}}, (err, res) ->
      err and console.log err

  'click .show-archieved': (e, t) ->
    e.preventDefault()
    board = Template.instance().data
    cur = board.config.showArchieved
    showArchieved = if cur is 1 then 0 else 1
    Boards.update {_id: board._id}, $set:
      'config.showArchieved': showArchieved
    , (err, res) ->
      err and console.log err

  'click .show-backlog': (e, t) ->
    cur = Session.get 'backlogExpanded'
    Session.set 'backlogExpanded', not cur

  'click .board-settings-button': (e, t) ->
    instance = Template.instance()
    cur = instance.showSettings.get()
    instance.showSettings.set not cur
  'click #color-chooser': (e, t) ->
    t.$(e.target).closest(".dropdown-menu").toggle()
  'click #toggl-project': (e, t) ->
    t.$(e.target).closest(".dropdown-menu").toggle()

createProject = (name, boardId, bgColor, cb)->
  Meteor.call 'toggl/createProject', name: name, boardId: boardId, color: bgColor, (err, res)->
    res.result and fetchProjects()
