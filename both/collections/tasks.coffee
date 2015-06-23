@Tasks = new Mongo.Collection 'tasks'

Tasks.allow
	insert: (userId, doc) ->
		userId and userId is doc.ownerId
	update: (userId, doc, fields, modifier) ->
		userId and userId is doc.ownerId
	remove: (userId, doc) ->
		userId and userId is doc.ownerId

if Meteor.isClient
	Tasks.before.insert (userId, doc) ->
		maxOrderTask = Tasks.findOne {boardId: doc.boardId}, {sort: {order: -1}}
		maxOrder = if maxOrderTask then maxOrderTask.order else 0
		doc.order = maxOrder + 1

if Meteor.isServer
	Tasks.before.update (userId, doc) ->
		console.log 'before update', doc
		if doc.timerStarted is 1
			Tasks.update {ownerId: userId, timerStarted: 1}, {$set: {timerStarted: 0}}, {multi: 1}