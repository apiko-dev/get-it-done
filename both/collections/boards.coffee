@Boards = new Mongo.Collection 'boards'

Boards.allow
	insert: (userId, doc) ->
		return true
	update: (userId, doc, fields, modifier) ->
		return true
	remove: (userId, doc) ->
		return true

if Meteor.isClient
	Boards.before.insert (userId, doc) ->
		doc.config = doc.config or {}
		doc.config.bgColor = doc.config.bgColor or '#aaa'

if Meteor.isServer
	Boards.after.remove (userId, doc) -> 
		Tasks.remove {boardId: doc._id}, (err, res) ->
			console.log err or res
		Chips.remove {boardId: doc._id}, (err, res) ->
			console.log err or res