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
		maxOrderBoard = Boards.findOne {boardId: doc.boardId}, {sort: {order: -1}}
		maxOrder = if maxOrderBoard then maxOrderBoard.order else 0
		doc.order = maxOrder + 1

if Meteor.isServer
	Boards.after.remove (userId, doc) -> 
		Tasks.remove {boardId: doc._id}, (err, res) ->
			console.log err or res
		Chips.remove {boardId: doc._id}, (err, res) ->
			console.log err or res
