Template.priorityChooser.onCreated ()->
  @.currentPriority = new ReactiveVar 1

Template.priorityChooser.onRendered ()->
  console.log @.data.priority
  @.currentPriority.set Number(@.data.priority)

Template.priorityChooser.helpers
  isSelected: (priority) ->
    return priority == Template.instance().currentPriority.get()

Template.priorityChooser.events
  'click .priority-value': (e, t) ->
    Template.instance().currentPriority.set Number(e.target.dataset.value)