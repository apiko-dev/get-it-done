Template.newChipModal.onDestroyed ->
  delete Session.keys['selectedBoard']
  delete Session.keys['selectedTasks']
  $(".main-container, .navbar, .stripe").removeClass "blur"

Template.newChipModal.onRendered ->
  $(".main-container, .navbar, .stripe").addClass "blur"
  @.$('.selectpicker').selectpicker()
  @.$('#datetimepicker_start').datetimepicker
    date: new Date @.data.start
    stepping: 30

  @.$('#datetimepicker_end').datetimepicker
    date: new Date @.data.end
    stepping: 30

  @.$('#datetimepicker_start').on 'dp.change', (e) ->
    $('#datetimepicker_end').data('DateTimePicker').minDate e.date

  @.$('#datetimepicker_end').on 'dp.change', (e) ->
    $('#datetimepicker_start').data('DateTimePicker').maxDate e.date

Template.newChipModal.helpers
  data: ->
    Template.instance().data
  boards: ->
    Boards.find
      ownerId: Meteor.userId()
      isBacklog:
        $exists: false
  tasks: ->
    tasks = Tasks.find boardId: Session.get "selectedBoard"
    Meteor.setTimeout ->
      $('#select-tasks').selectpicker "refresh"
    , 500
    tasks

Template.newChipModal.events
  'submit form#new-chip': (e, t) ->
    e.preventDefault()
    console.log 'submit form#new-chip'
    startTime = e.target[0].value
    endTime = e.target[1].value
    selectedBoardId = e.target[2].value
    selectedTasksIds = t.$("#select-tasks").val()

    chipDoc =
      ownerId: Meteor.userId()
      start: startTime
      end: endTime
      boardId: selectedBoardId
      taskIds: selectedTasksIds

    Chips.insert chipDoc, (err, res) ->
      if res
        Modal.hide '.modal.new-chip'
      else
        sAlert.error "Problem with event creation"

  'click .submit': (e, t) ->
    $('form#new-chip').submit()

  'change #select-board': (e, t) ->
    Session.set "selectedBoard", t.$(e.target).val()

  'click #select-tasks': (e, t) ->
    Session.set "selectedTasks", t.$(e.target).val()