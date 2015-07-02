Template.newItemModal.onCreated () ->
  @.color = new ReactiveVar(0);

Template.newItemModal.helpers
  isTaskCreating: () ->
    return Template.instance().data and !!Template.instance().data.board
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
    board = instance.data.board
    taskDoc =
      ownerId: Meteor.userId()
      boardId: board._id
      text: instance.$('#title').val()
      description: instance.$('#description').val()
      priority: Number $('#priority-chooser')[0].dataset.priority
      completed: 0
    if taskDoc.text and taskDoc.description
      Tasks.insert taskDoc, (err, res) ->
        console.log err or res
        res and $('.new-task').modal 'hide'
    else
      alert 'Text and description required'


  'click .submit': (e, t) ->
    e.preventDefault()
    $('form.new-task').submit()
#  'click .colors li': (e, t)->