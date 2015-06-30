PRIORITY_CLASSES = [
  'LOW'
  'MED'
  'HIGH'
]

Template._taskItem.onCreated (->
	@.taskEditing = new ReactiveVar(false);
	@.showDescription = new ReactiveVar(false);
)

Template._taskItem.helpers
	taskEditing: () ->
		return Template.instance().taskEditing and Template.instance().taskEditing.get()
	showDescription: () ->
		return Template.instance().showDescription.get()
	description: () ->
		return Template.instance().data.description or "no description"
	priority: () ->
		return PRIORITY_CLASSES[Template.instance().data.priority]
	isTimeStarted: () ->
		return !!Template.instance().data.timerStarted
	isSelected: (priority) ->
		if parseInt(Template.instance().data.priority) is priority
			return "selected"
		else return ""
Template._taskItem.events
	'click .action-edit': (e, t) ->
		Template.instance().taskEditing.set true
	'click .edit-ok-action': (e, t) ->
		taskData = Blaze.getData(e.target)
		text = $(e.target).parent().parent().find('textarea.title').val()
		description = $(e.target).parent().parent().find('textarea.description').val()
		priority = Number $(e.target).parent().parent().find('select#priority-chooser').val()

		if !text or !text.length
			removeTask taskData._id

		Tasks.update { _id: taskData._id }, { $set: {text: text, description: description, priority: priority}}, (err, res) ->
  		console.log err or res

		Template.instance().taskEditing.set false
	'click .edit-cancel-action': (e, t) ->
		Template.instance().taskEditing.set false
	'click .delete-action': (e, t) ->
		taskId = Blaze.getData(e.target)._id
		removeTask taskId
	'click .show-description': (e, t) ->
		instance = Template.instance()
		cur = instance.showDescription.get()
		instance.showDescription.set !cur
	'click .start-timer': (e, t) ->
		task = Blaze.getData e.target
		if Meteor.user().toggl and Meteor.user().toggl.api_token
			Meteor.call	'toggl/startTimer', {taskId: task._id, taskTitle: task.text, boardId: task.boardId}
		else
			Modal.show 'togglSignIn'
	'click .stop-timer': (e, t) ->
		task = Blaze.getData e.target
		if Meteor.user().toggl and Meteor.user().toggl.api_token
			Meteor.call 'toggl/stopTimer'
		else
			Modal.show 'togglSignIn'


removeTask = (taskId) ->
	Tasks.remove {_id: taskId}, (err, res) ->
		console.log err or res