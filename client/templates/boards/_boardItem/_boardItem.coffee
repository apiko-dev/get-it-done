Template._boardItem.onCreated (->
	@.taskCreating = new ReactiveVar false
	@.boardEditing = new ReactiveVar false
)


Template._boardItem.onRendered (->
	if @.data and not @.data.togglProject
		Meteor.call 'toggl/createProject', {name: @.data.title, boardId: @.data._id, color: @.data.config.bgColor}
	@.$('.dropdown-toggle').dropdown()
	@.$('.task-list').sortable
		connectWith: '.task-list'
		helper: 'clone'
		placeholder: 'sortable-placeholder'
		items: '.action'
		forcePlaceholderSize: !0
		dropOnEmpty: true
		opacity: 1
		zIndex: 9999
		start: (e, ui) ->
		  ui.placeholder.height(ui.helper.outerHeight());
		update: (event, ui) ->
			targetBoardId = Blaze.getData(event.target)._id
			targetTaskId = Blaze.getData(ui.item[0])._id
			try
				prevTaskData = Blaze.getData ui.item[0].previousElementSibling
			try
				nextTaskData = Blaze.getData ui.item[0].nextElementSibling
			if !nextTaskData and prevTaskData
				curOrder = prevTaskData.order + 1
			if !prevTaskData and nextTaskData
				curOrder = nextTaskData.order/2
			if !prevTaskData and !nextTaskData
				curOrder = 1
			if prevTaskData and nextTaskData
				curOrder = (nextTaskData.order + prevTaskData.order) / 2
			Tasks.update { _id: targetTaskId }, { $set: boardId: targetBoardId, order: curOrder}, (err, res) ->
				console.log err or res
)

Template._boardItem.helpers
	tasks: () ->
		return Tasks.find { boardId: Template.instance().data._id }, {sort: {order: 1} }
	taskCreating: () ->
		return Template.instance().taskCreating and Template.instance().taskCreating.get()
	boardEditing: () ->
		return Template.instance().boardEditing.get()
	isNoTasks: () ->
		return !Tasks.find({ boardId: Template.instance().data._id }).count()


Template._boardItem.events
	'click .new-task-action': (e, t) ->
		Template.instance().taskCreating.set true

	'click .complete-action': (e, t) ->
		taskData = Blaze.getData(event.target)
		Tasks.update { _id: taskData._id }, { $set: completed: !taskData.completed }, (err, res) ->
  		console.log err or res

	'click .ok-action, keydown .new-task-action .title': (e, t) ->
		if e.type == 'click' or e.keyCode == 13
			text = $(e.target).parent().parent().find('textarea.title').val()
			description = $(e.target).parent().parent().find('textarea.description').val()
			priority = $(e.target).parent().parent().find('select#priority-chooser').val()
			if !text or !text.length
				alert 'text is required'
			else
				boardId = t.data._id
				Tasks.insert {ownerId: Meteor.userId(), boardId: boardId, text: text, description: description, priority: priority || 1, completed: false}, (err, res) ->
					console.log err or res
			Template.instance().taskCreating.set false

	'click .cancel-action': (e, t) ->
		Template.instance().taskCreating.set false

	'click li.color': (e, t) ->
		$(e.target).parent().parent().css('border-color', e.currentTarget.dataset.color + ';')
		boardId = @._id
		self = @
		Boards.update { _id: boardId }, { $set: 'config.bgColor': e.currentTarget.dataset.color}, (err, res) ->
			console.log err or res
		Meteor.call 'toggl/updateProject', {projectId: self.togglProject.id, data: {color: e.currentTarget.dataset.color}}, (err, res)->
			console.log err or res, self.togglProject.id

	'click .delete-board': (e, t) ->
		Boards.remove {_id: t.data._id}, (err, res) ->
			console.log err or res

	'click .edit-board-title': (e, t) ->
		instance = Template.instance()
		cur = instance.boardEditing.get()
		instance.boardEditing.set !cur
		Meteor.setTimeout (->
			t.$('.board-title').focus()
		), 0

	'keyup, focusout input.board-title': (e, t) ->
		if e.type == 'focusout' or e.keyCode == 13
			instance = Template.instance()
			cur = instance.boardEditing.get()
			self = @
			if cur
				title = $(e.currentTarget).parent().find('input').val()
				Boards.update {_id: @._id}, {$set: {title: title}}, (err, res) ->
					console.log err or res
					console.log 'toggl/updateProject'
					res and Meteor.call 'toggl/updateProject', self.togglProject.id, {name: title}, ()->
						console.log err or res, self.togglProject.id
			instance.boardEditing.set null



