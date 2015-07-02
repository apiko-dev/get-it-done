Template.priorityChooser.helpers
  isSelected: (priority) ->
    if Template.instance().data is priority
      return "active"
    else return ""

Template.priorityChooser.events
  'click .priority-value': (e, t) ->
    t.$(e.target).parent().find(".priority-value").removeClass "active"
    t.$(e.target).addClass "active"