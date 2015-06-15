Template._taskItem.onCreated (->
	@.taskEditing = new ReactiveVar(false);
	@.showDescription = new ReactiveVar(false);
)

Template._taskItem.helpers
	taskEditing: () ->
		return Template.instance().taskEditing and Template.instance().taskEditing.get()
	showDescription: () ->
		return Template.instance().showDescription.get()

Template._taskItem.events
	'click .action-edit': (e, t) ->
		Template.instance().taskEditing.set true
	'click .edit-ok-action': (e, t) ->
		taskData = Blaze.getData(e.target)
		text = $(e.target).parent().parent().find('textarea.title').val()
		description = $(e.target).parent().parent().find('textarea.description').val()
		console.log text
		console.log description
		if !text or !text.length
			removeTask taskData._id
		Tasks.update { _id: taskData._id }, { $set: {text: text, description: description}}, (err, res) ->
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



removeTask = (taskId) ->
	Tasks.remove {_id: taskId}, (err, res) ->
		console.log err or res