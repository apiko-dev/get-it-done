@Tasks = new Mongo.Collection 'tasks'

Tasks.allow
	insert: (userId, doc) ->
		userId && userId is doc.ownerId
	update: (userId, doc, fields, modifier) ->
		userId && userId is doc.ownerId
	remove: (userId, doc) ->
		userId && userId is doc.ownerId

if Meteor.isClient
	Tasks.before.insert (userId, doc) ->
		maxOrderTask = Tasks.findOne {boardId: doc.boardId}, {sort: {order: -1}}
		maxOrder = if maxOrderTask then maxOrderTask.order else 0
		doc.order = maxOrder + 1