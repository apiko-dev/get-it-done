@Tasks = new Mongo.Collection 'tasks'

Tasks.allow
	insert: (userId, doc) ->
		return true
	update: (userId, doc, fields, modifier) ->
		return true
	remove: (userId, doc) ->
		return true

if Meteor.isClient
	Tasks.before.insert (userId, doc) ->
		maxOrderTask = Tasks.findOne {boardId: doc.boardId}, {sort: {order: -1}}
		maxOrder = if maxOrderTask then maxOrderTask.order else 0
		doc.order = maxOrder + 1