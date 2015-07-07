Template.backlog.onCreated ->
  @.taskCreating = new ReactiveVar false

Template.backlog.onRendered ->
  $('.dropdown-toggle').dropdown()
  @.$('.task-list').sortable taskListOptions

Template.backlog.helpers
  backlogExpanded: ->
    Session.get 'backlogExpanded'
