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
	priority: () ->
		return PRIORITY_CLASSES[Template.instance().data.priority]
	description: () ->
		return Template.instance().description or 'no description'

Template._taskItem.events
	'click .action-edit': (e, t) ->
		Template.instance().taskEditing.set true
	'click .edit-ok-action': (e, t) ->
		taskData = Blaze.getData(e.target)
		text = $(e.target).parent().parent().find('textarea.title').val()
		description = $(e.target).parent().parent().find('textarea.description').val()
		priority = $(e.target).parent().parent().find('select#priority-chooser').val()
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
		console.log 'start'
		task = Blaze.getData e.target
		TogglClientSide.startTimer {taskTitle: task.text}, (err, res) ->
			toggleTask task, 1
	'click .stop-timer': (e, t) ->
		console.log 'stop'
		task = Blaze.getData e.target
		TogglClientSide.stopTimer (err, res) ->
			console.log 'stop timer callback'
			toggleTask task, 0
			


toggleTask = (task, timerStarted) ->
	console.log 'toggle task', timerStarted
	Tasks.update {_id: task._id}, {$set: {'timerStarted': timerStarted}}, (err, res)->
		console.log err or res

removeTask = (taskId) ->
	Tasks.remove {_id: taskId}, (err, res) ->
		console.log err or res