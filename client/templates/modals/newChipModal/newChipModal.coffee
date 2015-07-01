Template.newChipModal.onDestroyed ->
  delete Session.keys['selectedBoard']
  delete Session.keys['selectedTasks']

Template.newChipModal.onRendered ->
  $('#datetimepicker_start').datetimepicker
    date: new Date @.data.start
    stepping: 30
  $('#datetimepicker_end').datetimepicker
    date: new Date @.data.end
    stepping: 30
  $('#datetimepicker_start').on 'dp.change', (e) ->
    $('#datetimepicker_end').data('DateTimePicker').minDate e.date
  $('#datetimepicker_end').on 'dp.change', (e) ->
    $('#datetimepicker_start').data('DateTimePicker').maxDate e.date

Template.newChipModal.helpers
  data: () ->
    return Template.instance().data
  boards: () ->
    return Boards.find ownerId: Meteor.userId()
  tasks: () ->
    return Tasks.find boardId: Session.get "selectedBoard"

Template.newChipModal.events
  'submit .new-chip': (e, t) ->
    e.preventDefault()
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
      console.log err or res

  'click .submit': (e, t) ->
    $('.new-chip').submit()

  'click #select-board': (e, t) ->
    Session.set "selectedBoard", t.$(e.target).val()

  'click #select-tasks': (e, t) ->
    Session.set "selectedTasks", t.$(e.target).val()