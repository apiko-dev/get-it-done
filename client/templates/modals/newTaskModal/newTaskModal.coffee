Template.newTaskModal.events
  'submit .new-task': (e, t) ->
    e.preventDefault()
    board = Template.instance().data.board
    console.log '---------------------'
    console.log board
    console.log 'e', e
    console.log 't', t
    #taskDoc =
    #  ownerId: Meteor.userId()
    #  boardId: board._id
    #  text: text
    #  description: description
    #  priority: if priority? then priority else 1
    #  completed: 0
    #Tasks.insert taskDoc, (err, res) ->
    #  err and console.log(err)

  'click .submit': (e, t) ->
    e.preventDefault()
    $('.new-task').submit()