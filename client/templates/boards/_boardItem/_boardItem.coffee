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
        console.log "tid: #{targetTaskId}, bid: #{targetBoardId}, crdr: #{curOrder}"
)

Template._boardItem.helpers
	colors: () ->
		arr = []
		for el, i in COLORS
			arr.push { _index: i, color: el }
		return arr;
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

	'click .ok-action, keyup .new-task-action .title': (e, t) ->
		if e.type == 'click' or e.keyCode == 13
			$textarea = $(e.target).parent().parent().find('textarea.title')
			text = $textarea.val()
			# description = $(e.target).parent().parent().find('textarea.description').val()
			# priority = $(e.target).parent().parent().find('select#priority-chooser').val()
			if !text or !text.length
				alert 'text is required'
			else
				boardId = t.data._id
				Tasks.insert { ownerId: Meteor.userId(), boardId: boardId, text: text, priority: 1, completed: false }, (err, res) ->
					console.log err or res
			$textarea.val('')
			if e.type == 'click'
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
				Meteor.call 'toggl/updateProject', {projectId: self.togglProject.id, data: {name: title}}, (err, res)->
					console.log err or res, self.togglProject.id
			instance.boardEditing.set null


	'click .sort-by-priority': (e) ->
    elements = []
    boardIndex = $(e.target).index('.sort-by-priority')

    sortChildren document.querySelectorAll('.task-list')[boardIndex], (el) ->
      elData = Blaze.getData el
      taskId = elData._id
      boardId = elData.boardId
      order = 0

      if $(el).find('.priority').hasClass('LOW')
        order = 1
      else if $(el).find('.priority').hasClass('HIGH')
        order = -1
      else order = 0

      elements.push
        taskId: taskId
        boardId: boardId
        order: order

      return order

    elements.sort (a, b) ->
      if a.order > b.order then 1 else if b.order > a.order then -1 else 0

    for el in elements
      Tasks.update { _id: el.taskId }, { $set: boardId: el.boardId, order: el.order}, (err, res) ->
        console.log err or res

# http://stackoverflow.com/a/24342401/2727317
sortChildren = (wrap, f, isNum) ->
	l = wrap.children.length
	arr = new Array(l)
	i = 0
	while i < l
		arr[i] = [
			f(wrap.children[i])
			wrap.children[i]
		]
		++i
	arr.sort if isNum then ((a, b) ->
		a[0] - (b[0])
	) else ((a, b) ->
		if a[0] < b[0] then -1 else if a[0] > b[0] then 1 else 0
	)
	par = wrap.parentNode
	ref = wrap.nextSibling
	par.removeChild wrap
	j = 0
	while j < l
		wrap.appendChild arr[j][1]
		++j
	par.insertBefore wrap, ref
	return
