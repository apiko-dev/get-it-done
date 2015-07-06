Template._boardItem.onCreated ->
  @.boardEditing = new ReactiveVar false
  @.showSettings = new ReactiveVar false

Template._boardItem.onRendered ->
  @.$('.dropdown-toggle').dropdown()
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

    Tasks.find findQuery, sortingQuery

  boardEditing: ->
    Template.instance().boardEditing.get()
  isNoTasks: ->
    !Tasks.find(boardId: Template.instance().data._id).count()
  sortByPriority: ->
    Template.instance().data.config.sortByPriority
  togglProjects: ->
    TogglProjects.find()
  showArchieved: ->
    !!Template.instance().data.config.showArchieved
  showSettings: ->
    Template.instance().showSettings.get()

Template._boardItem.events
  'click .new-task-action': ->
    Modal.show 'newItemModal',
      board: Template.instance().data
      isBacklogTask: !!Template.instance().data?.backlogBoard

  'click li.color': (e) ->
    tplInstance = Template.instance()
    updateBoard tplInstance.data._id, 'config.bgColor': e.currentTarget.dataset.color
#    if togglProjectExists = tplInstance.togglProject and tplInstance.togglProject.id
#      updateTogglProject tplInstance.togglProject.id, color: e.currentTarget.dataset.color

  'click .delete-board': (e, t) ->
    removeBoard t.data._id

  'click .edit-board-title': (e, t) ->
    boardEditMode = Template.instance().boardEditing
    currentBoardEditMode = boardEditMode.get()
    boardEditMode.set not currentBoardEditMode

    Meteor.setTimeout ->
      t.$('.board-title').focus()
    , 0

  'click .toggl-project-item': (e) ->
    tplInstance = Template.instance()
    boardData = tplInstance.data
    togglProjectData = Blaze.getData e.target

    if togglProjectExists = togglProjectData and togglProjectData.id
      updateBoard boardData._id, togglProject: togglProjectData
    else
      createTogglProject boardData.title, boardData._id, boardData.config.bgColor, (err, res) ->
        err and console.log err

  'keyup, focusout input.board-title': (e) ->
    if e.type is 'focusout' or e.keyCode is 13
      tplInstance = Template.instance()
      boardEditModeStatus = tplInstance.boardEditing.get()

      if boardEditModeStatus
        title = $(e.currentTarget).parent().find('input').val()
        updateBoard @._id, title: title

      #updateTogglProject @.togglProject.id, name: title
      tplInstance.boardEditing.set null

  'click .priority-switch-checkbox': ->
    boardData = Template.instance().data
    currentSorting = boardData.config.sortByPriority
    newSorting = if currentSorting is 1 then 0 else 1
    updateBoard boardData._id, 'config.sortByPriority': newSorting

  'click .show-archieved': ->
    boardData = Template.instance().data
    showArchivedModeStatus = if Number boardData.config.showArchieved is 1 then 0 else 1
    updateBoard boardData._id, 'config.showArchieved': showArchivedModeStatus

  'click .show-backlog': ->
    currentState = Session.get 'backlogExpanded'
    Session.set 'backlogExpanded', not currentState

  'click .board-settings-button': ->
    tplInstance = Template.instance()
    curShowSettingsState = tplInstance.showSettings.get()
    tplInstance.showSettings.set not curShowSettingsState

  'click #color-chooser': (e, t) ->
    t.$(e.target).parent().find('.dropdown-menu').toggle()

  'click #toggl-project': (e, t) ->
    t.$(e.target).parent().find('.dropdown-menu').toggle()

createTogglProject = (name, boardId, bgColor, cb) ->
  Meteor.call 'toggl/createProject', name: name, boardId: boardId, color: bgColor, (err, res)->
    res.result and fetchProjects()

updateTogglProject = (projectId, data) ->
  Meteor.call 'toggl/updateProject',
    projectId: projectId
    data: data
  , (err, res) ->
    err and console.log err

@updateBoard = (boardId, fieldsToSet) ->
  Boards.update _id: boardId,
    $set: fieldsToSet
    (err, res) ->
      console.log err or res

@removeBoard = (boardId) ->
  Boards.remove _id: boardId, (err, res) ->
    err and console.log err

Template.backlog.inheritsEventsFrom "_boardItem"
Template.backlog.inheritsHelpersFrom "_boardItem"
Template.backlog.inheritsHooksFrom "_boardItem"
Template._nestedBoard.inheritsEventsFrom "_boardItem"
