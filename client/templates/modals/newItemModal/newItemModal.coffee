Template.newItemModal.onCreated () ->
  @.color = new ReactiveVar 0

Template.newItemModal.helpers
  isTaskCreating: ->
    return Template.instance().data and !!Template.instance().data.board
  backlogTaskCreating: ->
    return !!Template.instance().data.isBacklogTask
  colors: ->
    array = []
    array.push color: color, _index: i for color, i in COLORS
    return array
  curColor: ->
    return Template.instance().color.get()
  backgroundColor: ->
    return COLORS[Template.instance().color.get()]

Template.newItemModal.events
  'submit form.new-task': (e, t) ->
    e.preventDefault()
    instance = Template.instance()
    boardId = ""

    if Template.instance().data.isBacklogTask
      boardId = instance.data.board.backlogBoard._id

      selectedBoard = $("#select-board").val()
      boardId = selectedBoard if selectedBoard.length > 0
    else
      boardId = instance.data.board._id

    titleInput = instance.$('#title')
    descriptionInput = instance.$('#description')

    taskDoc =
      ownerId: Meteor.userId()
      boardId: boardId
      text: titleInput.val()
      description: descriptionInput.val()
      priority: Number $('#priority-chooser')[0].dataset.priority
      completed: 0

    if taskDoc.text
      Tasks.insert taskDoc, (err, res) ->
        console.log err or res
        res and Modal.hide('newItemModal')

      titleInput.val("")
      descriptionInput.val("")
      sAlert.success 'Successfully created a task'
    else
      sAlert.error "Please, enter the title"

  'submit form.new-board': (e, t) ->
    e.preventDefault()
    boardDoc = {}
    text = $(e.target).find('input#board-title').val()
    buttonPressed = Template.instance().data.buttonPressed

    if buttonPressed is "left"
      boardDoc.insertInTheBeginning = true
      boardDoc.minBoardOrder = Boards.findOne({}, {sort: order: 1}).order

    if !text or !text.length
      alert 'Board name is required'
    else
      boardProperties =
        ownerId: Meteor.userId()
        title: text
        config:
          bgColor: Template.instance().color.get()

      _.extend boardDoc, boardProperties

      Boards.insert boardDoc, (err, res) ->
        if err
          sAlert.error "Error while creating board"
#        if res
#          sAlert.success "Successfully created a board #{boardDoc.title}"
        Modal.hide('newItemModal')


  'click .submit': (e, t) ->
    e.preventDefault()
    $('form.new-task').submit()

  'click ul.colors li span': (e, t)->
    colorIndex = t.$(e.target).parent().index()
    Template.instance().color.set colorIndex

    t.$(".modal.light.new-item.in").css "backgroud-color"