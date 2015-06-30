PRIORITY_CLASSES = [
	'LOW'
	'MED'
	'HIGH'
]

Template._taskItem.onCreated (->
	@.taskEditing = new ReactiveVar false
)

Template._taskItem.helpers
	taskEditing: () ->
		Template.instance().taskEditing and Template.instance().taskEditing.get()
	description: () ->
		Template.instance().data.description or "no description"
	priority: () ->
		PRIORITY_CLASSES[Template.instance().data.priority]
	isTimeStarted: () ->
		!!Template.instance().data.timerStarted
	isSelected: (priority) ->
		if parseInt(Template.instance().data.priority) is priority
			return "selected"
		else return ""
	text: () ->
		Template.instance().data.text or "no text"

Template._taskItem.events
	'click .button.priority': (e) ->
		oldPriority = Number Template.instance().data.priority
		newPriority = 2
		if oldPriority is 0
			newPriority =  1
		if oldPriority is 1
			newPriority =  2
		if oldPriority is 2
			newPriority =  0

		taskId = Template.instance().data._id
		Tasks.update {_id: taskId}, {$set: {priority: newPriority}}, (err, res) ->
			console.log err or res
	'click .action-edit': (e, t) ->
		Template.instance().taskEditing.set true
	'click .edit-ok-action': (e, t) ->
		taskData = Blaze.getData(e.target)
		text = $(e.target).parent().parent().find('textarea.title').val()
		description = $(e.target).parent().parent().find('textarea.description').val()
		priority = Number $(e.target).parent().parent().find('select#priority-chooser').val()

		if !text or !text.length
			removeTask taskData._id

		Tasks.update {_id: taskData._id}, {$set: {text: text, description: description, priority: priority}}, (err, res) ->
			console.log err or res

		Template.instance().taskEditing.set false
	'click .edit-cancel-action': (e, t) ->
		Template.instance().taskEditing.set false
	'click .delete-action': (e, t) ->
		taskId = Blaze.getData(e.target)._id
		removeTask taskId
	'click .start-timer': (e, t) ->
		task = Blaze.getData e.target
		user = Meteor.user()
		board = Boards.findOne task.boardId
		if user.toggl and user.toggl.api_token and user.toggl.workspaceId
			if board.togglProject and board.togglProject.id
				Meteor.call	'toggl/startTimer', {taskId: task._id, taskTitle: task.text, boardId: task.boardId}
			else
				alert 'You must choose Toggl project for this board'
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