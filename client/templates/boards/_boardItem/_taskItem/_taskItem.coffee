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
      else newPriority = 2

    updateTask taskId, priority: newPriority

  'click .action-edit': ->
    Template.instance().taskEditing.set true

  'click .edit-ok-action': (e, t) ->
    taskData = Blaze.getData e.target
    taskText = $(e.target).parent().parent().find("input.title").val()
    taskDescription = $(e.target).parent().parent().find("textarea.description").val()
    taskPriority = Number $('#priority-chooser button').filter(".active").data "value"
    taskBoardNewId = $("#select-board").val()

    if not taskBoardNewId
      taskBoardOldId = taskData.boardId
      taskBoardNewId = taskBoardOldId

    if taskInputsAreEmpty = not taskText or not taskText.length
      removeTask taskData._id

    taskDoc =
      boardId: taskBoardNewId
      text: taskText
      description: taskDescription
      priority: taskPriority

    updateTask taskData._id, taskDoc
    Template.instance().taskEditing.set false

  'click .edit-cancel-action': (e, t) ->
    Template.instance().taskEditing.set false

  'click .delete-action': (e, t) ->
    taskId = Blaze.getData(e.target)._id
    removeTask taskId

  'click .start-timer': (e, t) ->
    taskData = Blaze.getData e.target
    user = Meteor.user()
    taskBoard = Boards.findOne taskData.boardId

    if signedInToToggl = user.toggl and user.toggl.api_token and user.toggl.workspaceId
      if togglProjectSelected = taskBoard.togglProject and taskBoard.togglProject.id
        Meteor.call 'toggl/startTimer', taskId: taskData._id, taskTitle: taskData.text, boardId: taskData.boardId
      else
        sAlert.error 'You must choose Toggl project for this board'
    else
      Modal.show 'togglSignIn'

  'click .stop-timer': (e) ->
    if signedInToToggl = Meteor.user().toggl and Meteor.user().toggl.api_token
      Meteor.call 'toggl/stopTimer'
    else
      Modal.show 'togglSignIn'

  'click .complete-action': ->
    taskData = Template.instance().data
    taskCompletedStatus = Number taskData.completed
    newTaskCompletedStatus = if taskCompletedStatus is 1 then 0 else 1

    updateTask taskData._id, completed: newTaskCompletedStatus

removeTask = (taskId) ->
  Tasks.remove {_id: taskId}, (err, res) ->
    console.log err or res

updateTask = (taskId, fieldsToSet) ->
  Tasks.update _id: taskId,
    $set: fieldsToSet
    (err, res) ->
      console.log err or res