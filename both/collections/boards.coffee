@Boards = new Mongo.Collection 'boards'

Boards.allow
	insert: (userId, doc) ->
		return true
	update: (userId, doc, fields, modifier) ->
		return true
	remove: (userId, doc) ->
		return true
