Template.newItemModal.onCreated () ->
  @.color = new ReactiveVar(0);

Template.newItemModal.helpers
  isTaskCreating: ->
    return Template.instance().data and !!Template.instance().data.board
  backlogTaskCreating: ->
    return !!Template.instance().data.isBacklogTask
  colors: ->
    array = []
    array.push color: color, _index: i for color, i in COLORS
    return array
  curColor: ()->
    return Template.instance().color.get()

Template.newItemModal.events
  'submit form.new-task': (e, t) ->
    e.preventDefault()
    instance = Template.instance()
    console.log instance
    board = instance.data.board
    titleInput = instance.$('#title')
    descriptionInput = instance.$('#description')

    taskDoc =
      ownerId: Meteor.userId()
      boardId: board._id or board.backlogBoard._id
      text: titleInput.val()
      description: descriptionInput.val()
      priority: Number $('#priority-chooser')[0].dataset.priority
      completed: 0
    if taskDoc.text and taskDoc.description
      Tasks.insert taskDoc, (err, res) ->
        console.log err or res
        res and Modal.hide('newItemModal')

      titleInput.val("")
      descriptionInput.val("")
      sAlert.success 'Successfully created a task'
    else
      alert 'Text and description required'
  'submit form.new-board': (e, t) ->
    e.preventDefault()
    text = $(e.target).find('input#board-title').val()
    if !text or !text.length
      alert 'Board name is required'
    else
      Boards.insert {ownerId: Meteor.userId(), title: text}, (err, res) ->
        res and Modal.hide('newItemModal')
  'click .submit': (e, t) ->
    e.preventDefault()
    $('form.new-task').submit()
#  'click .colors li': (e, t)->
