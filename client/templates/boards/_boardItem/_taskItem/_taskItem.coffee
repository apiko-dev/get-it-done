Template._taskItem.onCreated ->
  @.taskEditing = new ReactiveVar false

Template._taskItem.helpers
  taskEditing: ->
    Template.instance().taskEditing and Template.instance().taskEditing.get()
  description: ->
    Template.instance().data.description or "no description"
  priorityText: ->
    PRIORITY_CLASSES[Template.instance().data.priority]
  isTimeStarted: ->
    !!Template.instance().data.timerStarted
  text: ->
    Template.instance().data.text or "no text"
  taskCompleted: ->
    !!Template.instance().data.completed

Template._taskItem.events
  'click .button.priority': ->
    tplData = Template.instance().data
    taskId = tplData._id
    oldPriority = Number tplData.priority
    newPriority = null

    switch oldPriority
      when 0
        newPriority = 1
      when 1
        newPriority = 2
      when 2
        newPriority = 0
      else
        newPriority = 2

    updateTask taskId, priority: newPriority

  'click .action-edit': ->
    Template.instance().taskEditing.set true

  'click .edit-ok-action': (e, t) ->
    instance = Template.instance()
    taskData = Blaze.getData e.target
    taskText = instance.$("input.title").val()
    taskDescription = instance.$("textarea.description").val()
    taskPriority = Number instance.$('#priority-chooser button').filter(".active").data "value"
    taskBoardNewId = $("#select-board").val()

    taskDoc =
      boardId: taskBoardNewId or taskData.boardId
      text: taskText or taskData.text
      description: taskDescription or taskData.description
      priority: taskPriority or taskData.priority
    updateTask taskData._id, taskDoc
    Template.instance().taskEditing.set false
    if taskBoardNewId
      scrollToBoard(taskBoardNewId)

  'click .edit-cancel-action': (e, t) ->
    Template.instance().taskEditing.set false

  'click .delete-action': (e, t) ->
    taskId = Blaze.getData(e.target)._id
    removeTask taskId

  'click .start-timer': (e, t) ->
    taskData = Blaze.getData e.target
    user = Meteor.user()
    boardOfTask = Boards.findOne taskData.boardId

    if signedInToToggl = user.toggl and user.toggl.api_token and user.toggl.workspaceId
      if togglProjectSelected = boardOfTask.togglProject and boardOfTask.togglProject.id
        Meteor.call 'toggl/startTimer', taskId: taskData._id, taskTitle: taskData.text, boardId: taskData.boardId
      else
        sAlert.error 'You must choose Toggl project for this board'
    else
      Modal.show 'togglSignIn'

  'click .stop-timer': ->
    if signedInToToggl = Meteor.user().toggl and Meteor.user().toggl.api_token
      Meteor.call 'toggl/stopTimer'
    else
      Modal.show 'togglSignIn'

  'click .complete-action': ->
    taskData = Template.instance().data
    taskCompletedStatus = Number taskData.completed
    newTaskCompletedStatus = if taskCompletedStatus is 1 then 0 else 1

    updateTask taskData._id, completed: newTaskCompletedStatus

@removeTask = (taskId) ->
  Tasks.remove {_id: taskId}, (err, res) ->
    console.log err or res

@updateTask = (taskId, fieldsToSet) ->
  Tasks.update _id: taskId,
    $set: fieldsToSet
    (err) ->
      err and console.log err