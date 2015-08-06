Template.newItemModal.onCreated ->
  @.color = new ReactiveVar 0
  @.newTaskForBoard = new ReactiveVar ""

Template.newItemModal.onRendered ->
  $(".main-container, .navbar, .stripe").addClass "blur"

Template.newItemModal.onDestroyed ->
  $(".main-container, .navbar, .stripe").removeClass "blur"

Template.newItemModal.helpers
  isTaskCreating: ->
    Template.instance().data and !!Template.instance().data.board
  backlogTaskCreating: ->
    !!Template.instance().data.isBacklogTask
  colors: ->
    array = []
    array.push color: color, _index: i for color, i in COLORS
    array
  curColor: ->
    Template.instance().color.get()
  backgroundColor: ->
    COLORS[Template.instance().color.get()]

Template.newItemModal.events
  'submit form.new-task': (e) ->
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

  'submit form.new-board': (e) ->
    e.preventDefault()
    boardDoc = {}
    text = $(e.target).find('input#board-title').val()
    buttonPressed = Template.instance().data.buttonPressed

    if buttonPressed is "left"
      boardDoc.insertInTheBeginning = true
      boardDoc.minBoardOrder = Boards.findOne({}, {
        sort:
          order: 1
      }).order

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
        Modal.hide('newItemModal')
        if res
          scrollToBoard res


  'click .new-task .submit': (e) ->
    e.preventDefault()
    $('form.new-task').submit()

  'click .new-board .submit': (e) ->
    e.preventDefault()
    $('form.new-board').submit()

  'click ul.colors li span': (e, t) ->
    colorIndex = t.$(e.target).parent().index()
    Template.instance().color.set colorIndex

#t.$(".modal.light.new-item.in").css "backgroud-color"