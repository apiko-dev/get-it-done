Template.highPriorityBoard.helpers
  highPriorityExpanded: ->
    Session.get 'highPriorityExpanded'

Template.highPriorityBoard.events
  'click .show-high-priority': ->
    cur = Session.get 'highPriorityExpanded'
    Session.set 'highPriorityExpanded', not cur