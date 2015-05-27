@Tasks = new Mongo.Collection 'tasks'

Tasks.allow
	insert: (userId, doc) ->
		return true
	update: (userId, doc, fields, modifier) ->
		return true
	remove: (userId, doc) ->
		return true
