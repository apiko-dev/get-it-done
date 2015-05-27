Template._boardItem.helpers
	tasks: () ->
		return Tasks.find boardId: Template.instance().data._id